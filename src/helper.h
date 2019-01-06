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
class QSettings;

class Helper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool processing
               READ processing
               NOTIFY processingFinished
               NOTIFY processingFinishedWithError
               NOTIFY processingStatus
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
    Q_PROPERTY(unsigned int ratio
               READ ratio
               WRITE setRatio
               NOTIFY ratioChanged)
    Q_PROPERTY(QString version
               READ version
               NOTIFY versionChanged)
    Q_PROPERTY(bool corrected
               READ corrected
               NOTIFY correctingFinished
               NOTIFY correctingFinishedWithError)
    Q_PROPERTY(bool erroronreply
               READ erroronreply
               NOTIFY replyError)
    Q_PROPERTY(bool detailsopened
               READ detailsopened
               WRITE setDetailsopened
               NOTIFY detailsReceived)
public:
    explicit Helper(QObject *parent = 0);
    bool processing() const;
    bool animate() const;
    void setAnimate(bool a);
    bool update() const;
    void setUpdate(bool u);
    unsigned int ratio() const;
    void setRatio(const unsigned int &r);
    QString choice() const;
    QString version() const;
    bool corrected() const;
    bool erroronreply() const;
    bool detailsopened () const;
    void setDetailsopened(bool d);

    Q_INVOKABLE void updateCache();
    Q_INVOKABLE void install(const QString &pkg);
    Q_INVOKABLE void remove(const QString &pkg);
    Q_INVOKABLE bool terminate();
    Q_INVOKABLE void getAppList();
    Q_INVOKABLE void getAppDetails(const QString &pkg);
    Q_INVOKABLE void surveyCheck();
    Q_INVOKABLE void surveyJoin(const QString &appName, const QString &duty);
    Q_INVOKABLE void systemNotify(const QString &pkg,
                                  const QString &title,
                                  const QString &content);
    Q_INVOKABLE QString getMainUrl() const;
    Q_INVOKABLE void correctSourcesList();
    Q_INVOKABLE void openUrl(const QString &url);
    Q_INVOKABLE void runCommand(const QString &cmd);


private:
    bool p;
    QString c;
    QString v;
    bool m_corrected;
    bool m_erroronreply;
    bool m_detailsopened;
    FileHandler *fh;
    PackageHandler *ph;
    QList<Application> m_fakelist;
    ListCover lc;
    NetworkHandler *nh;
    QSettings *s;
    void fillTheList();
    bool m_animate;
    bool m_update;
    unsigned int m_ratio;
    void readSettings();

private slots:
    void packageProcessFinished(int code);
    void packageProcessStatus(const QString &status, const QString &pkg,
                              int value, const QString &desc);
    void updateListUsingPackageManager();
    QString getLanguagePackage(const QString &pkg) const;
    void writeSettings(const QString &key, const QVariant &value);
    void getSelfVersion();

signals:
    void processingFinished();
    void processingFinishedWithError(const QString &output);
    void processingStatus(const QString &condition, int percent);
    void screenshotReceived(const QStringList &urls);
    void descriptionReceived(const QString &description);
    void choiceChanged();
    void versionChanged();
    void surveyListReceived(const QStringList &list);
    void surveyJoinSuccess();
    void surveyJoinUpdateSuccess();
    void screenshotNotFound();
    void fetchingAppListFinished();
    void gatheringLocalDetailFinished();
    void animateChanged();
    void updateChanged();
    void ratioChanged();
    void correctingFinished();
    void correctingFinishedWithError(const QString &errorString);
    void replyError(const QString &errorString);
    void detailsReceived(const QString &changelog, const QString &description,
                         const unsigned int &download, const QString &license,
                         const QString &mmail, const QString &mname,
                         const QStringList &screenshots, const QString &section,
                         const QString &website);

public slots:    
    void appDetailReceivedSlot(const ApplicationDetail &ad);
    void appListReceivedSlot(const QList<Application> &apps);
    void surveyListReceivedSlot(const QString &mySelection, const QStringList &sl);
    void surveyJoinResultReceivedSlot(const QString &duty, const int &result);
    void correctingFinishedSlot();
};

#endif // HELPER_H
