#ifndef LOGINSTANCE_H
#define LOGINSTANCE_H

#include <QObject>

#include "glog/logging.h"

class LogInstance {
public:
    LogInstance(char* argv[]);
    ~LogInstance();

private:
    void configureGoogleLog();
    static void messageHandler(QtMsgType, const QMessageLogContext& context, const QString& message);
};


#endif  // LOGINSTANCE_H
