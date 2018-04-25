#include "helper.h"
#include "filehandler.h"
#include "packagehandler.h"
#include "networkhandler.h"
#include "applicationdetail.h"
#include <QLocale>
#include <QProcess>
#include <QRegExp>
#include <QDebug>

Helper::Helper(QObject *parent) : QObject(parent), p(false)
{    
    nh = new NetworkHandler(10000,this);
    fh = new FileHandler(this);
    ph = new PackageHandler(this);
    l = fh->readLines();    
    ldetail = this->getDetails();
    this->fillTheList();
    connect(ph,SIGNAL(finished(int)),this,SLOT(packageProcessFinished(int)));    
    connect(nh,SIGNAL(appDetailsReceived(ApplicationDetail)),this,SLOT(appDetailReceivedSlot(ApplicationDetail)));
    connect(nh,SIGNAL(notFound()),this,SIGNAL(screenshotNotFound()));

}

bool Helper::processing() const
{
    return p;
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

void Helper::getAppDetails(const QString &pkg)
{  
    nh->getApplicationDetails(pkg);
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
