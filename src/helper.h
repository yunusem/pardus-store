#ifndef HELPER_H
#define HELPER_H

#include <QObject>
#include <QStringList>
#include <QString>
#include <QVariant>
#include "applicationlistmodel.h"

class FileHandler;
class PackageHandler;
class NetworkHandler;
class ApplicationDetail;

class Helper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool processing
               READ processing               
               NOTIFY processingFinished
               NOTIFY processingFinishedWithError
               NOTIFY descriptionReceived
               NOTIFY screenshotReceived
               NOTIFY screenshotNotFound
               NOTIFY fetchingAppListFinished
               NOTIFY gatheringLocalDetailFinished)
public:
    explicit Helper(QObject *parent = 0);
    bool processing() const;

    Q_INVOKABLE void updateCache();
    Q_INVOKABLE void install(const QString &pkg);
    Q_INVOKABLE void remove(const QString &pkg);
    Q_INVOKABLE void getAppList();
    Q_INVOKABLE void getAppDetails(const QString &pkg);
    Q_INVOKABLE void systemNotify(const QString &pkg,
                                  const QString &title,
                                  const QString &content);
private:
    bool p;
    FileHandler *fh;
    PackageHandler *ph;
    QStringList l;
    QStringList ldetail;
    ListCover lc;
    NetworkHandler *nh;
    void fillTheList();

private slots:
    void packageProcessFinished(int code);
    QStringList getDetails() const;
    void updateDetails();

signals:
    void processingFinished();
    void processingFinishedWithError(const QString &output);
    void screenshotReceived(const QStringList &urls);
    void descriptionReceived(const QString &description);
    void screenshotNotFound();
    void fetchingAppListFinished();
    void gatheringLocalDetailFinished();

public slots:
    void appDetailReceivedSlot(const ApplicationDetail &ad);
    void appListReceivedSlot(const QStringList &list);
};

#endif // HELPER_H
