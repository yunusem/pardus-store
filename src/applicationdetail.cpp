#include "applicationdetail.h"

ApplicationDetail::ApplicationDetail(const QString &appName,
                                     const QStringList &ssUrls,
                                     const QList<Description> &descs):
    m_app(appName), m_screenshots(ssUrls), m_descriptions(descs)
{

}

Description::Description(const QString &lang, const QString &content):
    m_language(lang), m_description(content)
{

}
