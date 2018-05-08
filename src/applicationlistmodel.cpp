#include "applicationlistmodel.h"

Application::Application(const QString &name, const QString &version,
                         bool stat, bool inque, const QString &category,
                         bool &non_free, const QString &description)
    :m_name(name), m_version(version), m_status(stat), m_in_queue(inque),
      m_category(category), m_non_free(non_free), m_description(description)
{

}

QString Application::name() const
{
    return m_name;
}

QString Application::version() const
{
    return m_version;
}

QString Application::category() const
{
    return m_category;
}

bool Application::non_free() const
{
    return m_non_free;
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
    case StatusRole: return app.status();
    case InQueueRole: return app.in_queue();
    case CategoryRole: return app.category();
    case NonFreeRole: return app.non_free();
    case DescriptionRole: return app.description();
    default: return QVariant();
    }
    return QVariant();
}

bool ApplicationListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if(index.row() < lst.size() && index.row() >= 0 ) {

        if(role == StatusRole) {
            lst[index.row()].setStatus(value.toBool());
        } else if (role == InQueueRole) {
            lst[index.row()].setInQueue(value.toBool());
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
    roles[StatusRole] = "status";
    roles[InQueueRole] = "inqueue";
    roles[CategoryRole] = "category";
    roles[NonFreeRole] = "nonfree";
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
    this->setFilterRole(isSearch ? NameRole | CategoryRole : CategoryRole);
    this->setFilterCaseSensitivity(Qt::CaseInsensitive);
    this->setFilterFixedString(s);

}

ApplicationListModel *ListCover::l = 0;

void ListCover::setInstance(ApplicationListModel *p)
{
    l=p;
}

