#ifndef DPKG_PROGRESS_H_
#define DPKG_PROGRESS_H_

#include <QObject>

class QString;
class QSocketNotifier;

class DpkgProgress : public QObject
{
    Q_OBJECT
public:
    DpkgProgress(QObject *parent = nullptr);
    virtual ~DpkgProgress();

    int statusFd();

signals:
    void dpkgProgress(const QString &status, const QString &pkg,
                      int value, const QString &desc);

private slots:
    void onReadable();

private:
    size_t avail() const;
    void processLine(const char *s);
    void notifyProgress(QStringList line, int percent = -1);

    QStringList m_line;
    QSocketNotifier *m_notifier;

    static const unsigned int BUF_SIZE = 128;
    char buf[BUF_SIZE], *pos;
    int pipefd, wrend;
};

inline size_t DpkgProgress::avail() const
{
    return &buf[BUF_SIZE] - pos;
}

#endif /* end of include guard: DPKG_PROGRESS_H_ */
