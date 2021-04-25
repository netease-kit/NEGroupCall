#include <QApplication>

#include "view/NEJoinWidget.h"
#include "utils/log_instance.h"
#ifdef WIN32
#include "utils/app_dump.h"
#endif

int main(int argc, char *argv[])
{
    qputenv("QT_MAC_WANTS_LAYER","1");

#ifdef WIN32
    ::SetUnhandledExceptionFilter(MyUnhandledExceptionFilter);
#endif
    QGuiApplication::setQuitOnLastWindowClosed(false);
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
    QApplication a(argc, argv);
    QFont font;
    font.setFamily("Microsoft YaHei");
    a.setFont(font);

    LogInstance logInstance(argv);

    NEJoinWidget w;
    w.show();
    return a.exec();
}
