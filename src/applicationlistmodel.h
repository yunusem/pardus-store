#ifndef APPLICATIONLISTMODEL_H
#define APPLICATIONLISTMODEL_H

#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <QString>
#include <QList>

class Application
{
public:
    Application(const QString &name,
                const QString &version,
                bool stat,
                bool inque,
                const QString &category,
                bool &non_free,
                const QString &description = "");
    QString name() const;
    QString version() const;
    bool status() const;
    bool in_queue() const;
    QString category() const;
    bool non_free() const;
    QString description() const;
    void setStatus(bool stat);
    void setInQueue(bool b);
private:
    QString m_name;
    QString m_version;
    bool m_status;
    bool m_in_queue;
    QString m_category;
    bool m_non_free;
    QString m_description;
};

enum Roles {
    NameRole = Qt::UserRole +1,
    VersionRole,
    StatusRole,
    InQueueRole,
    CategoryRole,
    NonFreeRole,
    DescriptionRole,
};

class ApplicationListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    ApplicationListModel(QObject* parent = 0);
    ~ApplicationListModel();
    void addData(const Application &app);
    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role);

protected:
    QHash<int, QByteArray> roleNames() const;
private:
    QList<Application> lst;
};


class FilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
public:

    FilterProxyModel(QObject* parent = 0);

    ~FilterProxyModel();

    Q_INVOKABLE void setFilterString(QString s, bool isSearch);

};

class ListCover : public QObject
{
    Q_OBJECT

public:
    static void setInstance(ApplicationListModel* p);
    static ApplicationListModel* l;

};


#endif // APPLICATIONLISTMODEL_H
