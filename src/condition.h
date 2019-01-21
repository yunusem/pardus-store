#ifndef CONDITION_H
#define CONDITION_H

#include <QObject>

class Condition : public QObject
{
    Q_OBJECT
public:
    enum State {
        Idle,
        Installed,
        Removed,
        Downloading,
        Installing,
        Removing
    };
    Q_ENUM(State)
};

#endif // CONDITION_H
