#include "helper.h"
#include "filehandler.h"
//#include <apt-pkg/pkgcache.h>
//#include <apt-pkg/dpkgpm.h>

#include <QDebug>

Helper::Helper(QObject *parent) : QObject(parent)
{
    fh = new FileHandler(this);

    l = fh->readLines();
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
