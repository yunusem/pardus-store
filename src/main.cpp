#include "src/helper.h"
#include "src/iconprovider.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    qmlRegisterType<Helper>("ps.helper",1,0,"Helper");
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.addImageProvider(QLatin1String("application"), new IconProvider);
    engine.load(QUrl(QLatin1String("qrc:/ui/main.qml")));


    return app.exec();
}
