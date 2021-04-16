#include "log_instance.h"
#include <QString>
#include <QStandardPaths>
#include <QtGlobal>
#include <QDir>
#include <QDebug>

LogInstance::LogInstance(char* argv[])
{
    google::InitGoogleLogging(argv[0]);
    configureGoogleLog();
}

LogInstance::~LogInstance()
{
    google::ShutdownGoogleLogging();
}

void LogInstance::configureGoogleLog()
{
    google::EnableLogCleaner(10);
    google::SetStderrLogging(google::GLOG_INFO);
    auto appDataDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    appDataDir.append("/App");
    QDir logDir = appDataDir;
    if (!logDir.exists(appDataDir))
        logDir.mkpath(appDataDir);

    QByteArray byteLogDir = appDataDir.toUtf8();
    FLAGS_log_dir = byteLogDir.data();
#ifdef Q_NO_DEBUG
    FLAGS_logtostderr = false;
#else
    FLAGS_logtostderr = false;
#endif
    FLAGS_alsologtostderr = false;
    FLAGS_logbufsecs = 0;       //
    FLAGS_max_log_size = 10;    // MB
    FLAGS_stop_logging_if_full_disk = true;

    LOG(INFO) << "===================================================";
    LOG(INFO) << "[Product] NetEase Muticall";
    LOG(INFO) << "[DeviceId] " << QString(QSysInfo::machineUniqueId()).toStdString();
    LOG(INFO) << "[OSVersion] " << QSysInfo::prettyProductName().toStdString();
    LOG(INFO) << "===================================================";

    qInstallMessageHandler(&LogInstance::messageHandler);
}

void LogInstance::messageHandler(QtMsgType, const QMessageLogContext &context, const QString &message)
{
    if (context.file && !message.isEmpty())
    {
        LOG(INFO) << "[" << context.file << ":" << context.line << "] " << message.toStdString();
    }
}

