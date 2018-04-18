#ifndef ARTWORK_H_TGDM3NUJ
#define ARTWORK_H_TGDM3NUJ

#include <QObject>
#include <QNetworkAccessManager>
#include <map>

class QNetworkReply;
class QTimer;
class ScreenshotInfo;

class Artwork : public QObject
{
    Q_OBJECT
public:
    Artwork (int msec, QObject *parent = 0);

    void get(const QString &packageName);

signals:
    void screenshotReceived(const ScreenshotInfo &screenshot);
    void screenshotNotFound();

private slots:
    void replyFinished(QNetworkReply *);
    void onTimeout();

private:
    QNetworkAccessManager m_nam;
    std::map<QNetworkReply *, QTimer *> m_timerMap;
    int m_timeoutDuration;
};

#endif /* end of include guard: ARTWORK_H_TGDM3NUJ */
