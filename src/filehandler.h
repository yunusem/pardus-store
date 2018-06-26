#ifndef FILEHANDLER_H
#define FILEHANDLER_H

#include <QObject>

class FileHandler : public QObject
{
    Q_OBJECT
public:
    explicit FileHandler(QObject *parent = 0);
    void correctSources();

signals:
    void correctingSourcesFinished();
    void correctingSourcesFinishedWithError(const QString &err);

};

#endif // FILEHANDLER_H
