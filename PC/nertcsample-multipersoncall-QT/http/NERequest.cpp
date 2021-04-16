#include <QIODevice>
#include <QTimer>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkCookie>
#include "utils/log_instance.h"

#include "NERequest.h"
#include "NEHttpManager.h"

NERequest::NERequest(QNetworkReply *reply, const QString &url, int timeout)
    : reply(reply)
    , url(url)
    , timeout(timeout)
    , hasQuit(false)
    , hasError(false)
    , hasTimeout(false)
{
    LOG(INFO) << "request url : " << url.toStdString();

    connect(reply,&QIODevice::readyRead,this,&NERequest::onReplyRedyRead);
    connect(reply, &QNetworkReply::finished, this, &NERequest::onReplyFinished);
    connect(reply, static_cast<void (QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error), this, &NERequest::onReplyError);
    connect(reply, &QNetworkReply::sslErrors,this, &NERequest::onReplysslError);
    connect(this,&NERequest::onFinish,this,&QObject::deleteLater);

    setTimeout(timeout);
}

NERequest::~NERequest()
{
    timer.stop();

    if(reply != nullptr)
    {
        reply->abort();

        delete reply;

        reply = nullptr;
    }
}

void NERequest::quit()
{
    LOG(INFO) << "quit request : " << url.toStdString();

    hasQuit = true;

    timer.stop();

    if(reply != nullptr)
        reply->abort();
}

const QString &NERequest::getUrl()
{
    return url;
}

void NERequest::onReplyRedyRead()
{
    QByteArray data = reply->readAll();

    response.append(data);
}

void NERequest::onReplyFinished()
{
    if(hasQuit)
    {
        emit onQuit();
        emit onFinish();
    }

    if(hasQuit || hasError || hasTimeout)
        return;

    timer.stop();

    saveCookie();

    QJsonParseError err;
    QJsonDocument   doc = QJsonDocument::fromJson(response,&err);

    if(err.error != QJsonParseError::NoError)
    {
        LOG(INFO) << "request json fail :" << response.toStdString();

        emit onFail(UPClassHttpError::HTTP_JSON_ERROR,ERROR_CODE_JSON,"json parse error !");

        emit onFinish();

        return;
    }

    QJsonObject obj = doc.object();

    if(obj["code"].toInt() != 200)
    {
        LOG(INFO) << "response " << response.toStdString();

        LOG(INFO) << "request " << url.toStdString() << "error, code : " << obj["code"].toInt() << ", errorMsg : "<< obj["msg"].toString().toStdString();
        LOG(INFO) << response.toStdString();

        emit onFail(UPClassHttpError::HTTP_VALUE_ERROR,obj["code"].toInt(),obj["msg"].toString());

        emit onFinish();

        return;
    }

    LOG(INFO) << "request finish : " << url.toStdString();

    emit onSuccess(response);

    emit onSuccessByte(response);

    emit onFinish();
}

void NERequest::onReplyError(QNetworkReply::NetworkError code)
{

    if(hasQuit || hasTimeout)
        return;

    timer.stop();

    hasError = true;

    LOG(INFO) << "request network error :" << url.toStdString() << code << reply->attribute( QNetworkRequest::HttpStatusCodeAttribute).toInt();

    emit onFail(UPClassHttpError::HTTP_NETWORK_ERROR,reply->attribute( QNetworkRequest::HttpStatusCodeAttribute).toInt(),"network error !");

    emit onFinish();
}

void NERequest::onReplysslError(const QList<QSslError> &errors)
{
    if(hasQuit || hasTimeout)
        return;

    timer.stop();

    hasError = true;

    LOG(INFO) << "request ssl error :" << url.toStdString();

    emit onFail(UPClassHttpError::HTTP_SSL_ERROR,ERROR_CODE_SSL,"ssl error !");

    emit onFinish();
}

void NERequest::onTimeout()
{
    if(hasError || hasQuit)
        return;

    hasTimeout = true;

    if(reply != nullptr)
        reply->abort();

    LOG(INFO) << "request time out :" << url.toStdString();

    emit onFail(UPClassHttpError::HTTP_TIMEOUT_ERROR,ERROR_CODE_TIMEOUT,"http timeout !");

    emit onFinish();
}

void NERequest::saveCookie()
{
    QVariant varRequestCookies = reply->request().header(QNetworkRequest::CookieHeader);

    QVariant varResponseCookies = reply->header(QNetworkRequest::SetCookieHeader);

    QList<QNetworkCookie> cookies = varRequestCookies.value< QList<QNetworkCookie> >();

    //dosomething
}

QVariant NERequest::getUserData() const
{
    return userData;
}

void NERequest::setUserData(const QVariant &value)
{
    userData = value;
}

bool NERequest::isQuit()
{
    return hasQuit;
}

void NERequest::setTimeout(int value)
{
    timeout = value;

    if(timeout != 0)
    {
        timer.setInterval(timeout);

        timer.setSingleShot(true);

        timer.start();

        connect(&timer,&QTimer::timeout,this,&NERequest::onTimeout);
    }
}
