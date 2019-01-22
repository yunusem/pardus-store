#ifndef APPLICATION_H
#define APPLICATION_H

#include <QString>
#include <QList>
#include <QHash>

class Application
{
public:
    Application(const QString &name);

    QString name() const;
    QString version() const;
    QString downloadsize() const;
    QString category() const;
    QString categoryLocal() const;
    QString prettyname() const;
    QString exec() const;
    QString state() const;
    QString search() const;
    double rating() const;
    bool installed() const;
    bool inqueue() const;
    bool nonfree() const;

    void setVersion(const QString &version);
    void setDownloadsize(const QString &downloadsize);
    void setCategory(const QHash<QString,QString> &category);
    void setPrettyname (const QHash<QString, QString> &prettyname);
    void setExec(const QString &exec);
    void setState(const QString &state);
    void setRating(const double &rating);
    void setInstalled(bool installed);
    void setInQueue(bool inqueue);
    void setNonfree(bool nonfree);    

private:
    QString m_name;
    QString m_version;
    QString m_downloadsize;
    QHash<QString,QString> m_category;
    QHash<QString,QString> m_prettyname;
    QString m_exec;
    QString m_state;
    QString m_search;
    double m_rating;
    bool m_installed;
    bool m_inqueue;
    bool m_nonfree;
};

#endif // APPLICATION_H
