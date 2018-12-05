#include "networkhandler.h"
#include "applicationdetail.h"
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QNetworkInterface>
#include <QNetworkProxyFactory>
#include <QNetworkProxy>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QTimer>
#include <QDebug>

#define MAIN_URL "http://store.pardus.org.tr:5000"
#define API_APPS_URL "http://store.pardus.org.tr:5000/api/v1/apps/"
#define API_SURVEY_URL "http://store.pardus.org.tr:5000/api/v1/survey/"

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
    QNetworkProxyQuery npq(QUrl(MAIN_URL));
    QList<QNetworkProxy> listOfProxies = QNetworkProxyFactory::systemProxyForQuery(npq);
    foreach ( QNetworkProxy p, listOfProxies ) {
        if(p.hostName() != "") {
            m_nam.setProxy(p);
        }
    }
    connect(&m_nam, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(replyFinished(QNetworkReply*)));
}

void NetworkHandler::getApplicationList()
{
    QNetworkReply *reply;
    QTimer *timer = new QTimer();
    connect(timer, SIGNAL(timeout()), this, SLOT(onTimeout()));
    timer->setSingleShot(true);
    reply = m_nam.get(QNetworkRequest(QUrl(API_APPS_URL)));
    timer_put(&m_timerMap, reply, timer);
    timer->start(m_timeoutDuration);
}

void NetworkHandler::getApplicationDetails(const QString &packageName)
{
    QNetworkReply *reply;
    QString url = QString(API_APPS_URL).append(packageName);
    QTimer *timer = new QTimer();
    connect(timer, SIGNAL(timeout()), this, SLOT(onTimeout()));
    timer->setSingleShot(true);
    reply = m_nam.get(QNetworkRequest(QUrl(url)));
    timer_put(&m_timerMap, reply, timer);
    timer->start(m_timeoutDuration);
}

void NetworkHandler::surveyCheck()
{
    QUrl url(QString(API_SURVEY_URL).append("list"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject data;
    QString mac;
    foreach (QNetworkInterface interface, QNetworkInterface::allInterfaces()) {
        auto flags = interface.flags();
        if(flags.testFlag(QNetworkInterface::IsRunning) &&
                !flags.testFlag(QNetworkInterface::IsLoopBack)) {
            mac = interface.hardwareAddress();
            break;
        }
    }

    data.insert("mac",QJsonValue::fromVariant(mac));

    QNetworkReply *reply;
    QTimer *timer = new QTimer();
    connect(timer, SIGNAL(timeout()), this, SLOT(onTimeout()));
    timer->setSingleShot(true);
    reply = m_nam.post(request, QJsonDocument(data).toJson());
    timer_put(&m_timerMap, reply, timer);
    timer->start(m_timeoutDuration);
}

void NetworkHandler::surveyJoin(const QString &appName, const QString &duty)
{
    QUrl url(QString(API_SURVEY_URL).append("join"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject data;
    QString mac;
    foreach (QNetworkInterface interface, QNetworkInterface::allInterfaces()) {
        auto flags = interface.flags();
        if(flags.testFlag(QNetworkInterface::IsRunning) &&
                !flags.testFlag(QNetworkInterface::IsLoopBack)) {
            mac = interface.hardwareAddress();
            break;
        }
    }

    data.insert("mac",QJsonValue::fromVariant(mac));
    data.insert("app",QJsonValue::fromVariant(appName));
    data.insert("duty",QJsonValue::fromVariant(duty));

    QNetworkReply *reply;
    QTimer *timer = new QTimer();
    connect(timer, SIGNAL(timeout()), this, SLOT(onTimeout()));
    timer->setSingleShot(true);
    reply = m_nam.post(request, QJsonDocument(data).toJson());
    timer_put(&m_timerMap, reply, timer);
    timer->start(m_timeoutDuration);
}

QString NetworkHandler::getMainUrl() const
{
    return QString(MAIN_URL);
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
    } else if(obj.contains("survey-list")) {
        QStringList sl;
        QString ps;
        auto surveylist = obj["survey-list"].toObject();
        ps = surveylist["individual"].toString();
        QJsonArray counts = surveylist["counts"].toArray();
        for(int i=0; i< counts.size();i++) {
            QString app = counts.at(i).toObject()["app"].toString();
            int count = counts.at(i).toObject()["count"].toInt();
            sl.append(app + " " + QString::number(count));
        }
        emit surveyListReceived(ps, sl);
    } else if(obj.contains("survey-join")) {
        auto surveyjoin = obj["survey-join"].toObject();
        QString duty = surveyjoin["duty"].toString();
        int result = surveyjoin["result"].toInt();
        emit surveyJoinResultReceived(duty, result);
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
