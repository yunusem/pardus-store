#include "applicationlistmodel.h"

Application::Application(const QString &name, const QString &version,
                         const QString &dsize, bool stat, bool inque,
                         const QString &category, bool &non_free, const QString &state,
                         const QString &description)
    :m_name(name), m_version(version), m_dsize(dsize), m_status(stat),
      m_in_queue(inque), m_category(category), m_non_free(non_free),
      m_description(description)
{
    if(state == "") {
        if(m_status) {
            m_state = "installed";
        } else {
            m_state = "get";
        }
    }
}

QString Application::name() const
{
    return m_name;
}

QString Application::version() const
{
    return m_version;
}

QString Application::download_size() const
{
    return m_dsize;
}

QString Application::category() const
{
    return m_category;
}

bool Application::non_free() const
{
    return m_non_free;
}

QString Application::state() const
{
    return m_state;
}

QString Application::description() const
{
    return m_description;
}

bool Application::status() const
{
    return m_status;
}

void Application::setStatus(bool stat)
{
    m_status = stat;
}

bool Application::in_queue() const
{
    return m_in_queue;
}

void Application::setInQueue(bool b)
{
    m_in_queue = b;
}

void Application::setState(const QString &state)
{
    m_state = state;
}

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
    case DownloadSizeRole: return app.download_size();
    case InstalledRole: return app.status();
    case InQueueRole: return app.in_queue();
    case CategoryRole: return app.category();
    case NonFreeRole: return app.non_free();
    case StateRole: return app.state();
    case DescriptionRole: return app.description();
    default: return QVariant();
    }
    return QVariant();
}

bool ApplicationListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if(index.row() < lst.size() && index.row() >= 0 ) {

        if(role == InstalledRole) {
            bool status = value.toBool();
            lst[index.row()].setStatus(status);
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
    roles[InstalledRole] = "installed";
    roles[InQueueRole] = "inqueue";
    roles[CategoryRole] = "section";
    roles[NonFreeRole] = "nonfree";
    roles[StateRole]= "delegatestate";
    roles[DescriptionRole] = "description";
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
    this->setFilterRole(isSearch ? NameRole : CategoryRole);
    this->setFilterCaseSensitivity(Qt::CaseInsensitive);
    this->setFilterFixedString(s);

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

