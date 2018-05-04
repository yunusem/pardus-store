#ifndef NETWORKHANDLER_H
#define NETWORKHANDLER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <map>

class QNetworkReply;
class QTimer;
class QStringList;
class ApplicationDetail;

class NetworkHandler : public QObject
{
    Q_OBJECT
public:
    explicit NetworkHandler(int msec = 10000, QObject *parent = 0);

    void getApplicationList();
    void getApplicationDetails(const QString &packageName);
    void surveyCheck();
    void surveyJoin(const QString &appName, const QString &duty);

signals:
    void appListReceived(const QStringList &al);
    void appDetailsReceived(const ApplicationDetail &ad);
    void surveyListReceived(const QString &mySelection, const QStringList &sl);
    void surveyJoinResultReceived(const QString &duty, const int &result);
    void notFound();

private slots:
    void replyFinished(QNetworkReply *);
    void onTimeout();

private:
    QNetworkAccessManager m_nam;
    std::map<QNetworkReply *, QTimer *> m_timerMap;
    int m_timeoutDuration;
};

#endif // NETWORKHANDLER_H
