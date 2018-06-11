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
               NOTIFY processingStatus
               NOTIFY descriptionReceived
               NOTIFY screenshotReceived
               NOTIFY screenshotNotFound
               NOTIFY fetchingAppListFinished
               NOTIFY gatheringLocalDetailFinished
               NOTIFY surveyListReceived
               NOTIFY surveyJoinSuccess
               NOTIFY surveyJoinUpdateSuccess)
    Q_PROPERTY(QString choice
               READ choice
               NOTIFY choiceChanged)
    Q_PROPERTY(bool animate
               READ animate
               WRITE setAnimate
               NOTIFY animateChanged)
    Q_PROPERTY(bool update
               READ update
               WRITE setUpdate
               NOTIFY updateChanged)
public:
    explicit Helper(QObject *parent = 0);
    bool processing() const;
    bool animate() const;
    void setAnimate(bool a);
    bool update() const;
    void setUpdate(bool u);
    QString choice() const;
    Q_INVOKABLE void updateCache();
    Q_INVOKABLE void install(const QString &pkg);
    Q_INVOKABLE void remove(const QString &pkg);
    Q_INVOKABLE void getAppList();
    Q_INVOKABLE void getAppDetails(const QString &pkg);
    Q_INVOKABLE void surveyCheck();
    Q_INVOKABLE void surveyJoin(const QString &appName, const QString &duty);
    Q_INVOKABLE void systemNotify(const QString &pkg,
                                  const QString &title,
                                  const QString &content);
    Q_INVOKABLE QString getMainUrl() const;


private:
    bool p;
    QString c;
    FileHandler *fh;
    PackageHandler *ph;
    QStringList l;
    QStringList ldetail;
    ListCover lc;
    NetworkHandler *nh;
    void fillTheList();
    bool m_animate;
    bool m_update;
    void readSettings();

private slots:
    void packageProcessFinished(int code);
    void packageProcessStatus(const QString &status, const QString &pkg,
                              int value, const QString &desc);
    QStringList getDetails() const;    
    QString getLanguagePackage(const QString &pkg) const;
    void writeSettings(const QString &key, const QVariant &value);

signals:
    void processingFinished();
    void processingFinishedWithError(const QString &output);
    void processingStatus(const QString &condition, int percent);
    void screenshotReceived(const QStringList &urls);
    void descriptionReceived(const QString &description);
    void choiceChanged();
    void surveyListReceived(const QStringList &list);
    void surveyJoinSuccess();
    void surveyJoinUpdateSuccess();
    void screenshotNotFound();
    void fetchingAppListFinished();
    void gatheringLocalDetailFinished();
    void animateChanged();
    void updateChanged();

public slots:    
    void appDetailReceivedSlot(const ApplicationDetail &ad);
    void appListReceivedSlot(const QStringList &list);
    void surveyListReceivedSlot(const QString &mySelection, const QStringList &sl);
    void surveyJoinResultReceived(const QString &duty, const int &result);
};

#endif // HELPER_H
