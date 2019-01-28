#ifndef HELPER_H
#define HELPER_H

#include <QObject>
#include <QHash>
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
               NOTIFY gatheringLocalDetailFinished)
    Q_PROPERTY(QString surveychoice
               READ surveychoice
               NOTIFY surveychoiceChanged
               NOTIFY surveyListReceived
               NOTIFY surveyJoinSuccess)
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
    Q_PROPERTY(bool usedark
               READ usedark
               WRITE setUsedark
               NOTIFY usedarkChanged)
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
    Q_PROPERTY(unsigned int rating
               READ rating
               NOTIFY ratingDetailReceived)
    Q_PROPERTY(bool homeLoaded
               READ homeLoaded
               NOTIFY homeReceived)
    Q_PROPERTY(QStringList categorylist READ categorylist NOTIFY categorylistChanged)

public:
    explicit Helper(QObject *parent = 0);
    ~Helper();
    bool processing() const;
    bool animate() const;
    void setAnimate(bool a);
    bool update() const;
    void setUpdate(bool u);
    unsigned int ratio() const;
    void setRatio(const unsigned int &r);
    bool usedark() const;
    void setUsedark(bool d);
    QString url() const;
    QString port() const;
    void setUrl(const QString &u);
    void setPort(const QString &p);
    QString surveychoice() const;
    QString version() const;
    bool corrected() const;
    bool erroronreply() const;
    bool detailsopened () const;
    void setDetailsopened(bool d);
    unsigned int rating();
    bool homeLoaded();
    QStringList categorylist() const;

    Q_INVOKABLE void updateCache();
    Q_INVOKABLE void install(const QString &pkg);
    Q_INVOKABLE void remove(const QString &pkg);
    Q_INVOKABLE bool terminate();
    Q_INVOKABLE void getAppList();
    Q_INVOKABLE void getAppDetails(const QString &pkg);
    Q_INVOKABLE void ratingControl(const QString &name, const unsigned int &rating = 0);
    Q_INVOKABLE void getHomeScreenDetails();
    Q_INVOKABLE void surveyCheck();
    Q_INVOKABLE void surveyJoin(const QString &option, const bool sendingForm, const QString &reason = "",
                                const QString &website = "", const QString &mail = "",
                                const QString &explanation = "");
    Q_INVOKABLE void getSurveyDetail(const QString &name);
    Q_INVOKABLE void systemNotify(const QString &pkg,
                                  const QString &title,
                                  const QString &content);
    Q_INVOKABLE QString getMainUrl() const;
    Q_INVOKABLE void correctSourcesList();
    Q_INVOKABLE void openUrl(const QString &url);
    Q_INVOKABLE void runCommand(const QString &cmd);
    Q_INVOKABLE void sendStatistics(const QString &appname);
    Q_INVOKABLE QString getCategoryLocal(const QString &c) const;

private:
    bool p;
    QString m_surveychoice;
    QString v;
    bool m_corrected;
    bool m_erroronreply;
    bool m_detailsopened;
    unsigned int m_rating;
    bool m_homeloaded;
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
    bool m_usedark;
    QString m_url;
    QString m_port;
    void readSettings();
    QStringList m_categories;
    QHash<QString,QString> m_categorieswithlocal;

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
    void descriptionReceived(const QString &description);
    void surveychoiceChanged();
    void versionChanged();
    void surveyListReceived(const bool isform, const QString &title,
                            const QString &question, const QStringList &choices,
                            const unsigned int &timestamp, const bool pending);
    void surveyJoinSuccess();    
    void screenshotNotFound();
    void fetchingAppListFinished();
    void gatheringLocalDetailFinished();
    void animateChanged();
    void updateChanged();
    void ratioChanged();
    void usedarkChanged();
    void correctingFinished();
    void correctingFinishedWithError(const QString &errorString);
    void replyError(const QString &errorString);
    void detailsReceived(const QStringList &changeloglatest, const QString &changeloghistory,
                         const unsigned int &timestamp, const QString &copyright,
                         const QString &description,
                         const unsigned int &download, const QString &license,
                         const QString &mmail, const QString &mname, const QStringList &screenshots,
                         const QString &section, const QString &website);
    void ratingDetailReceived(const double &average,
                              const unsigned int &individual,
                              const unsigned int &total,
                              const QList<int> &rates);
    void surveyDetailReceived(const unsigned int &count, const QString &reason,
                              const QString &website, const QString &explanation);
    void homeReceived(const QString &ename, const QString &epname, const unsigned int &ecount, const double &erating,
                      const QString &dname, const QString &dpname, const unsigned int &dcount, const double &drating,
                      const QString &rname, const QString &rpname, const unsigned int &rcount, const double &rrating);
    void categorylistChanged();

public slots:    
    void appDetailReceivedSlot(const ApplicationDetail &ad);
    void appListReceivedSlot(const QList<Application> &apps);
    void surveyListReceivedSlot(const bool isForm, const QString &title,
                                const QString &question, const QString &mychoice,
                                const QStringList &choices, const unsigned int &timestamp,
                                const bool pending);
    void surveyJoinResultReceivedSlot(const QString &duty, const int &result);
    void correctingFinishedSlot();
};

#endif // HELPER_H
