#include <QUrlQuery>
#include <QHttpPart>
#include <QFileInfo>
#include <QJsonObject>
#include <QJsonDocument>

#include "NEHttpManager.h"

NEHttpManager::NEHttpManager()
{
    networkAccessManager = new QNetworkAccessManager();
}

NEHttpManager::~NEHttpManager()
{
    delete networkAccessManager;
}

NERequest *NEHttpManager::get(const QString &urlString, const QMap<QString,QString> &params, int timeout)
{
    QUrl url(urlString);
    
    if (!params.isEmpty())
    {
        QUrlQuery query;

        for(auto it = params.begin(); it != params.end(); it ++)
        {
            query.addQueryItem(it.key(), it.value());
        }

        url.setQuery(query);
    }

    QNetworkRequest request(url);

    //支持301, 302重定向
    request.setAttribute(QNetworkRequest::FollowRedirectsAttribute, true);

    if(networkAccessManager->networkAccessible() == QNetworkAccessManager::NotAccessible)
    {
        qInfo() << "networkaccess change !";

        networkAccessManager->setNetworkAccessible(QNetworkAccessManager::Accessible);
    }

    QNetworkReply *reply = networkAccessManager->get(request);

    if (!reply)
    {
        qCritical("reply is null");

        return nullptr;
    }

    return new NERequest(reply, urlString, timeout);
}

NERequest *NEHttpManager::post(const QString &urlString, const QMap<QString,QString> &params, int timeout)
{
    QUrl url(urlString);

    QNetworkRequest request(url);

    QSslConfiguration config;
    QSslConfiguration conf = request.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    request.setSslConfiguration(conf);

    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json;charset=utf-8");

    QJsonObject obj;

    for(auto it = params.begin(); it != params.end(); it ++)
    {
        obj.insert(it.key(), it.value());
    }

    QString postData = QJsonDocument(obj).toJson(QJsonDocument::Compact);

    qInfo() << "postData:" << postData;

    QNetworkReply *reply = networkAccessManager->post(request, postData.toUtf8());

    if(networkAccessManager->networkAccessible() == QNetworkAccessManager::NotAccessible)
    {
        qInfo() << "networkaccess change !";

        networkAccessManager->setNetworkAccessible(QNetworkAccessManager::Accessible);
    }

    if (!reply)
    {
        return nullptr;
    }

    return new NERequest(reply, urlString, timeout);
}
