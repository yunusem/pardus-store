#ifndef NETWORKHANDLER_H
#define NETWORKHANDLER_H

#include <QObject>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <map>

class QNetworkReply;
class QTimer;
class QStringList;
class ApplicationDetail;
class Application;

class NetworkHandler : public QObject
{
    Q_OBJECT
public:
    explicit NetworkHandler(int msec = 10000, QObject *parent = 0);

    void getApplicationList();    
    void getApplicationDetails(const QString &packageName);
    void ratingControl(const QString &name, const unsigned int &rating);
    void getHomeDetails();
    void sendApplicationInstalled(const QString &name);
    void surveyCheck();
    void surveyJoin(const QString &appName, const QString &duty);
    QString getMainUrl() const;

signals:
    void appListReceived(const QList<Application> &apps);
    void appDetailsReceived(const ApplicationDetail &ad);
    void appRatingReceived(const double &average,
                           const unsigned int &individual,
                           const unsigned int &total,
                           const QList<int> &rates);
    void homeDetailsReceived(const QString &ename, const QString &epname, const unsigned int &ecount, const double &erating,
                             const QString &dname, const QString &dpname, const unsigned int &dcount, const double &drating,
                             const QString &rname, const QString &rpname, const unsigned int &rcount, const double &rrating);

    void surveyListReceived(const QString &mySelection, const QStringList &sl);
    void surveyJoinResultReceived(const QString &duty, const int &result);
    void replyError(const QString &error);

private slots:
    void replyFinished(QNetworkReply *);
    void onTimeout();

private:
    QNetworkAccessManager m_nam;
    std::map<QNetworkReply *, QTimer *> m_timerMap;
    int m_timeoutDuration;
    QString m_macId;
    void parseAppsResponse(const QJsonObject &obj);
    void parseDetailsResponse(const QJsonObject &obj);    
    void parseSurveyResponse(const QJsonObject &obj);
    void parseHomeResponse(const QJsonObject &obj);
    void parseRatingResponse(const QJsonObject &obj);
    void parseStatisticsResponse(const QJsonObject &obj);

};

#endif // NETWORKHANDLER_H
