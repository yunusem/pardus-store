#include "helper.h"
#include "filehandler.h"
#include "packagehandler.h"
#include <QProcess>
#include <QRegExp>
#include <QDebug>

Helper::Helper(QObject *parent) : QObject(parent), p(false)
{
    fh = new FileHandler(this);
    ph = new PackageHandler(this);
    l = fh->readLines();    
    ldetail = this->getDetails();

    connect(ph,SIGNAL(finished(int)),this,SLOT(packageProcessFinished(int)));

}

bool Helper::processing() const
{
    return p;
}

QStringList Helper::appList()
{
    ldetail = this->getDetails();
    QStringList list;
    for(int i = 0; i < l.length(); i++) {
        list.append(l.at(i) + " " + ldetail.at(i));
    }
    return list;
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
    foreach (QString line, l) {
        app = line.split(" ").at(0);
        ix = output.indexOf(QRegExp(app + QString("*.*")));
        installed = output.at(ix + 1).split(" ").last();


        if (installed.contains("none")) {
            installed = "no";
        } else {
            installed = "yes";
        }

        version = output.at(ix + 2).split(" ").last();
        detail += version + " ";
        detail += installed;
        list.append(detail);
        detail = "";
    }
    return list;
}

void Helper::updateDetails()
{
    ldetail = this->getDetails();
}

QStringList Helper::getApplicationsByCategory(const QString c)
{
    QStringList out;
    QStringList sl;
    for(int i = 0; i < l.length(); i++) {
        sl = l.at(i).split(" ");
        if (sl.at(1) == c) {
            out.append(sl.at(0) + " " + ldetail.at(i));
        }
    }
    return out;
}

QStringList Helper::getApplicationsByName(const QString c)
{

    QStringList sl;
    QStringList firstPortion;
    QStringList secondPortion;
    QString application;
    QString category;
    QStringList mainList = this->appList();
    foreach (QString line, mainList) {
        sl = line.split(" ");
        application = sl.at(0);
        category = sl.at(1);

        if(application.contains(c)) {
            if(application.mid(0,c.count()-1) == c) {
                firstPortion.append(line);
            } else {
                secondPortion.append(line);
            }
        }
    }

    return firstPortion + secondPortion;
}

void Helper::install(const QString pkg)
{

    ph->install(pkg);
    p = true;
}

void Helper::remove(const QString pkg)
{

    ph->remove(pkg);
    p = true;
}

void Helper::packageProcessFinished(int code)
{
    if(code == 0) {        
        //qDebug() << ph->getOutput();

    } else {
        qDebug() << ph->getError();
    }
    emit processingFinished();
    p = false;
    //updateDetails();

}
