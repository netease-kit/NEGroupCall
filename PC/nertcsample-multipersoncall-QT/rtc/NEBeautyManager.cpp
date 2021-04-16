#include <sstream>
#include <fstream>
#include <iostream>
#include <QWindow>
#include <QCoreApplication>
#include <QDebug>
#include <QThread>
#include "utils/log_instance.h"

#include "NEBeautyManager.h"
#include "CNamaSDK.h"          //nama SDK 的头文件
#include "authpack.h"
#include "NERtcEngine.h"

#define MAX_BEAUTYFACEPARAMTER 7
#define MAX_FACESHAPEPARAMTER 15

const QString g_faceBeautification = "face_beautification_v2.bundle";

const std::string g_faceBeautyParamName[MAX_BEAUTYFACEPARAMTER] = { "blur_level","color_level", "red_level", "eye_bright", "tooth_whiten" ,"remove_pouch_strength", "remove_nasolabial_folds_strength" };

const std::string g_faceShapeParamName[MAX_FACESHAPEPARAMTER] = { "cheek_thinning","eye_enlarging", "intensity_chin", "intensity_forehead", "intensity_nose","intensity_mouth",
                                                                  "cheek_v","cheek_narrow","cheek_small",
                                                                  "intensity_canthus", "intensity_eye_space", "intensity_eye_rotate", "intensity_long_nose",
                                                                  "intensity_philtrum", "intensity_smile" };

NEBeautyManager::NEBeautyManager(NERtcEngine* engine)
{
    m_engine = engine;
}

NEBeautyManager::~NEBeautyManager()
{
    fuDestroyAllItems();

    LOG(INFO) << "~NEBeautyManager";
}

void NEBeautyManager::initBeauty()
{
    if(m_bInit){
        return;
    }

    LOG(INFO)  <<  "fuGetOpenGLSupported: " << fuGetOpenGLSupported();

    auto ret = fuSetup(nullptr, 0, nullptr, g_auth_package, sizeof(g_auth_package));

    if(ret){
        m_bInit = true;
    }

    LOG(INFO) << "fuSetup:" << ret;

    qDebug()<< "fuGetVersion: " << fuGetVersion();

    QString beautyBundlePath = QCoreApplication::applicationDirPath() + "/assert/" + g_faceBeautification;

    LOG(INFO) << "beautyBundlePath: " << beautyBundlePath.toStdString();

    std::vector<char> propData;
    if (false == LoadBundleInner(beautyBundlePath.toStdString(), propData))
    {
        LOG(INFO) << "load face beautification data failed";
        return;
    }

    LOG(INFO) << "load face beautification data.";

    m_BeautyHandles = fuCreateItemFromPackage(&propData[0], propData.size());

    for (int i=0;i<MAX_BEAUTYFACEPARAMTER;i++)
    {
        if (i==0)
        {
            ret = fuItemSetParamd(m_BeautyHandles, const_cast<char*>(g_faceBeautyParamName[i].c_str()), 6.0f);
        }
        else
        {
            ret = fuItemSetParamd(m_BeautyHandles, const_cast<char*>(g_faceBeautyParamName[i].c_str()), 1.0f);
        }
    }
}

bool NEBeautyManager::setBeautyParam(const char *name, double value)
{
    return fuItemSetParamd(m_BeautyHandles, name, value);
}

void NEBeautyManager::onRenderFrame(int type, void *data, unsigned int w, unsigned int h, int frameid)
{
    int handle[] = { m_BeautyHandles };
    int handleSize = sizeof(handle) / sizeof(handle[0]);

#ifdef Q_OS_MAC
    fuRenderItemsEx2(FU_FORMAT_NV21_BUFFER, reinterpret_cast<int*>(data), FU_FORMAT_NV21_BUFFER, reinterpret_cast<int*>(data),w, h, m_FrameID, handle, handleSize, NAMA_RENDER_FEATURE_FULL, NULL);
#else
    fuRenderItemsEx2(FU_FORMAT_I420_BUFFER, reinterpret_cast<int*>(data), FU_FORMAT_I420_BUFFER, reinterpret_cast<int*>(data),w, h, m_FrameID, handle, handleSize, NAMA_RENDER_FEATURE_FULL, NULL);
#endif
}

size_t NEBeautyManager::FileSize(std::ifstream& file)
{
    std::streampos oldPos = file.tellg();
    file.seekg(0, std::ios::beg);
    std::streampos beg = file.tellg();
    file.seekg(0, std::ios::end);
    std::streampos end = file.tellg();
    file.seekg(oldPos, std::ios::beg);
    return static_cast<size_t>(end - beg);
}

bool NEBeautyManager::LoadBundleInner(const std::string &filepath, std::vector<char> &data)
{
    std::ifstream fin(filepath, std::ios::binary);
    if (false == fin.good())
    {
        fin.close();
        return false;
    }
    size_t size = FileSize(fin);
    if (0 == size)
    {
        fin.close();
        return false;
    }
    data.resize(size);
    fin.read(reinterpret_cast<char*>(&data[0]), size);

    fin.close();
    return true;
}

