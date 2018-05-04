#include "helper.h"
#include "filehandler.h"
#include "packagehandler.h"
#include "networkhandler.h"
#include "applicationdetail.h"
#include <QLocale>
#include <QProcess>
#include <QRegExp>
#include <QDebug>

Helper::Helper(QObject *parent) : QObject(parent), p(false), c("")
{    
    nh = new NetworkHandler(10000,this);
    fh = new FileHandler(this);
    ph = new PackageHandler(this);    

    connect(ph,SIGNAL(finished(int)),this,SLOT(packageProcessFinished(int)));
    connect(nh,SIGNAL(appListReceived(QStringList)),this,SLOT(appListReceivedSlot(QStringList)));
    connect(nh,SIGNAL(appDetailsReceived(ApplicationDetail)),this,SLOT(appDetailReceivedSlot(ApplicationDetail)));
    connect(nh,SIGNAL(notFound()),this,SIGNAL(screenshotNotFound()));
    connect(nh,SIGNAL(surveyListReceived(QString,QStringList)),this,SLOT(surveyListReceivedSlot(QString,QStringList)));
    connect(nh,SIGNAL(surveyJoinResultReceived(QString,int)),this,SLOT(surveyJoinResultReceived(QString,int)));
}

bool Helper::processing() const
{
    return p;
}

QString Helper::choice() const
{
    return c;
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
    bool stat = false;
    QString category = "";
    bool non_free = false;
    foreach(line, list) {
        name = line.split(" ")[0];
        category = line.split(" ")[1];
        version = line.split(" ")[2];
        if (line.split(" ")[3] == "yes") {
            stat = true;
        } else {
            stat = false;
        }
        if (line.split(" ")[4] == "yes") {
            non_free = true;
        } else {
            non_free = false;
        }
        lc.l->addData(Application(name,version,stat,false,category,non_free));
    }
    emit gatheringLocalDetailFinished();
}

void Helper::updateCache()
{
    ph->updateCache();
}

void Helper::install(const QString &pkg)
{

    ph->install(pkg);
    p = true;
}

void Helper::remove(const QString &pkg)
{

    ph->remove(pkg);
    p = true;
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

void Helper::packageProcessFinished(int code)
{
    if(code == 0) {                
        emit processingFinished();
    } else {        
        emit processingFinishedWithError(QString::fromLatin1(ph->getError()));
    }

    p = false;
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
    QStringList list;
    int ix = 0;
    QString app;
    QString detail;
    QString version;
    QString installed;
    QString non_free;
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
        detail += non_free;
        list.append(detail);
        detail = "";
    }
    return list;
}

void Helper::updateDetails()
{
    ldetail = this->getDetails();
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

void Helper::appListReceivedSlot(const QStringList &list)
{
    l = list;
    emit fetchingAppListFinished();
    ldetail = this->getDetails();
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
