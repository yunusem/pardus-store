#include "packagehandler.h"
#include <QProcess>
#include <QProcessEnvironment>
#include <QByteArray>

//#include <apt-pkg/pkgcache.h>
//#include <apt-pkg/dpkgpm.h>

PackageHandler::PackageHandler(QObject *parent) : QObject(parent)
{
    p = new QProcess(this);
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("LC_ALL","C");
    p->setEnvironment(env.toStringList());
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

QString PackageHandler::getPolicy(const QString pkg) const
{
    QProcess pr;
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("LC_ALL","C");
    pr.setEnvironment(env.toStringList());
    pr.start("apt-cache policy " + pkg);

    pr.waitForFinished();

    QString out = QString::fromLocal8Bit(pr.readAllStandardOutput());
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

