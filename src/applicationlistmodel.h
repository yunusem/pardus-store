#ifndef APPLICATIONLISTMODEL_H
#define APPLICATIONLISTMODEL_H

#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <QHash>

#include "application.h"

enum Roles {
    NameRole = Qt::UserRole +1,
    VersionRole,
    DownloadSizeRole,
    CategoryRole,
    PrettyNameRole,
    ExecRole,
    StateRole,
    RatingRole,
    InstalledRole,
    InQueueRole,
    NonFreeRole,
    SearchRole
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
    Q_INVOKABLE QString getFilterString() const;

};

class ListCover : public QObject
{
    Q_OBJECT

public:
    static void setInstance(ApplicationListModel* p);
    static ApplicationListModel* l;

};


#endif // APPLICATIONLISTMODEL_H
