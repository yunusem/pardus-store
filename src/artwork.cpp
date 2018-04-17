#include "artwork.h"

#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QDebug>

#include "screenshotinfo.h"

Artwork::Artwork(QObject *parent) : QObject(parent)
{
    connect(&m_nam, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(replyFinished(QNetworkReply*)));
}

void Artwork::get(const QString &packageName)
{
    QString url = QString("http://screenshots.debian.net/json/package/%1")
            .arg(packageName);
    m_nam.get(QNetworkRequest(QUrl(url)));
}

void Artwork::replyFinished(QNetworkReply *reply)
{
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
