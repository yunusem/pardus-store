#include "src/helper.h"
#include "src/iconprovider.h"
#include "src/applicationlistmodel.h"
#include "src/singleton.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTranslator>
#include <QLocale>
#include <QIcon>
#include <QDebug>

int main(int argc, char *argv[])
{
    Singleton singleton("pardus-application-store");
    if (!singleton.tryToRun()) {
        return 0;
    }
    qmlRegisterType<Helper>("ps.helper",1,0,"Helper");
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setWindowIcon(QIcon(":/images/icon.svg"));
    QGuiApplication app(argc, argv);

    ApplicationListModel listModel;
    ListCover::setInstance(&listModel);
    FilterProxyModel filterModel;
    filterModel.setSourceModel(&listModel);
    filterModel.setSortRole(NameRole);

    QTranslator t;
    if (t.load(":/translations/pardus-store_" + QLocale::system().name())) {
        app.installTranslator(&t);
    } else {
        qDebug() << "Could not load the translation";
    }

    QQmlApplicationEngine engine;
    QQmlContext *context = engine.rootContext();
    context->setContextProperty("applicationModel", &filterModel);
    engine.addImageProvider(QLatin1String("application"), new IconProvider);
    engine.load(QUrl(QLatin1String("qrc:/ui/main.qml")));


    return app.exec();
}
