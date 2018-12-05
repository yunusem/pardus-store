#ifndef ICONPROVIDER_H
#define ICONPROVIDER_H

#include <QQuickImageProvider>
#include <QIcon>
#include <QSize>

#define default_icon_theme "pardus"

class IconProvider : public QQuickImageProvider
{
public:
    IconProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap)
    {

    }
    virtual QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
    {
        if (size) {
            *size = QSize(64, 64);
        }
        const QIcon defaultIcon = QIcon::fromTheme("image-missing",QIcon(id));
        defaultIcon.setThemeName(default_icon_theme);
        QIcon icon = QIcon::fromTheme(id, defaultIcon);
        icon.setThemeName(default_icon_theme);

        QPixmap pixmap = icon.pixmap(icon.actualSize(QSize(requestedSize.width() > 0 ? requestedSize.width() : 64,
                                                     requestedSize.height() > 0 ? requestedSize.height() : 64)));


        return pixmap;
    }

};

#endif // ICONPROVIDER_H
