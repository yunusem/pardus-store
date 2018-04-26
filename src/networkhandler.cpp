#include "networkhandler.h"
#include "applicationdetail.h"
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QTimer>
#include <QDebug>

#define MAIN_URL "http://depo.pardus.org.tr:5000"
#define API_URL "http://depo.pardus.org.tr:5000/api/v1/apps/"

namespace {

QTimer *timer_get(std::map<QNetworkReply *, QTimer *> *m, QNetworkReply *reply)
{
    auto it = m->find(reply);

    if (it != m->end()) {
        m->erase(it);
        return it->second;
    }
    return nullptr;
}

void timer_put(std::map<QNetworkReply *, QTimer *> *m,
               QNetworkReply *reply, QTimer *timer)
{
    auto it = m->lower_bound(reply);

    if (it != m->end() && !(m->key_comp()(reply, it->first))) {
        qWarning("Reply already has an associated timer!");
        return;
    }
    m->insert(it, std::map<QNetworkReply *, QTimer *>::value_type(reply, timer));
}

QNetworkReply *reply_get(std::map<QNetworkReply *, QTimer *> *m, QTimer *t)
{
    std::map<QNetworkReply *, QTimer *>::iterator it;

    for (it = m->begin(); it != m->end(); ++it) {
        if (it->second == t)
            return it->first;
    }
    return nullptr;
}
}

NetworkHandler::NetworkHandler(int msec, QObject *parent) : QObject(parent),
    m_timeoutDuration(msec)
{
    connect(&m_nam, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(replyFinished(QNetworkReply*)));
}

void NetworkHandler::getApplicationList()
{
    QNetworkReply *reply;
    QTimer *timer = new QTimer();
    connect(timer, SIGNAL(timeout()), this, SLOT(onTimeout()));
    timer->setSingleShot(true);
    reply = m_nam.get(QNetworkRequest(QUrl(API_URL)));
    timer_put(&m_timerMap, reply, timer);
    timer->start(m_timeoutDuration);
}

void NetworkHandler::getApplicationDetails(const QString &packageName)
{
    QNetworkReply *reply;
    QString url = QString(API_URL).append(packageName);
    QTimer *timer = new QTimer();
    connect(timer, SIGNAL(timeout()), this, SLOT(onTimeout()));
    timer->setSingleShot(true);
    reply = m_nam.get(QNetworkRequest(QUrl(url)));
    timer_put(&m_timerMap, reply, timer);
    timer->start(m_timeoutDuration);
}

void NetworkHandler::replyFinished(QNetworkReply *reply)
{
    auto timer = timer_get(&m_timerMap, reply);
    if (timer) {
        timer->stop();
        timer->deleteLater();
    }

    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << reply->errorString();
        emit notFound();
        return;
    }

    auto data = reply->readAll();
    auto doc = QJsonDocument::fromJson(data);

    if (doc.isNull()) {
        qDebug("Not a json document!");
        emit notFound();
        return;
    }

    auto obj = doc.object();
    if (obj["status"].toString() == "400") {
        qDebug() << obj["error"].toString();
        emit notFound();
        return;
    }

    if (obj.contains("app-list")) {
        QStringList apps;
        QString item;
        auto arr = obj["app-list"].toArray();
        for(int i=0; i < arr.size(); i++) {
            item = QString("");
            item += QString(arr.at(i).toObject()["name"].toString()) + " ";
            item += QString(arr.at(i).toObject()["category"].toString());
            apps.append(item);
        }
        emit appListReceived(apps);
    } else if (obj.contains("details")) {
        QStringList ss;
        QList<Description> descs;
        QString appName = obj["name"].toString();
        auto details = obj["details"].toObject();
        QJsonArray screenshots = details["screenshots"].toArray();
        for(int i=0; i < screenshots.size(); i++) {
            if(screenshots.at(i).toString() != "") {
                ss.append(QString(MAIN_URL).append(screenshots.at(i).toString()));
            }
        }
        QJsonObject descObj = details["descriptions"].toObject();
        foreach(const QString &key, descObj.keys()) {
            QJsonValue value = descObj.value(key);
            descs.append(Description(key,value.toString()));
        }
        emit appDetailsReceived(ApplicationDetail(appName,ss,descs));
    }
}

void NetworkHandler::onTimeout()
{
    QTimer *timer;
    QNetworkReply *reply;

    timer = static_cast<QTimer *>(sender());
    reply = reply_get(&m_timerMap, timer);

    // finished() signal will also be emitted
    if (reply)
        reply->abort();
}
