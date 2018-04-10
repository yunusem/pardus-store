#ifndef PACKAGEHANDLER_H
#define PACKAGEHANDLER_H

#include <QObject>
#include <QString>
class QProcess;
class QByteArray;

class PackageHandler : public QObject
{
    Q_OBJECT
public:
    explicit PackageHandler(QObject *parent = 0);
    ~PackageHandler();
private:
    QProcess *p;

signals:
    void finished(int code);

public slots:
    void install(const QString pkg);
    void remove(const QString pkg);
    QString getPolicy(const QString pkg) const;
    QByteArray getError();
    QByteArray getOutput();
};

#endif // PACKAGEHANDLER_H
