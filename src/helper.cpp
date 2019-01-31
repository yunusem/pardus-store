#include "helper.h"
#include "application.h"
#include "applicationdetail.h"
#include "filehandler.h"
#include "packagehandler.h"
#include "networkhandler.h"
#include <QLocale>
#include <QProcess>
#include <QRegExp>
#include <QSettings>
#include <QDebug>

#define CONFIG_PATH "/usr/share/pardus/pardus-store/config.ini"

Helper::Helper(QObject *parent) : QObject(parent),
    p(false), m_surveychoice(""), v("beta"), m_corrected(false),
    m_erroronreply(false), m_detailsopened(false),
    m_rating(0), m_homeloaded(true)
{
    s = new QSettings(CONFIG_PATH, QSettings::IniFormat);
    readSettings();

    nh = new NetworkHandler(url(),port(),10000,this);
    fh = new FileHandler(this);
    ph = new PackageHandler(this);

    connect(ph,SIGNAL(finished(int)),this,SLOT(packageProcessFinished(int)));
    connect(ph,SIGNAL(dpkgProgressStatus(QString,QString,int,QString)),this,SLOT(packageProcessStatus(QString,QString,int,QString)));
    connect(nh,SIGNAL(appListReceived(QList<Application>)),this,SLOT(appListReceivedSlot(QList<Application>)));
    connect(nh,SIGNAL(appDetailsReceived(ApplicationDetail)),this,SLOT(appDetailReceivedSlot(ApplicationDetail)));
    connect(nh,SIGNAL(replyError(QString)),this,SIGNAL(replyError(QString)));
    connect(nh,SIGNAL(appRatingReceived(double,uint,uint,QList<int>)),this,SIGNAL(ratingDetailReceived(double,uint,uint,QList<int>)));
    connect(nh,SIGNAL(homeAppListReceived(QList<Application>)),this, SLOT(homeReceivedSlot(QList<Application>)));
    connect(nh,SIGNAL(surveyListReceived(bool,QString,QString,QString,QStringList,uint,bool)),
            this,SLOT(surveyListReceivedSlot(bool,QString,QString,QString,QStringList,uint,bool)));
    connect(nh,SIGNAL(surveyJoinResultReceived(QString,int)),this,SLOT(surveyJoinResultReceivedSlot(QString,int)));
    connect(nh,SIGNAL(surveyDetailReceived(uint,QString,QString,QString)),this,SIGNAL(surveyDetailReceived(uint,QString,QString,QString)));
    connect(fh,SIGNAL(correctingSourcesFinished()),this,SLOT(correctingFinishedSlot()));
    connect(fh,SIGNAL(correctingSourcesFinishedWithError(QString)),this,SIGNAL(correctingFinishedWithError(QString)));
}

Helper::~Helper()
{
    writeSettings("url",m_url);
    writeSettings("port",m_port);
}

bool Helper::animate() const
{
    return m_animate;
}

void Helper::setAnimate(bool a)
{
    if(a != m_animate) {
        m_animate = a;
        writeSettings("animate", m_animate);
        emit animateChanged();
    }
}

bool Helper::update() const
{
    return m_update;
}

void Helper::setUpdate(bool u)
{
    if(u != m_update) {
        m_update = u;
        writeSettings("update", m_update);
        emit updateChanged();
    }
}

unsigned int Helper::ratio() const
{
    return m_ratio;
}

void Helper::setRatio(const unsigned int &r)
{
    if(r != m_ratio ) {
        if(r >= 4) {
            m_ratio = 3;
        } else if (r <= 1) {
            m_ratio = 2;
        } else {
            m_ratio = r;
        }
        writeSettings("ratio", m_ratio);
        emit ratioChanged();
    }
}

bool Helper::usedark() const
{
    return m_usedark;
}

void Helper::setUsedark(bool d)
{
    if( d != m_usedark) {
        m_usedark = d;
        writeSettings("dark-theme", m_usedark);
        emit usedarkChanged();
    }
}

