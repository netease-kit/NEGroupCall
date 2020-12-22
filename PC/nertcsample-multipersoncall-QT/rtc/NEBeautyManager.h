#ifndef NEBEAUTYMANAGER_H
#define NEBEAUTYMANAGER_H

#include <QObject>

class NEBeautyManager : public QObject
{
    Q_OBJECT
public:
    explicit NEBeautyManager(QObject *parent = nullptr);
    ~NEBeautyManager();

    //设置美颜相关参数：滤镜、美型，具体参考相芯美颜文档
    bool setBeautyParam(const char* name, double value);

public Q_SLOTS:
     void onRenderFrame(int type, void* data, unsigned int w, unsigned int h,int frameid);

public:
    //美颜初始化
    void initBeauty();
    //加载资源包
    bool LoadBundleInner(const std::string& filepath, std::vector<char>& data);
    //计算文件大小
    size_t FileSize(std::ifstream &file);

private:
    int m_BeautyHandles;
    int m_FrameID = 0;
    bool m_bInit;
};

#endif // NEBEAUTYMANAGER_H
