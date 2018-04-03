#ifndef ICONPROVIDER_H
#define ICONPROVIDER_H

#include <QQuickImageProvider>
#include <QIcon>
#include <QSize>

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

        QIcon icon = QIcon::fromTheme(id);
        if (icon.availableSizes().count() == 0) {
            icon = QIcon::fromTheme("image-missing");
        }
        QPixmap pixmap = icon.pixmap(icon.actualSize(QSize(requestedSize.width() > 0 ? requestedSize.width() : 64,
                                                     requestedSize.height() > 0 ? requestedSize.height() : 64)));


        return pixmap;
    }

};

#endif // ICONPROVIDER_H
