#ifndef FILEHANDLER_H
#define FILEHANDLER_H

#include <QObject>
#include <QStringList>

class FileHandler : public QObject
{
    Q_OBJECT
public:
    explicit FileHandler(QObject *parent = 0);

signals:

public slots:
    QStringList readLines();
};

#endif // FILEHANDLER_H
