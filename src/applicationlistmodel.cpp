#include "applicationlistmodel.h"
//#include "application.h"

ApplicationListModel::ApplicationListModel(QObject *parent)
    : QAbstractListModel(parent)
{

}

ApplicationListModel::~ApplicationListModel()
{

}

void ApplicationListModel::addData(const Application &app)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    lst.append(app);
    endInsertRows();
}

int ApplicationListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return lst.count();
}

QVariant ApplicationListModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= lst.count())
        return QVariant();

    const Application &app = lst[index.row()];

    switch (role) {
    case NameRole: return app.name();
    case VersionRole: return app.version();
    case DownloadSizeRole: return app.downloadsize();
    case CategoryRole: return app.category();
    case PrettyNameRole: return app.prettyname();
    case ExecRole: return app.exec();
    case StateRole: return app.state();
    case InstalledRole: return app.installed();
    case InQueueRole: return app.inqueue();
    case NonFreeRole: return app.nonfree();
    case SearchRole: return app.search();
    default: return QVariant();
    }
    return QVariant();
}

bool ApplicationListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if(index.row() < lst.size() && index.row() >= 0 ) {

        if(role == InstalledRole) {
            bool status = value.toBool();
            lst[index.row()].setInstalled(status);
            if(status) {
                lst[index.row()].setState("installed");
            } else {
                lst[index.row()].setState("get");
            }
        } else if(role == InQueueRole) {
            lst[index.row()].setInQueue(value.toBool());
        } else if(role == StateRole) {
            lst[index.row()].setState(value.toString());
        }

        dataChanged(index,index);
        return true;
    }
    return false;
}

QHash<int, QByteArray> ApplicationListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[VersionRole] = "version";
    roles[DownloadSizeRole] = "dsize";
    roles[CategoryRole] = "category";
    roles[PrettyNameRole] = "prettyname";
    roles[ExecRole] = "exec";
    roles[StateRole] = "delegatestate";
    roles[RatingRole] = "rating";
    roles[InstalledRole] = "installed";
    roles[InQueueRole] = "inqueue";
    roles[NonFreeRole] = "nonfree";
    roles[SearchRole] = "search";
    return roles;
}

FilterProxyModel::FilterProxyModel(QObject *parent)
    :QSortFilterProxyModel(parent)
{
    this->setFilterRole(CategoryRole);
}

FilterProxyModel::~FilterProxyModel()
{

}

void FilterProxyModel::setFilterString(QString s, bool isSearch)
{
    setFilterCaseSensitivity(Qt::CaseInsensitive);
    if(s == "") {
        setFilterRole(isSearch ? NameRole : CategoryRole);
        setFilterFixedString(s);
    } else {
        setFilterRole(isSearch ? SearchRole : CategoryRole);
        setFilterRegExp(s);
    }
}

QString FilterProxyModel::getFilterString() const
{
    return this->filterRegExp().pattern();
}

ApplicationListModel *ListCover::l = 0;

void ListCover::setInstance(ApplicationListModel *p)
{
    l=p;
}

