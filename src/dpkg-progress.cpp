#include "dpkg-progress.h"

#include <QSocketNotifier>
#include <QDebug>

#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

#define RD_END 0
#define WR_END 1

static int set_nonblock(int fd)
{
    int flags;

    flags = fcntl(fd, F_GETFL);
    if (flags < 0)
        return -1;
    return fcntl(fd, F_SETFL, flags | O_NONBLOCK);
}

static int set_cloexec(int fd)
{
    int flags;

    flags = fcntl(fd, F_GETFD);
    if (flags < 0)
        return -1;
    return fcntl(fd, F_SETFD, flags | FD_CLOEXEC);
}

static ssize_t xread(int fd, void *buf, size_t len)
{
    ssize_t n;

    for (;;) {
        n = read(fd, buf, len);
        if (n < 0 && errno == EINTR)
            continue;
        return n;
    }
}

DpkgProgress::DpkgProgress(QObject *parent) : QObject(parent),
    m_notifier(nullptr),
    pos(&buf[0]),
    pipefd(-1),
    wrend(-1)
{
}

DpkgProgress::~DpkgProgress()
{
    if (m_notifier)
        m_notifier->setEnabled(false);
    if (pipefd >= 0)
        close(pipefd);
    if (wrend >= 0)
        close(wrend);
    delete m_notifier;
}

int DpkgProgress::statusFd()
{
    int fds[2];
    int err;

    err = ::pipe(fds);
    if (err)
        return -errno;
    if ((err = set_nonblock(fds[RD_END])))
        return -errno;

    m_notifier = new QSocketNotifier(fds[RD_END], QSocketNotifier::Read, this);
    connect(m_notifier, SIGNAL(activated(int)), this, SLOT(onReadable(void)));
    pipefd = fds[RD_END];
    wrend = fds[WR_END];
    set_cloexec(pipefd);

    return fds[WR_END];
}

void DpkgProgress::onReadable()
{
    ssize_t nr;
    char *nl;

    /* QProcess quirk */
    if (wrend >= 0) {
        close(wrend);
        wrend = -1;
    }

    nr = xread(pipefd, pos, avail());
    if (nr <= 0) {
        if (nr == 0) {
            m_notifier->setEnabled(false);
            notifyProgress(m_line, 100);
            return;
        }
        if (errno != EAGAIN) {
            qDebug("Unable to read from pipe!");
            return;
        }
    }
    pos += nr;

    do {
        nl = (char *)memchr(buf, '\n', pos - buf);
        if (!nl)
            break;

        *nl = '\0';
        nl += 1;
        processLine(buf);
        if (nl < pos)
            memmove(buf, nl, pos - nl);
        pos = &buf[pos - nl];
    } while (pos - buf > 1);

    if (!avail())
        pos= &buf[0];
}

void DpkgProgress::processLine(const char *s)
{
    QString str = QString::fromUtf8(s);
    m_line = str.split(':', QString::SkipEmptyParts);
    if (m_line.size() < 4)
        return;
    notifyProgress(m_line);
}

void DpkgProgress::notifyProgress(QStringList line, int percent)
{
    bool ok;

    if (percent == -1) {
        percent = line[2].toFloat(&ok);
        if (!ok)
            return;
    }
    emit dpkgProgress(line[0], line[1], percent, line[3]);
}
