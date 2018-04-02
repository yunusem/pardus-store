#include "helper.h"
#include "filehandler.h"
//#include <apt-pkg/pkgcache.h>
//#include <apt-pkg/dpkgpm.h>
#include <QProcess>
#include <QDebug>

Helper::Helper(QObject *parent) : QObject(parent), i(false)
{
    fh = new FileHandler(this);

    l = fh->readLines();
    p = new QProcess(this);

    connect(p,SIGNAL(finished(int)),this,SLOT(installingFinishedSlot()));

}

bool Helper::installing() const
{
    return i;
}

QStringList Helper::appList() {
    return l;
}

QStringList Helper::getApplicationsByCategory(const QString c)
{
    QStringList out;
    QStringList sl;
    foreach (QString line, l) {
        sl = line.split(" ");
        if (sl.at(1) == c) {
            out.append(sl.at(0));
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
    foreach (QString line, l) {
        sl = line.split(" ");
        application = sl.at(0);
        category = sl.at(1);

        if(application.contains(c)) {
            if(application.mid(0,c.count()-1) == c) {
                firstPortion.append(application);
            } else {
                secondPortion.append(application);
            }
        }
    }

    return firstPortion + secondPortion;
}

void Helper::startInstalling(const QString pkg)
{

    p->start("apt-get install -y " + pkg);
    //p->waitForFinished(-1);
    i = true;
}

void Helper::installingFinishedSlot()
{
    i = false;
    emit installingFinished();
}
