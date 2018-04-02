#include "helper.h"
#include "filehandler.h"
#include "packagehandler.h"
#include <QProcess>
#include <QDebug>

Helper::Helper(QObject *parent) : QObject(parent), p(false)
{
    fh = new FileHandler(this);
    ph = new PackageHandler(this);
    l = fh->readLines();    

    connect(ph,SIGNAL(finished(int)),this,SLOT(packageProcessFinished(int)));

}

bool Helper::processing() const
{
    return p;
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
        emit processingFinished();
        qDebug() << ph->getOutput();
    } else {
        qDebug() << ph->getError();
    }

    p = false;

}
