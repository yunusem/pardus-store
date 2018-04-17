#ifndef ARTWORK_H_TGDM3NUJ
#define ARTWORK_H_TGDM3NUJ

#include <QObject>
#include <QNetworkAccessManager>

class QNetworkReply;
class ScreenshotInfo;

class Artwork : public QObject
{
    Q_OBJECT
public:
    Artwork (QObject *parent = 0);

    void get(const QString &packageName);

signals:
    void screenshotReceived(const ScreenshotInfo &screenshot);
    void screenshotNotFound();

private slots:
    void replyFinished(QNetworkReply *);

private:
    QNetworkAccessManager m_nam;
};

#endif /* end of include guard: ARTWORK_H_TGDM3NUJ */
