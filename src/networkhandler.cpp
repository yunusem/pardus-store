#include "networkhandler.h"
#include "application.h"
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
#include <QLocale>
#include <QTimer>
#include <QDebug>

#define MAIN_URL "http://0.0.0.0:5000" //"http://store.pardus.org.tr:5000"

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

    foreach (QNetworkInterface interface, QNetworkInterface::allInterfaces()) {
        auto flags = interface.flags();
        if(flags.testFlag(QNetworkInterface::IsRunning) &&
                !flags.testFlag(QNetworkInterface::IsLoopBack)) {
            m_macId = interface.hardwareAddress();
            break;
        }
    }
}

void NetworkHandler::getApplicationList()
{
    QNetworkReply *reply;
    QTimer *timer = new QTimer();
    connect(timer, SIGNAL(timeout()), this, SLOT(onTimeout()));
    timer->setSingleShot(true);
    reply = m_nam.get(QNetworkRequest(QUrl(QString(MAIN_URL).append("/api/v2/apps/"))));
    timer_put(&m_timerMap, reply, timer);
    timer->start(m_timeoutDuration);
}

void NetworkHandler::getApplicationDetails(const QString &packageName)
{    
    QNetworkReply *reply;
    QString url = QString(MAIN_URL).append("/api/v2/apps/"+ packageName);
    QTimer *timer = new QTimer();
    connect(timer, SIGNAL(timeout()), this, SLOT(onTimeout()));
    timer->setSingleShot(true);
    reply = m_nam.get(QNetworkRequest(QUrl(url)));
    timer_put(&m_timerMap, reply, timer);
    timer->start(m_timeoutDuration);
}

