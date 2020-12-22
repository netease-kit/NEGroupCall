#include "view/NEJoinWidget.h"

#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    NEJoinWidget w;
    w.show();
    return a.exec();
}