QString Helper::url() const
{
    return m_url;
}

QString Helper::port() const
{
    return m_port;
}

void Helper::setUrl(const QString &u)
{
    if(m_url != u) {
        m_url = u;
        writeSettings("url",m_url);
    }
}

void Helper::setPort(const QString &p)
{
    if(m_port != p) {
        m_port = p;
        writeSettings("port",m_port);
    }
}

void Helper::readSettings()
{
    setAnimate(s->value("animate", true).toBool());
    setUpdate(s->value("update", true).toBool());
    setRatio(s->value("ratio", 3).toUInt());
    setUsedark(s->value("dark-theme", true).toBool());
    setUrl(s->value("url","http://store.pardus.org.tr").toString());
    setPort(s->value("port","5000").toString());
}

void Helper::writeSettings(const QString &key, const QVariant &value)
{    
    s->setValue(key,value);
}

bool Helper::processing() const
{
    return p;
}

QString Helper::surveychoice() const
{
    return m_surveychoice;
}

QString Helper::version() const
{
    return v;
}

bool Helper::corrected() const
{
    return m_corrected;
}

bool Helper::erroronreply() const
{
    return m_erroronreply;
}

bool Helper::detailsopened() const
{
    return m_detailsopened;
}

void Helper::setDetailsopened(bool d)
{
    m_detailsopened = d;
}

unsigned int Helper::rating()
{
    return m_rating;
}

bool Helper::homeLoaded()
{
    return m_homeloaded;
}

QStringList Helper::categorylist() const
{
    return m_categories;
}

void Helper::fillTheList()
{
    for(int i = 0; i < m_fakelist.size(); i++) {
        lc.l->addData(m_fakelist.at(i));
    }
    getHomeScreenDetails();
}

void Helper::updateCache()
{
    ph->updateCache();
}

void Helper::install(const QString &pkg)
{
    p = true;
    QString package = getLanguagePackage(pkg);
    if(package != "") {
        ph->install(package);
    } else {
        ph->install(pkg);
    }
}

void Helper::remove(const QString &pkg)
{
    p = true;
    ph->remove(pkg);
}

bool Helper::terminate()
{
    return ph->terminate();
}

void Helper::getAppList()
{
    nh->getApplicationList();
}

void Helper::getAppDetails(const QString &pkg)
{  
    nh->getApplicationDetails(pkg);
}

void Helper::ratingControl(const QString &name, const unsigned int &rating)
{
    nh->ratingControl(name,rating);
}

void Helper::getHomeScreenDetails()
{
    nh->getHomeDetails();
}

void Helper::surveyCheck()
{
    nh->surveyCheck();
}

void Helper::surveyJoin(const QString &option, const bool sendingForm, const QString &reason, const QString &website, const QString &mail, const QString &explanation)
{
    nh->surveyJoin(option,sendingForm,reason,website,mail,explanation);
}

void Helper::getSurveyDetail(const QString &name)
{
    nh->surveyDetail(name);
}

void Helper::systemNotify(const QString &pkg, const QString &title, const QString &content)
{
    QProcess p;
    QStringList args;
    args << "-u" << "normal";
    args << "-t" << "13000";
    args << "-i" << pkg;
    args << title << content;

    QString command = "/usr/bin/notify-send";
    p.execute(command, args);
}

QString Helper::getMainUrl() const
{
    return nh->getMainUrl();
}

void Helper::correctSourcesList()
{
    fh->correctSources();
}

void Helper::openUrl(const QString &url)
{
    QProcess p1;
    QString user;
    QString out;
    QStringList args;
    p1.start("who");
    p1.waitForFinished(-1);
    out = QString::fromLatin1(p1.readAllStandardOutput());
    p1.close();

    if(out.contains(":0")) {
        QProcess p;
        user = out.split(" ")[0];
        args << "-u" << user << "--";
        args << "xdg-open" << url;
        p.execute("sudo",args);
    }
}

