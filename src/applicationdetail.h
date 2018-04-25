#ifndef APPLICATIONDETAIL_H
#define APPLICATIONDETAIL_H

#include <QString>
#include <QStringList>
#include <QList>

class Description;

class ApplicationDetail
{
public:
    ApplicationDetail(const QString &appName,
                      const QStringList &ssUrls,
                      const QList<Description> &descs);

    const QString &app() const;
    const QStringList &screenshots() const;
    const QList<Description> &descriptions() const;

private:
    QString m_app;
    QStringList m_screenshots;
    QList<Description> m_descriptions;

};

inline const QString &ApplicationDetail::app() const { return m_app; }
inline const QStringList &ApplicationDetail::screenshots() const { return m_screenshots; }
inline const QList<Description> &ApplicationDetail::descriptions() const { return m_descriptions; }


class Description
{
public:
    Description(const QString &lang, const QString &content);
    const QString &language() const;
    const QString &description() const;

private:
    QString m_language, m_description;
};

inline const QString &Description::language() const { return m_language; }
inline const QString &Description::description() const { return m_description; }

#endif // APPLICATIONDETAIL_H
