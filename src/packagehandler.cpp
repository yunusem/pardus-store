#include "packagehandler.h"
#include <QProcess>
#include <QProcessEnvironment>
#include <QByteArray>
#include <QDebug>
//#include <apt-pkg/pkgcache.h>
//#include <apt-pkg/dpkgpm.h>

PackageHandler::PackageHandler(QObject *parent) : QObject(parent)
{
    p = new QProcess();
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("LC_ALL","C");
    p->setEnvironment(env.toStringList());
    connect(p,SIGNAL(finished(int)),this,SIGNAL(finished(int)));
}

PackageHandler::~PackageHandler()
{
    p->deleteLater();
}

void PackageHandler::updateCache()
{
    p->start("apt-get update");
}

void PackageHandler::install(const QString pkg)
{
    p->start("apt-get install -y " + pkg);
}

void PackageHandler::remove(const QString pkg)
{
    p->start("apt-get remove -y " + pkg);
}

QString PackageHandler::getPolicy(const QString pkg) const
{    
    p->start("apt-cache policy " + pkg);

    p->waitForFinished();

    QString out = QString::fromLatin1(p->readAllStandardOutput());
    p->close();
    return out;
}
QByteArray PackageHandler::getError()
{
    return p->readAllStandardError();
}

QByteArray PackageHandler::getOutput()
{
    return p->readAllStandardOutput();
}