void Helper::runCommand(const QString &cmd)
{
    QProcess p1;
    QString user;
    QString out;
    QStringList args;
    p1.start("who");
    p1.waitForFinished(-1);
    out = QString::fromLatin1(p1.readAllStandardOutput());
    p1.close();

    QString command = cmd;
    if(out.contains(":0")) {
        QProcess p;
        user = out.split(" ")[0];
        args << "-i";
        args << "-u" << user << "--";
        args << command.split(" ");
        p.startDetached("sudo", args);
    }
}

void Helper::sendStatistics(const QString &appname)
{
    nh->sendApplicationInstalled(appname);
}

void Helper::updatePackageInstalledStatus(const QString &pkg, const bool s)
{
    int index = 0;
    for(int i = 0; i< m_fakelist.length(); i++) {
        if(m_fakelist.at(i).name() == pkg) {
            index = i;
        }
    }
    if(!lc.l->setInstallStatusAtIndex(index,s)) {
        qDebug() << "Something went wrong while updating package installed status";
    }
}

QString Helper::getCategoryLocal(const QString &c) const
{
    return m_categorieswithlocal.value(c);
}

void Helper::packageProcessFinished(int code)
{
    if(code == 0) {
        emit processingFinished();
    } else {
        emit processingFinishedWithError(QString::fromLatin1(ph->getError()));
    }

    p = false;
}

void Helper::packageProcessStatus(const QString &status, const QString &pkg, int value, const QString &desc)
{
    Q_UNUSED(pkg);
    Q_UNUSED(desc);
    emit processingStatus(status, value);
}

void Helper:: updateListUsingPackageManager(QList<Application> &list)
{
    QMap<QString,QString> sizeList;
    QString apps;
    for(int i = 0; i < list.size(); i++) {
        sizeList.insert(list.at(i).name(),"");
        apps += list.at(i).name();
        if (i != (list.size() - 1)) {
            apps += " ";
        }
    }

    QStringList output = ph->getPolicy(apps).split(QRegExp("\n|\r\n|\r"));
    QStringList showOutput = ph->getShow(apps).split(QRegExp("\n|\r\n|\r"));

    QString name = "";
    bool nameChanged = false;
    foreach (QString ln, showOutput) {
        if(ln.contains(QRegExp("^Package"))) {
            if(ln.mid(9) != name) {
                name = ln.mid(9);
                nameChanged = true;
            } else {
                nameChanged = false;
            }
        } else if(ln.contains(QRegExp("^Size"))) {
            if(nameChanged) {
                double size = ln.mid(6).toDouble() / 1024.0;

                if(size > 1024) {
                    size = size / 1024.0;
                    ln = QString(QString::number(size,'f',1) + " MB");
                } else {
                    ln = QString(QString::number(size,'f',1) + " KB");
                }
                sizeList.insert(name,ln);
            }
        }
    }


    int ix = 0;
    QString checkInstalled;

    for(int i = 0; i< list.size(); i++) {
        ix = output.indexOf(QRegExp(list[i].name() + QString("*.*")));
        checkInstalled = output.at(ix + 1).split(" ").last();
        if (checkInstalled.contains("none")) {
            list[i].setInstalled(false);
            list[i].setState("get");
        } else {
            list[i].setInstalled(true);
            list[i].setState("installed");
        }
        list[i].setVersion(output.at(ix + 2).split(" ").last());
        list[i].setDownloadsize(sizeList.value(list[i].name()));
    }
}

QString Helper::getLanguagePackage(const QString &pkg) const
{
    QStringList l = ph->getSearch(pkg).split("\n");
    QString lang = QLocale::system().name();
    QString langMajor = lang.split("_")[0];
    QString langMinor = lang.split("_")[1];

    QStringList pl;
    QString result = "";

    foreach (QString str, l) {
        if(str.contains("language")) {
            pl.append(str.split(" - ")[0]);
        }
    }
    if(pl.size() > 1) {
        foreach (QString s, pl) {
            if(langMajor.toLower() == lang.toLower()) {
                if (s.contains(langMajor, Qt::CaseInsensitive)) {
                    result = s;
                }
            } else {
                if (s.contains(langMajor, Qt::CaseInsensitive) &&
                        s.contains(langMinor, Qt::CaseInsensitive)) {
                    result = s;
                }
            }
        }
    } else if(pl.size() == 1) {
        result = pl[0];
    }

    return result;
}

