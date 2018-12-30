#include "packagehandler.h"
#include <QProcess>
#include <QProcessEnvironment>
#include <QByteArray>
#include <QDebug>
//#include <apt-pkg/pkgcache.h>
//#include <apt-pkg/dpkgpm.h>

#include "dpkg-progress.h"

PackageHandler::PackageHandler(QObject *parent) : QObject(parent),
    dpkg(nullptr), m_percent(0), m_status("")
{
    p = new QProcess();
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("LC_ALL","C");
    p->setEnvironment(env.toStringList());
    connect(p,SIGNAL(finished(int)),this,SIGNAL(finished(int)));
    connect(p,SIGNAL(finished(int)),this, SLOT(onFinished(int)));

}

PackageHandler::~PackageHandler()
{
    p->deleteLater();
}

void PackageHandler::updateCache()
{    
    p->start("apt update");
}

void PackageHandler::install(const QString &pkg)
{    
    int statusFd;
    QString cmd = "apt-get install -y ";
    dpkg = new DpkgProgress();

    statusFd = dpkg->statusFd();
    if (statusFd >= 0) {
        cmd.append("-o APT::Status-Fd=%1 %2");
        cmd = cmd.arg(statusFd).arg(pkg);
        connect(dpkg, SIGNAL(dpkgProgress(QString,QString,int,QString)),
                         this, SLOT(onDpkgProgress(QString,QString,int,QString)));
    } else {
        /* Unable to get progress information */
        delete dpkg;
        dpkg = nullptr;
        cmd.append("%1");
        cmd = cmd.arg(pkg);
    }
    p->start(cmd);
}

void PackageHandler::onFinished(int)
{
    if (dpkg) {
        dpkg->disconnect();
        dpkg->deleteLater();
        dpkg = nullptr;
    }
}

void PackageHandler::onDpkgProgress(const QString &status, const QString &pkg,
                                    int value, const QString &desc)
{    
    m_status = status;
    m_percent = value;
    emit dpkgProgressStatus(status, pkg, value, desc);
}

void PackageHandler::remove(const QString &pkg)
{    
    int statusFd;
    QString cmd = "apt-get remove -y ";
    dpkg = new DpkgProgress();

    statusFd = dpkg->statusFd();
    if (statusFd >= 0) {
        cmd.append("-o APT::Status-Fd=%1 %2");
        cmd = cmd.arg(statusFd).arg(pkg);
        connect(dpkg, SIGNAL(dpkgProgress(QString,QString,int,QString)),
                         this, SLOT(onDpkgProgress(QString,QString,int,QString)));
    } else {
        /* Unable to get progress information */
        delete dpkg;
        dpkg = nullptr;
        cmd.append("%1");
        cmd = cmd.arg(pkg);
    }
    p->start(cmd);
}

bool PackageHandler::terminate()
{
    if(m_status == "dlstatus" && m_percent < 99) {
        p->terminate();
        if (dpkg) {
            dpkg->disconnect();
            dpkg->deleteLater();
            dpkg = nullptr;
        }
        return true;
    } else {
        return false;
    }
}

QString PackageHandler::getPolicy(const QString &pkg) const
{
    QProcess process;
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("LC_ALL","C");
    process.setEnvironment(env.toStringList());
    process.start("apt-cache policy " + pkg);

    process.waitForFinished(-1);

    QString out = QString::fromLatin1(process.readAllStandardOutput());
    process.close();
    return out;
}

QString PackageHandler::getShow(const QString &pkg) const
{
    QProcess process;
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("LC_ALL","C");
    process.setEnvironment(env.toStringList());
    process.start("apt-cache show " + pkg);

    process.waitForFinished(-1);

    QString out = QString::fromLatin1(process.readAllStandardOutput());
    process.close();
    return out;
}

QString PackageHandler::getSearch(const QString &pkg) const
{
    QProcess process;
    process.start("apt-cache search " + pkg);

    process.waitForFinished();

    QString out = QString::fromLatin1(process.readAllStandardOutput());
    process.close();
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
