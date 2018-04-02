#ifndef HELPER_H
#define HELPER_H

#include <QObject>
#include <QStringList>
#include <QString>

class FileHandler;
class QProcess;

class Helper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool installing READ installing NOTIFY installingFinished)
public:
    explicit Helper(QObject *parent = 0);
    bool installing() const;
    Q_INVOKABLE QStringList appList();
    Q_INVOKABLE QStringList getApplicationsByCategory(const QString c);
    Q_INVOKABLE QStringList getApplicationsByName(const QString c);
    Q_INVOKABLE void startInstalling(const QString pkg);
private:
    bool i;
    FileHandler *fh;
    QStringList l;
    QProcess *p;
private slots:
    void installingFinishedSlot();

signals:
    void installingFinished();

public slots:
};

#endif // HELPER_H
