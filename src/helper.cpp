#include "helper.h"
#include "filehandler.h"
#include "packagehandler.h"
#include "networkhandler.h"
#include "applicationdetail.h"
#include <QLocale>
#include <QProcess>
#include <QRegExp>
#include <QSettings>
#include <QDebug>

#define CONFIG_PATH "/usr/share/pardus/pardus-store/config.ini"

Helper::Helper(QObject *parent) : QObject(parent), p(false), c(""), v("alpha")
{    
    nh = new NetworkHandler(10000,this);
    fh = new FileHandler(this);
    ph = new PackageHandler(this);
    s = new QSettings(CONFIG_PATH, QSettings::IniFormat);

    connect(ph,SIGNAL(finished(int)),this,SLOT(packageProcessFinished(int)));
    connect(ph,SIGNAL(dpkgProgressStatus(QString,QString,int,QString)),this,SLOT(packageProcessStatus(QString,QString,int,QString)));
    connect(nh,SIGNAL(appListReceived(QStringList)),this,SLOT(appListReceivedSlot(QStringList)));
    connect(nh,SIGNAL(appDetailsReceived(ApplicationDetail)),this,SLOT(appDetailReceivedSlot(ApplicationDetail)));
    connect(nh,SIGNAL(notFound()),this,SIGNAL(screenshotNotFound()));
    connect(nh,SIGNAL(surveyListReceived(QString,QStringList)),this,SLOT(surveyListReceivedSlot(QString,QStringList)));
    connect(nh,SIGNAL(surveyJoinResultReceived(QString,int)),this,SLOT(surveyJoinResultReceived(QString,int)));

    readSettings();
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
    if(r != m_ratio && r < 6 && r > 2) {
      m_ratio = r;
      writeSettings("ratio", m_ratio);
      emit ratioChanged();
    }
}

void Helper::readSettings()
{
    setAnimate(s->value("animate", true).toBool());
    setUpdate(s->value("update", false).toBool());
    setRatio(s->value("ratio", 5).toUInt());
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

void Helper::fillTheList()
{    
    QStringList list;
    for(int i = 0; i < l.length(); i++) {
        list.append(l.at(i) + " " + ldetail.at(i));
    }

    QString line = "";
    QString name = "";
    QString version = "";
    QString dsize = "";
    bool stat = false;
    QString category = "";
    bool non_free = false;
    foreach(line, list) {
        QStringList params = line.split(" ");
        name = params[0];
        category = params[1];
        version = params[2];
        if (params[3] == "yes") {
            stat = true;
        } else {
            stat = false;
        }
        if (params[4] == "yes") {
            non_free = true;
        } else {
            non_free = false;
        }
        dsize = params[5] + " " + params[6];
        lc.l->addData(Application(name,version,dsize,stat,false,category,non_free));
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

QStringList Helper::getDetails() const
{
    QString apps;
    for(int i = 0; i < l.length(); i++) {
        apps += (l[i].split(" ").at(0));
        if (i != (l.length() - 1)) {
            apps += " ";
        }
    }

    QStringList output = ph->getPolicy(apps).split(QRegExp("\n|\r\n|\r"));
    QStringList showOutput = ph->getShow(apps).split(QRegExp("\n|\r\n|\r"));
    QStringList sizeList;
    QString name = "";
    bool nameChanged = false;
    foreach (QString ln, showOutput) {
        if(ln.contains(QRegExp("^Package"))) {
            if(ln != name) {
                name = ln;
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

                sizeList.append(ln);
            }
        }
    }

    QStringList list;
    int ix = 0;
    QString app;
    QString detail;
    QString version;
    QString installed;
    QString non_free;
    unsigned int cnt = 0;
    foreach (QString line, l) {
        app = line.split(" ").at(0);
        ix = output.indexOf(QRegExp(app + QString("*.*")));
        installed = output.at(ix + 1).split(" ").last();
        if (output.at(ix+5).indexOf("non-free") != -1) {
            non_free = "yes";
        } else {
            non_free = "no";
        }
        if (installed.contains("none")) {
            installed = "no";
        } else {
            installed = "yes";
        }

        version = output.at(ix + 2).split(" ").last();
        detail += version + " ";
        detail += installed + " ";
        detail += non_free + " ";
        detail += sizeList.at(cnt);
        list.append(detail);
        detail = "";
        cnt++;
    }
    return list;
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
    QLocale locale;
    QString storeLocale = locale.name().split("_")[0];
    QString l;
    QString d;
    for(int i=0; i< ad.descriptions().size(); i++) {
        l = ad.descriptions().at(i).language();
        if (l == "en") {
            d = ad.descriptions().at(i).description();
        } else if (l == storeLocale) {
            if(ad.descriptions().at(i).description() != "") {
                d = ad.descriptions().at(i).description();
            }
        }

    }
    emit descriptionReceived(d);
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

void Helper::appListReceivedSlot(const QStringList &list)
{
    l = list;
    emit fetchingAppListFinished();
    ldetail = this->getDetails();
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
