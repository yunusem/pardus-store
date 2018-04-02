#ifndef HELPER_H
#define HELPER_H

#include <QObject>
#include <QStringList>
#include <QString>

class FileHandler;
class PackageHandler;

class Helper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool processing READ processing NOTIFY processingFinished)
public:
    explicit Helper(QObject *parent = 0);
    bool processing() const;
    Q_INVOKABLE QStringList appList();
    Q_INVOKABLE QStringList getApplicationsByCategory(const QString c);
    Q_INVOKABLE QStringList getApplicationsByName(const QString c);
    Q_INVOKABLE void install(const QString pkg);
    Q_INVOKABLE void remove(const QString pkg);
private:
    bool p;
    FileHandler *fh;
    PackageHandler *ph;
    QStringList l;

private slots:
    void packageProcessFinished(int code);

signals:
    void processingFinished();

public slots:
};

#endif // HELPER_H
