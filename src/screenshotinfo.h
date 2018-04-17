#ifndef SCREENSHOTINFO_H_
#define SCREENSHOTINFO_H_

#include <QString>
#include <QList>

class Screenshot;

class ScreenshotInfo
{
public:
    ScreenshotInfo(const QString &packageName,
                   const QList<Screenshot> &sshots);

    const QString &package() const;
    const QList<Screenshot> &screenshots() const;

private:
    QString m_package;
    QList<Screenshot> m_screenshots;
};

inline const QString &ScreenshotInfo::package() const { return m_package; }
inline const QList<Screenshot> &ScreenshotInfo::screenshots() const { return m_screenshots; }

class Screenshot
{
public:
    Screenshot(const QString &smallImgUrl,
               const QString &largeImgUrl,
               const QString &version);

    QString smallImageUrl() const;
    QString largeImageUrl() const;
    QString version() const;
    QString toString() const;

private:
    QString m_smallImg, m_largeImg, m_version;
};



#endif /* end of include guard: SCREENSHOTINFO_H_ */

