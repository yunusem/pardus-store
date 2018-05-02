#include "singleton.h"
#include <QCryptographicHash>

namespace
{

QString generateKeyHash( const QString& key, const QString& salt )
{
    QByteArray data;

    data.append( key.toUtf8() );
    data.append( salt.toUtf8() );
    data = QCryptographicHash::hash( data, QCryptographicHash::Sha1 ).toHex();

    return data;
}

}

Singleton::Singleton( const QString &key )
    : m_key( key )
    , m_memoryLockKey( generateKeyHash( key, "_m_memoryLockKey" ) )
    , m_sharedMemoryKey( generateKeyHash( key, "_m_sharedMemoryKey" ) )
    , m_sharedMemory( m_sharedMemoryKey )
    , m_systemSemaphore( m_memoryLockKey, 1 )
{
    m_systemSemaphore.acquire();
    {
        QSharedMemory fix( m_sharedMemoryKey );
        fix.attach();
    }
    m_systemSemaphore.release();
}

Singleton::~Singleton()
{
    release();
}

bool Singleton::isAnotherRunning()
{
    if ( m_sharedMemory.isAttached() ) {
        return false;
    }
    m_systemSemaphore.acquire();
    const bool isRunning = m_sharedMemory.attach();
    if ( isRunning ) {
        m_sharedMemory.detach();
    }
    m_systemSemaphore.release();

    return isRunning;
}

bool Singleton::tryToRun()
{
    if ( isAnotherRunning() ) {
        return false;
    }
    m_systemSemaphore.acquire();
    const bool result = m_sharedMemory.create( sizeof( quint64 ) );
    m_systemSemaphore.release();
    if ( !result ) {
        release();
        return false;
    }
    return true;
}

void Singleton::release()
{
    m_systemSemaphore.acquire();
    if ( m_sharedMemory.isAttached() ) {
        m_sharedMemory.detach();
    }
    m_systemSemaphore.release();
}
