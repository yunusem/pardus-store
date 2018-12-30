#ifndef PACKAGEHANDLER_H
#define PACKAGEHANDLER_H

#include <QObject>
#include <QString>
class QProcess;
class QByteArray;
class DpkgProgress;

class PackageHandler : public QObject
{
    Q_OBJECT
public:
    explicit PackageHandler(QObject *parent = 0);
    ~PackageHandler();
private:
    QProcess *p;
    DpkgProgress *dpkg;
    int m_percent;
    QString m_status;

signals:
    void finished(int code);    
    void dpkgProgressStatus(const QString &status, const QString &pkg, int value, const QString &desc);

public slots:
    void updateCache();
    void install(const QString &pkg);
    void remove(const QString &pkg);
    bool terminate();
    void onFinished(int code);    
    QString getPolicy(const QString &pkg) const;
    QString getShow(const QString &pkg) const;
    QString getSearch(const QString &pkg) const;
    QByteArray getError();
    QByteArray getOutput();

private slots:
    void onDpkgProgress(const QString &status, const QString &pkg,
                        int value, const QString &desc);    

};

#endif // PACKAGEHANDLER_H
