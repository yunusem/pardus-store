#ifndef HELPER_H
#define HELPER_H

#include <QObject>
#include <QStringList>
#include <QString>

class FileHandler;

class Helper : public QObject
{
    Q_OBJECT

public:
    explicit Helper(QObject *parent = 0);
    Q_INVOKABLE QStringList appList();
    Q_INVOKABLE QStringList getApplicationsByCategory(const QString c);
private:
    FileHandler *fh;
    QStringList l;

signals:

public slots:
};

#endif // HELPER_H
