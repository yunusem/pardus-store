#ifndef SINGLETON_H
#define SINGLETON_H

#include <QObject>
#include <QSharedMemory>
#include <QSystemSemaphore>

class Singleton
{
public:
    Singleton(const QString &key);
    ~Singleton();
    bool isAnotherRunning();
    bool tryToRun();
    void release();

private:
    const QString m_key;
    const QString m_memoryLockKey;
    const QString m_sharedMemoryKey;

    QSharedMemory m_sharedMemory;
    QSystemSemaphore m_systemSemaphore;

    Q_DISABLE_COPY( Singleton )

};

#endif // SINGLETON_H
