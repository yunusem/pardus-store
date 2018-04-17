#include "screenshotinfo.h"

ScreenshotInfo::ScreenshotInfo(const QString &packageName,
                               const QList<Screenshot> &sshots) :
    m_package(packageName),
    m_screenshots(sshots)
{
}

Screenshot::Screenshot(const QString &smallImgUrl,
                       const QString &largeImgUrl,
                       const QString &version) :
    m_smallImg(smallImgUrl),
    m_largeImg(largeImgUrl),
    m_version(version)
{
}

QString Screenshot::smallImageUrl() const
{
    return m_smallImg;
}

QString Screenshot::largeImageUrl() const
{
    return m_largeImg;
}

QString Screenshot::version() const
{
    return m_version;
}

QString Screenshot::toString() const
{
    return QString("version: %1, small: %2, large: %3")
            .arg(m_version).arg(m_smallImg).arg(m_largeImg);
}
