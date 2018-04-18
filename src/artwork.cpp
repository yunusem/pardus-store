#include "artwork.h"

#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QTimer>
#include <QDebug>

#include "screenshotinfo.h"

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

Artwork::Artwork(int msec, QObject *parent) :
    QObject(parent),
    m_timeoutDuration(msec)
{
    connect(&m_nam, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(replyFinished(QNetworkReply*)));
}

void Artwork::get(const QString &packageName)
{
    QNetworkReply *reply;
    QString url = QString("http://screenshots.debian.net/json/package/%1")
            .arg(packageName);
    QTimer *timer = new QTimer();
    connect(timer, SIGNAL(timeout()), this, SLOT(onTimeout()));
    timer->setSingleShot(true);
    reply = m_nam.get(QNetworkRequest(QUrl(url)));
    timer_put(&m_timerMap, reply, timer);
    timer->start(m_timeoutDuration);
}

void Artwork::replyFinished(QNetworkReply *reply)
{
    auto timer = timer_get(&m_timerMap, reply);
    if (timer) {
        timer->stop();
        timer->deleteLater();
    }

    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << reply->errorString();
        emit screenshotNotFound();
        return;
    }

    auto data = reply->readAll();
    auto doc = QJsonDocument::fromJson(data);

    if (doc.isNull()) {
        qDebug("Not a json document!");
        emit screenshotNotFound();
        return;
    }

    auto obj = doc.object();
    if (obj["status"].toString() == "404") {
        qDebug("Error: not found!");
        emit screenshotNotFound();
        return;
    }

    QString packageName = obj["package"].toString();

    QList<Screenshot> sshots;
    auto arr = obj["screenshots"].toArray();
    foreach(const QJsonValue &val, arr) {
        obj = val.toObject();
        sshots.append(Screenshot(obj["small_image_url"].toString(),
                      obj["large_image_url"].toString(),
                obj["version"].toString()));
    }

    emit screenshotReceived(ScreenshotInfo(packageName, sshots));
}

void Artwork::onTimeout()
{
    QTimer *timer;
    QNetworkReply *reply;

    timer = static_cast<QTimer *>(sender());
    reply = reply_get(&m_timerMap, timer);

    // finished() signal will also be emitted
    if (reply)
        reply->abort();
}
