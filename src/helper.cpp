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
    foreach (QString line, l) {
        QStringList sl = line.split(" ");
        if (sl.at(1) == c) {
            out.append(sl.at(0));
        }
    }
    return out;
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
