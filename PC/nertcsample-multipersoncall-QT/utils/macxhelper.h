
#include <QObject>

#include <QGuiApplication>

class Macxhelper : public QObject
{
    Q_OBJECT
public:
    Macxhelper(QObject* parent = nullptr);

public:
    //获取yuv裸数据即data数据
    static void getCVPixelbufferInfo(void* cvref, void* & data, int& width, int& height);

private:
    //获取图像格式类型
    const char *getCVPixelbuffertype(void *cvref);
};
