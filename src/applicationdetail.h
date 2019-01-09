#ifndef APPLICATIONDETAIL_H
#define APPLICATIONDETAIL_H

#include <QString>
#include <QStringList>
#include <QList>

class Description;
class Section;
class Changelog
{
public:
    Changelog(const QStringList &latest, const QString &history,
              const QString &date, const unsigned int &timestamp);
    Changelog();
    QStringList latest() const;
    QString history() const;
    QString date() const;
    unsigned int timestamp() const;

private:
    QStringList m_latest;
    QString m_history, m_date;
    unsigned int m_timestamp;
};

inline QStringList Changelog::latest() const { return m_latest; }
inline QString Changelog::history() const { return m_history; }
inline QString Changelog::date() const { return m_date; }
inline unsigned int Changelog::timestamp() const { return m_timestamp; }

class ApplicationDetail
{
public:
    ApplicationDetail();

    QStringList changelogLatest() const;
    QString changelogHistory() const;
    QString changelogDate() const;
    unsigned int changelogTimestamp() const;
    QString description() const;
    unsigned int download() const;
    QString license() const;
    QString maintainerMail() const;
    QString maintainerName() const;
    QString name() const;
    QStringList screenshots() const;
    QString section() const;
    QString website() const;

    void setChangelog(const Changelog &changelog);
    void setDescriptionList(const QList<Description> &descList);
    void setDownload(const unsigned int &download);
    void setLicense(const QString &license);
    void setMaintainer(const QString &mail, const QString &name);
    void setName(const QString &name);
    void setScreenshots(const QStringList &screenshots);
    void setSections(const QList<Section> &sections);
    void setWebsite(const QString &website);

private:
    Changelog m_changelog;
    QList<Description> m_descriptions;
    unsigned int m_download;
    QString m_license;
    QString m_maintainer_mail;
    QString m_maintainer_name;
    QString m_name;
    QStringList m_screenshots;
    QList<Section> m_sections;
    QString m_website;
};


class Description
{
public:
    Description(const QString &lang, const QString &content);
    QString language() const;
    QString description() const;

private:
    QString m_language, m_description;
};

inline QString Description::language() const { return m_language; }
inline QString Description::description() const { return m_description; }

class Section
{
public:
    Section(const QString &lang, const QString &content);
    QString language() const;
    QString section() const;

private:
    QString m_language, m_section;
};

inline QString Section::language() const { return m_language; }
inline QString Section::section() const { return m_section; }



#endif // APPLICATIONDETAIL_H