void Helper::appDetailReceivedSlot(const ApplicationDetail &ad)
{
    emit detailsReceived(ad.changelogLatest(), ad.changelogHistory(), ad.changelogTimestamp(),
                         ad.copyright(), ad.description(),ad.download(),ad.license(),
                         ad.maintainerMail(),ad.maintainerName(),ad.screenshots(),
                         ad.section(),ad.website());
    emit descriptionReceived(ad.description());
}

void Helper::getSelfVersion()
{
    QStringList output = ph->getPolicy("pardus-store").split(QRegExp("\n|\r\n|\r"));
    int ix = output.indexOf(QRegExp("pardus-store" + QString("*.*")));
    QString installed = output.at(ix + 1).split(" ").last();
    if(!installed.contains("none")) {
        v = installed;
        emit versionChanged();
    }
}

void Helper::appListReceivedSlot(const QList<Application> &apps)
{
    m_fakelist = apps;
    for(int i = 0; i< m_fakelist.length(); i++) {
        if(!m_categories.contains(m_fakelist[i].category()) && m_fakelist[i].category() != "") {
            m_categories.append(m_fakelist[i].category());
            m_categorieswithlocal.insert(m_fakelist[i].category(),m_fakelist[i].categoryLocal());
        }
    }
    m_categories.sort();
    if(m_categories.contains("others")) {
        m_categories.removeAt(m_categories.indexOf("others"));
        m_categories.append("others");
    }
    emit categorylistChanged();
    updateListUsingPackageManager(m_fakelist);
    emit fetchingAppListFinished();
    getSelfVersion();
    fillTheList();
}

void Helper::homeReceivedSlot(const QList<Application> &apps)
{
    m_homelist = apps;
    updateListUsingPackageManager(m_homelist);
    emit homeReceived(m_homelist[0].name(), m_homelist[0].prettyname(), m_homelist[0].category(), m_homelist[0].exec(),
            m_homelist[0].installed(), m_homelist[0].downloadcount(), m_homelist[0].rating(), m_homelist[0].version(),
            m_homelist[0].downloadsize(),m_homelist[0].nonfree(),
            m_homelist[1].name(), m_homelist[1].prettyname(), m_homelist[1].category(), m_homelist[1].exec(),
            m_homelist[1].installed(), m_homelist[1].downloadcount(), m_homelist[1].rating(), m_homelist[1].version(),
            m_homelist[1].downloadsize(), m_homelist[1].nonfree(),
            m_homelist[2].name(), m_homelist[2].prettyname(), m_homelist[2].category(), m_homelist[2].exec(),
            m_homelist[2].installed(), m_homelist[2].downloadcount(), m_homelist[2].rating(), m_homelist[2].version(),
            m_homelist[2].downloadsize(), m_homelist[2].nonfree());
    emit gatheringLocalDetailFinished();
}

void Helper::surveyListReceivedSlot(const bool isForm, const QString &title,
                                    const QString &question, const QString &mychoice,
                                    const QStringList &choices, const unsigned int &timestamp,
                                    const bool pending)
{    
    m_surveychoice = mychoice;
    emit surveychoiceChanged();
    emit surveyListReceived(isForm,title,question,choices,timestamp,pending);
}

void Helper::surveyJoinResultReceivedSlot(const QString &duty, const int &result)
{    
    if (result == 1) {
        emit surveyJoinSuccess();
    } else {
        qDebug() << "Survey join result is " << result << " duty is " << duty;
    }
}

void Helper::correctingFinishedSlot()
{
    m_corrected = true;
    emit correctingFinished();
}
