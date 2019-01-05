#include "applicationdetail.h"
#include <QLocale>

ApplicationDetail::ApplicationDetail()
{
    m_name = "";
    m_descriptions = QList<Description>();
    m_download = 0;
    m_license = "";
    m_maintainer_mail = "";
    m_maintainer_name = "";
    m_screenshots = QStringList("");
    m_sections = QList<Section>();
    m_website = "";
}

QString ApplicationDetail::changelog() const
{
    return m_changelog;
}

QString ApplicationDetail::description() const
{
    QLocale systemLocale;
    QString locale = systemLocale.name().split("_")[0];
    QString language;
    QString description = "";
    for(int i=0; i< m_descriptions.size(); i++) {
        language = m_descriptions.at(i).language();
        if (language.compare("en") == 0) {
            description = m_descriptions.at(i).description();
        } else if (language.compare(locale) == 0) {
            if(m_descriptions.at(i).description() != "") {
                description = m_descriptions.at(i).description();
            }
        }
    }

    return description;
}

unsigned int ApplicationDetail::download() const
{
    return m_download;
}

QString ApplicationDetail::license() const
{
    return m_license;
}

QString ApplicationDetail::maintainerMail() const
{
    return m_maintainer_mail;
}

QString ApplicationDetail::maintainerName() const
{
    return m_maintainer_name;
}

QString ApplicationDetail::name() const
{
    return m_name;
}

QStringList ApplicationDetail::screenshots() const
{
    return m_screenshots;
}

QString ApplicationDetail::section() const
{
    QLocale systemLocale;
    QString locale = systemLocale.name().split("_")[0];
    QString language;
    QString section = "";
    for(int i=0; i< m_sections.size(); i++) {
        language = m_sections.at(i).language();
        if (language.compare("en") == 0) {
            section = m_sections.at(i).section();
        } else if (language.compare(locale) == 0) {
            if(m_sections.at(i).section() != "") {
                section = m_sections.at(i).section();
            }
        }
    }
    return section;
}

QString ApplicationDetail::website() const
{
    return m_website;
}

void ApplicationDetail::setChangelog(const QString &changelog)
{
    m_changelog = changelog;
}

void ApplicationDetail::setDescriptionList(const QList<Description> &descList)
{
    m_descriptions = descList;
}

void ApplicationDetail::setDownload(const unsigned int &download)
{
    m_download = download;
}

void ApplicationDetail::setLicense(const QString &license)
{
    m_license = license;
}

void ApplicationDetail::setMaintainer(const QString &mail, const QString &name)
{
    m_maintainer_mail = mail;
    m_maintainer_name = name;
}

void ApplicationDetail::setName(const QString &name)
{
    m_name = name;
}

void ApplicationDetail::setScreenshots(const QStringList &screenshots)
{
    m_screenshots = screenshots;
}

void ApplicationDetail::setSections(const QList<Section> &sections)
{
    m_sections = sections;
}

void ApplicationDetail::setWebsite(const QString &website)
{
    m_website = website;
}

Description::Description(const QString &lang, const QString &content):
    m_language(lang), m_description(content)
{

}

Section::Section(const QString &lang, const QString &content):
    m_language(lang), m_section(content)
{

}


