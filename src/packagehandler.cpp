#include "packagehandler.h"
#include <QProcess>
#include <QByteArray>

//#include <apt-pkg/pkgcache.h>
//#include <apt-pkg/dpkgpm.h>

PackageHandler::PackageHandler(QObject *parent) : QObject(parent)
{
    p = new QProcess(this);
    connect(p,SIGNAL(finished(int)),this,SIGNAL(finished(int)));
}

void PackageHandler::install(const QString pkg)
{
    p->start("apt-get install -y " + pkg);
}

void PackageHandler::remove(const QString pkg)
{
    p->start("apt-get remove -y " + pkg);
}

QByteArray PackageHandler::getError()
{
    return p->readAllStandardError();
}

QByteArray PackageHandler::getOutput()
{
    return p->readAllStandardOutput();
}

