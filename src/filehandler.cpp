#include "filehandler.h"
#include <QFile>
#include <QTextStream>
#include <QUrl>

FileHandler::FileHandler(QObject *parent) : QObject(parent)
{

}

QStringList FileHandler::readLines() {
    QStringList out;
    QFile inputFile(":/app-list");
    if (inputFile.open(QIODevice::ReadOnly))
    {
       QTextStream in(&inputFile);
       while (!in.atEnd())
       {
          QString line = in.readLine();
          out.append(line);
       }
       inputFile.close();
    }
    return out;
}
