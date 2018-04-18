#ifndef HELPER_H
#define HELPER_H

#include <QObject>
#include <QStringList>
#include <QString>
#include <QVariant>
#include "applicationlistmodel.h"

class FileHandler;
class PackageHandler;
class Artwork;
class ScreenshotInfo;

class Helper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool processing
               READ processing
               NOTIFY processingFinished
               NOTIFY processingFinishedWithError
               NOTIFY screenshotReceived
               NOTIFY screenshotNotFound)
public:
    explicit Helper(QObject *parent = 0);
    bool processing() const;

    Q_INVOKABLE void install(const QString &pkg);
    Q_INVOKABLE void remove(const QString &pkg);
    Q_INVOKABLE void getScreenShot(const QString &pkg);
private:
    bool p;
    FileHandler *fh;
    PackageHandler *ph;
    QStringList l;
    QStringList ldetail;
    ListCover lc;
    Artwork *a;
    void fillTheList();

private slots:
    void packageProcessFinished(int code);
    QStringList getDetails() const;
    void updateDetails();

signals:
    void processingFinished();
    void processingFinishedWithError(const QString &output);
    void screenshotReceived(const QStringList &urls);
    void screenshotNotFound();

public slots:
    void screenshotReceivedSlot(const ScreenshotInfo &info);
};

#endif // HELPER_H
