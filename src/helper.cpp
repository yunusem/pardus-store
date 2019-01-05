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

Helper::Helper(QObject *parent) : QObject(parent), p(false), c(""), v("beta"), m_corrected(false)
{
    s = new QSettings(CONFIG_PATH, QSettings::IniFormat);
    readSettings();

    nh = new NetworkHandler(10000,this);
    fh = new FileHandler(this);
    ph = new PackageHandler(this);

    connect(ph,SIGNAL(finished(int)),this,SLOT(packageProcessFinished(int)));
    connect(ph,SIGNAL(dpkgProgressStatus(QString,QString,int,QString)),this,SLOT(packageProcessStatus(QString,QString,int,QString)));
    connect(nh,SIGNAL(appListReceived(QList<Application>)),this,SLOT(appListReceivedSlot(QList<Application>)));
    connect(nh,SIGNAL(appDetailsReceived(ApplicationDetail)),this,SLOT(appDetailReceivedSlot(ApplicationDetail)));
    connect(nh,SIGNAL(notFound()),this,SIGNAL(screenshotNotFound()));
    connect(nh,SIGNAL(surveyListReceived(QString,QStringList)),this,SLOT(surveyListReceivedSlot(QString,QStringList)));
    connect(nh,SIGNAL(surveyJoinResultReceived(QString,int)),this,SLOT(surveyJoinResultReceived(QString,int)));
    connect(fh,SIGNAL(correctingSourcesFinished()),this,SLOT(correctingFinishedSlot()));
    connect(fh,SIGNAL(correctingSourcesFinishedWithError(QString)),this,SIGNAL(correctingFinishedWithError(QString)));
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

void Helper::readSettings()
{
    setAnimate(s->value("animate", true).toBool());
    setUpdate(s->value("update", true).toBool());
    setRatio(s->value("ratio", 3).toUInt());
}

void Helper::writeSettings(const QString &key, const QVariant &value)
{    
    s->setValue(key,value);
}

bool Helper::processing() const
{
    return p;
}

QString Helper::choice() const
{
    return c;
}

QString Helper::version() const
{
    return v;
}

bool Helper::corrected() const
{
    return m_corrected;
}

void Helper::fillTheList()
{
    for(int i = 0; i < m_fakelist.size(); i++) {
        lc.l->addData(m_fakelist.at(i));
    }
    emit gatheringLocalDetailFinished();
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

void Helper::surveyCheck()
{
    nh->surveyCheck();
}

void Helper::surveyJoin(const QString &appName, const QString &duty)
{
    nh->surveyJoin(appName, duty);
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

void Helper::updateListUsingPackageManager()
{
    QMap<QString,QString> sizeList;
    QString apps;
    for(int i = 0; i < m_fakelist.size(); i++) {
        sizeList.insert(m_fakelist.at(i).name(),"");
        apps += m_fakelist.at(i).name();
        if (i != (m_fakelist.size() - 1)) {
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

    for(int i = 0; i< m_fakelist.size(); i++) {
        ix = output.indexOf(QRegExp(m_fakelist[i].name() + QString("*.*")));
        checkInstalled = output.at(ix + 1).split(" ").last();
        if (checkInstalled.contains("none")) {
            m_fakelist[i].setInstalled(false);
            m_fakelist[i].setState("get");
        } else {
            m_fakelist[i].setInstalled(true);
            m_fakelist[i].setState("installed");
        }
        m_fakelist[i].setVersion(output.at(ix + 2).split(" ").last());
        m_fakelist[i].setDownloadsize(sizeList.value(m_fakelist[i].name()));
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
    emit descriptionReceived(ad.description());
    emit screenshotReceived(ad.screenshots());
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
    emit fetchingAppListFinished();
    this->updateListUsingPackageManager();
    this->getSelfVersion();
    this->fillTheList();
}

void Helper::surveyListReceivedSlot(const QString &mySelection, const QStringList &sl)
{
    c = mySelection;
    emit choiceChanged();
    emit surveyListReceived(sl);
}

void Helper::surveyJoinResultReceived(const QString &duty, const int &result)
{
    if (result == 1) {
        if(duty == "update") {
            emit surveyJoinUpdateSuccess();
        } else if(duty == "join") {
            emit surveyJoinSuccess();
        }
    } else {
        qDebug() << "Survey join result is " << result;
    }
}

void Helper::correctingFinishedSlot()
{
    m_corrected = true;
    emit correctingFinished();
}
