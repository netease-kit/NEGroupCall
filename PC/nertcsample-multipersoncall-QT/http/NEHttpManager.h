#ifndef UPCLASSHTTPMANAGER_H
#define UPCLASSHTTPMANAGER_H

#include <QMap>
#include <QNetworkAccessManager>

#include "NERequest.h"

class NEHttpManager
{
public:

    static NEHttpManager &instance()
    {
        static NEHttpManager manager;

        return manager;
    }

    NERequest *get(const QString &urlString,const QMap<QString,QString> &params,int timeout = 0);

    NERequest *post(const QString &urlString,const QMap<QString,QString> &params,int timeout = 0);

private:
    NEHttpManager();

    ~NEHttpManager();

private:

    QNetworkAccessManager       *networkAccessManager;
};

#endif // UPCLASSHTTPMANAGER_H