void NetworkHandler::ratingControl(const QString &name, const unsigned int &rating)
{
    QString url(QString(MAIN_URL).append("/api/v2/rating"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject data;
    data.insert("mac", QJsonValue::fromVariant(m_macId));
    data.insert("app", QJsonValue::fromVariant(name));
    data.insert("rating", QJsonValue::fromVariant(rating));

    QNetworkReply *reply;
    QTimer *timer = new QTimer();
    connect(timer, SIGNAL(timeout()), this, SLOT(onTimeout()));
    timer->setSingleShot(true);
    reply = m_nam.post(request, QJsonDocument(data).toJson());
    timer_put(&m_timerMap, reply, timer);
    timer->start(m_timeoutDuration);
}

void NetworkHandler::getHomeDetails()
{
    QNetworkReply *reply;
    QString url = QString(MAIN_URL).append("/api/v2/home");
    QTimer *timer = new QTimer();
    connect(timer, SIGNAL(timeout()), this, SLOT(onTimeout()));
    timer->setSingleShot(true);
    reply = m_nam.get(QNetworkRequest(QUrl(url)));
    timer_put(&m_timerMap, reply, timer);
    timer->start(m_timeoutDuration);
}

void NetworkHandler::sendApplicationInstalled(const QString &name)
{
    QString url(QString(MAIN_URL).append("/api/v2/statistics"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject data;
    data.insert("mac", QJsonValue::fromVariant(m_macId));
    data.insert("app", QJsonValue::fromVariant(name));

    QNetworkReply *reply;
    QTimer *timer = new QTimer();
    connect(timer, SIGNAL(timeout()), this, SLOT(onTimeout()));
    timer->setSingleShot(true);
    reply = m_nam.post(request, QJsonDocument(data).toJson());
    timer_put(&m_timerMap, reply, timer);
    timer->start(m_timeoutDuration);
}

void NetworkHandler::surveyCheck()
{
    QUrl url(QString(MAIN_URL).append("/api/v1/survey/list"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject data;
    data.insert("mac",QJsonValue::fromVariant(m_macId));

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
    QUrl url(QString(MAIN_URL).append("/api/v1/survey/join"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject data;
    data.insert("mac",QJsonValue::fromVariant(m_macId));
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
        emit replyError(reply->errorString());
        return;
    }

    auto data = reply->readAll();
    auto doc = QJsonDocument::fromJson(data);

    if (doc.isNull()) {
        emit replyError("Not a json document!");
        return;
    }

    auto obj = doc.object();
    auto status = obj.value("status").toInt(200);
    if (status == 200) {
        auto type = obj.value("response-type").toInt(-1);
        if(type == -1) {
            emit replyError("Unknown response type");
        } else {
            switch (type) {
            case 0:
                parseAppsResponse(obj);
                break;
            case 1:
                parseDetailsResponse(obj);
                break;
            case 2:
                parseSurveyResponse(obj);
                break;
            case 3:
                parseHomeResponse(obj);
                break;
            case 4:
                parseRatingResponse(obj);
                break;
            case 5:
                parseStatisticsResponse(obj);
                break;
            default: qDebug() << "Unhandeled response type: "<< type;
                break;
            }
        }
    } else {
        qDebug() << "Status: " << status <<" Error: "<<  obj.value("error").toString();
        emit replyError("Error from server : " + obj.value("error").toString());
        return;
    }
}

void NetworkHandler::parseAppsResponse(const QJsonObject &obj)
{
    if (obj.keys().contains("app-list")) {
        QJsonArray arr = obj.value("app-list").toArray();
        QList<Application> apps;
        QJsonObject appobj;
        QHash<QString,QString> hash;
        foreach (const QJsonValue &val, arr) {
            appobj = val.toObject();
            Application app(appobj.value("name").toString());
            foreach (const QString &key, appobj.value("category").toObject().keys()) {
                hash.insert(key,appobj.value("category").toObject().value(key).toString());
            }
            app.setCategory(hash);
            hash.clear();
            app.setNonfree(appobj.value("component").toString() == "non-free");
            app.setExec(appobj.value("exec").toString());
            foreach (const QString &key, appobj.value("prettyname").toObject().keys()) {
                hash.insert(key,appobj.value("prettyname").toObject().value(key).toString());
            }
            app.setPrettyname(hash);
            hash.clear();
            app.setRating(appobj.value("rating").toDouble());
            apps.append(app);
        }
        emit appListReceived(apps);
    }
}

void NetworkHandler::parseDetailsResponse(const QJsonObject &obj)
{
    if (obj.keys().contains("details")) {
        QJsonObject content = obj.value("details").toObject();
        if(!content.isEmpty()) {
            ApplicationDetail ad;
            QList<Description> descriptionList;
            QStringList sl;
            QList<Section> sectionList;

            QJsonObject jo = content.value("changelog").toObject();
            foreach (const QVariant var, jo.value("latest").toArray().toVariantList()) {
                sl.append(var.toString());
            }
            ad.setChangelog(Changelog(sl,jo.value("history").toString(),
                                      jo.value("timestamp").toInt()));
            sl.clear();
            ad.setCopyright(content.value("copyright").toString());
            jo = content.value("descriptions").toObject();
            foreach (const QString &lang, jo.keys()) {
                descriptionList.append(Description(lang, jo.value(lang).toString()));
            }
            ad.setDescriptionList(descriptionList);
            ad.setDownload(content.value("download").toInt(0));
            ad.setLicense(content.value("license").toString());
            ad.setMaintainer(content.value("maintainer").toObject().value("mail").toString(),
                             content.value("maintainer").toObject().value("name").toString());
            ad.setName(content.value("name").toString());
            foreach (const QVariant var, content.value("screenshots").toArray().toVariantList()) {
                sl.append(QString(MAIN_URL).append(var.toString()));
            }
            ad.setScreenshots(sl);
            jo = content.value("section").toObject();
            foreach (const QString &lang, jo.keys()) {
                sectionList.append(Section(lang, jo.value(lang).toString()));
            }
            ad.setSections(sectionList);
            ad.setWebsite(content.value("website").toString());
            emit appDetailsReceived(ad);
        }
    }
}

void NetworkHandler::parseRatingResponse(const QJsonObject &obj)
{
    if(obj.keys().contains("rating")) {
        QJsonObject content = obj.value("rating").toObject();
        if(!content.isEmpty()) {
            QList<int> rates;
            for(int i = 0; i < 5; i++) {rates.append(0);}
            double avr = content.value("average").toDouble();
            unsigned int ind = content.value("individual").toInt();
            unsigned int tot = content.value("total").toInt();
            QJsonObject jo = content.value("rates").toObject();
            foreach (const QString &key, jo.keys()) {
                rates[key.toUInt() -1] = jo.value(key).toInt();
            }
            emit appRatingReceived(avr, ind, tot, rates);
        }
    }
}

void NetworkHandler::parseSurveyResponse(const QJsonObject &obj)
{
    if(obj.keys().contains("survey-list")) {
        QStringList sl;
        QJsonObject content = obj.value("survey-list").toObject();
        QJsonArray counts = content["counts"].toArray();
        for(int i=0; i< counts.size();i++) {
            sl.append(counts.at(i).toObject().value("app").toString() + " " +
                      QString::number(counts.at(i).toObject().value("count").toInt()));
        }
        emit surveyListReceived(content.value("individual").toString(), sl);
    } else if(obj.keys().contains("survey-join")) {
        QJsonObject content = obj.value("survey-join").toObject();
        emit surveyJoinResultReceived(content.value("duty").toString(),
                                      content.value("result").toInt());
    }
}

void NetworkHandler::parseHomeResponse(const QJsonObject &obj)
{
    if(obj.keys().contains("home")) {
        QJsonObject content = obj.value("home").toObject();
        QHash<QString,QString> hash;
        QString name, ename, dname, rname;
        QString epname, dpname, rpname;
        unsigned int d, ed, dd, rd;
        double r, er, dr, rr;
        QLocale systemLocale;
        QString locale = systemLocale.name().split("_")[0];

        foreach (const QString &key, content.keys()) {
            QJsonObject jo = content.value(key).toObject();
            if(!jo.isEmpty() && jo.keys().contains("prettyname")) {
                foreach (const QString &subkey, jo.value("prettyname").toObject().keys()) {
                    hash.insert(subkey,jo.value("prettyname").toObject().value(subkey).toString());
                }

                name = jo.value("appname").toString();
                d = jo.value("downloadcount").toInt();
                r = jo.value("rating").toDouble();
                if(key == "editor"){
                    epname = hash.value("en");
                    ename = name;
                    ed = d;
                    er = r;
                }else if(key == "mostdownloaded"){
                    dpname = hash.value("en");
                    dname = name;
                    dd = d;
                    dr = r;
                }else if(key == "mostrated"){
                    rpname = hash.value("en");
                    rname = name;
                    rd = d;
                    rr = r;
                }

                if(hash.keys().contains(locale) && hash.value(locale) != "") {
                    if(key == "editor") epname = hash.value(locale);
                    else if(key == "mostdownloaded") dpname = hash.value(locale);
                    else if(key == "mostrated") rpname = hash.value(locale);
                }
                hash.clear();
            }
        }

        emit homeDetailsReceived(ename,epname,ed,er,dname,dpname,dd,dr,rname,rpname,rd,rr);
    }
}

void NetworkHandler::parseStatisticsResponse(const QJsonObject &obj)
{
    if(obj.keys().contains("statistics")) {
        QJsonObject content = obj.value("statistics").toObject();
        if(!content.isEmpty()) {
            unsigned int count = content.value("count").toInt();
            Q_UNUSED(count);
        }
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


