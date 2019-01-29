#include "application.h"
#include <QLocale>

Application::Application(const QString &name)
    :m_name(name)
{
    m_version = "";
    m_downloadcount = 0;
    m_downloadsize = "";
    m_category = QHash<QString, QString>();
    m_prettyname = QHash<QString, QString>();
    m_exec = "";
    m_state = "get";
    m_search = "";
    m_search.append(m_name);
    m_rating = 0.0;
    m_installed = false;
    m_inqueue = false;
    m_nonfree = false;
}

QString Application::name() const
{
    return m_name;
}

QString Application::version() const
{
    return m_version;
}

unsigned int Application::downloadcount()
{
    return m_downloadcount;
}

QString Application::downloadsize() const
{
    return m_downloadsize;
}

QString Application::category() const
{
    return m_category.value("en");
}

QString Application::categoryLocal() const
{
    QLocale systemLocale;
    QString locale = systemLocale.name().split("_")[0];
    QString category = m_category.value("en");
    if(m_category.keys().contains(locale) &&
            m_category.value(locale) != "") {
        category = m_category.value(locale);
    }
    return category;
}

QString Application::prettyname() const
{
    QLocale systemLocale;
    QString locale = systemLocale.name().split("_")[0];
    QString prettyname = m_prettyname.value("en");
    if(m_prettyname.keys().contains(locale) &&
            m_prettyname.value(locale) != "") {
        prettyname = m_prettyname.value(locale);
    }
    return prettyname;
}

QString Application::exec() const
{
    return m_exec;
}

QString Application::state() const
{
    return m_state;
}

QString Application::search() const
{
    return m_search;
}

double Application::rating() const
{
    return m_rating;
}

bool Application::installed() const
{
    return m_installed;
}

bool Application::nonfree() const
{
    return m_nonfree;
}

bool Application::inqueue() const
{
    return m_inqueue;
}

void Application::setVersion(const QString &version)
{
    m_version = version;
}

void Application::setDownloadcount(const unsigned int &downloadcount)
{
    m_downloadcount = downloadcount;
}

void Application::setDownloadsize(const QString &downloadsize)
{
    m_downloadsize = downloadsize;
}

void Application::setCategory(const QHash<QString, QString> &category)
{
    m_category = category;
    foreach (const QString &key, category.keys()) {
        if(m_search.indexOf(category.value(key)) == -1) {
            m_search.append(category.value(key));
        }
    }
}

void Application::setPrettyname(const QHash<QString, QString> &prettyname)
{
    m_prettyname = prettyname;
    foreach (const QString &key, prettyname.keys()) {
        if(m_search.indexOf(prettyname.value(key)) == -1) {
            m_search.append(prettyname.value(key));
        }
    }
}

void Application::setExec(const QString &exec)
{
    m_exec = exec;
}

void Application::setState(const QString &state)
{
    m_state = state;
}

void Application::setRating(const double &rating)
{
    m_rating = rating;
}

void Application::setInstalled(bool installed)
{
    m_installed = installed;
}


void Application::setInQueue(bool inqueue)
{
    m_inqueue = inqueue;
}

void Application::setNonfree(bool nonfree)
{
    m_nonfree = nonfree;
}
