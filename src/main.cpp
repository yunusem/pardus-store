#include "src/helper.h"
#include "src/iconprovider.h"
#include "src/applicationlistmodel.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    qmlRegisterType<Helper>("ps.helper",1,0,"Helper");
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    ApplicationListModel listModel;
    ListCover::setInstance(&listModel);
    FilterProxyModel filterModel;
    filterModel.setSourceModel(&listModel);
    filterModel.setFilterRole(NameRole);
    filterModel.setSortRole(NameRole);

    QQmlApplicationEngine engine;
    QQmlContext *context = engine.rootContext();
    context->setContextProperty("applicationModel", &filterModel);
    engine.addImageProvider(QLatin1String("application"), new IconProvider);
    engine.load(QUrl(QLatin1String("qrc:/ui/main.qml")));


    return app.exec();
}
