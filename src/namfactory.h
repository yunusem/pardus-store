#ifndef NAMFACTORY_H
#define NAMFACTORY_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QQmlNetworkAccessManagerFactory>
#include <QNetworkRequest>
#include <QNetworkDiskCache>
#include <QDesktopServices>
#include <QStandardPaths>
#include <QDir>

#define CACHE_PATH "/.cache/pardus-store/"

class StoreNetworkAccessManager : public QNetworkAccessManager
{
public:
    StoreNetworkAccessManager(QObject *parent) : QNetworkAccessManager(parent) { }

protected:
    QNetworkReply *createRequest(Operation operation, const QNetworkRequest &request, QIODevice *outgoingData = nullptr) override
    {
        QNetworkRequest cacheRequest(request);
        cacheRequest.setAttribute(QNetworkRequest::CacheLoadControlAttribute,
          (networkAccessible() == QNetworkAccessManager::Accessible) ? QNetworkRequest::PreferCache : QNetworkRequest::AlwaysCache);
        return QNetworkAccessManager::createRequest(operation, cacheRequest, outgoingData);
    }
};

class NamFactory : public QQmlNetworkAccessManagerFactory
{
public:
    QNetworkAccessManager *create(QObject *parent) override;

};


QNetworkAccessManager *NamFactory::create(QObject *parent)
{
    QNetworkAccessManager *nam = new StoreNetworkAccessManager(parent);
    QNetworkDiskCache *cache = new QNetworkDiskCache(nam);
    cache->setCacheDirectory(QDir::homePath().append(QString(CACHE_PATH)));
    nam->setCache(cache);
    return nam;
}

#endif // NAMFACTORY_H
