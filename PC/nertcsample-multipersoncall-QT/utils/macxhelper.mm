#include "macxhelper.h"
#include <CoreVideo/CVPixelBuffer.h>
#import <AppKit/AppKit.h>
#include <QDebug>

Macxhelper::Macxhelper(QObject* parent)
    :QObject(parent)
{

}




void Macxhelper::getCVPixelbufferInfo(void* cvref, void* &data, int &width, int &height)
{
    CVPixelBufferRef cvPixelBufferRef = CVPixelBufferRef(cvref);

    // 如果想要对数据进行修改就必须对向前数据进行锁定
    CVPixelBufferLockBaseAddress(cvPixelBufferRef, kCVPixelBufferLock_ReadOnly);
    // 处理图像数据
    OSType format = CVPixelBufferGetPixelFormatType(cvPixelBufferRef);

    //获取图像格式类型
    //LOG(INFO) << "getCVPixelbuffertype: " << getCVPixelbuffertype(cvref);

    //获取宽高
    width = CVPixelBufferGetWidth(cvPixelBufferRef);
    height = CVPixelBufferGetHeight(cvPixelBufferRef);
    // 获取指向数据内容的指针
    void *buffer0 = (void *)CVPixelBufferGetBaseAddress(cvPixelBufferRef);

    data = buffer0;
    CVPixelBufferUnlockBaseAddress(cvPixelBufferRef, kCVPixelBufferLock_ReadOnly);
}

const char* Macxhelper::getCVPixelbuffertype(void* cvref)
{
    CVPixelBufferRef cvPixelBufferRef = CVPixelBufferRef(cvref);

    auto p = CVPixelBufferGetPixelFormatType(cvPixelBufferRef);
       switch (p) {
       case kCVPixelFormatType_1Monochrome:                   return "kCVPixelFormatType_1Monochrome";
       case kCVPixelFormatType_2Indexed:                      return "kCVPixelFormatType_2Indexed";
       case kCVPixelFormatType_4Indexed:                      return "kCVPixelFormatType_4Indexed";
       case kCVPixelFormatType_8Indexed:                      return "kCVPixelFormatType_8Indexed";
       case kCVPixelFormatType_1IndexedGray_WhiteIsZero:      return "kCVPixelFormatType_1IndexedGray_WhiteIsZero";
       case kCVPixelFormatType_2IndexedGray_WhiteIsZero:      return "kCVPixelFormatType_2IndexedGray_WhiteIsZero";
       case kCVPixelFormatType_4IndexedGray_WhiteIsZero:      return "kCVPixelFormatType_4IndexedGray_WhiteIsZero";
       case kCVPixelFormatType_8IndexedGray_WhiteIsZero:      return "kCVPixelFormatType_8IndexedGray_WhiteIsZero";
       case kCVPixelFormatType_16BE555:                       return "kCVPixelFormatType_16BE555";
       case kCVPixelFormatType_16LE555:                       return "kCVPixelFormatType_16LE555";
       case kCVPixelFormatType_16LE5551:                      return "kCVPixelFormatType_16LE5551";
       case kCVPixelFormatType_16BE565:                       return "kCVPixelFormatType_16BE565";
       case kCVPixelFormatType_16LE565:                       return "kCVPixelFormatType_16LE565";
       case kCVPixelFormatType_24RGB:                         return "kCVPixelFormatType_24RGB";
       case kCVPixelFormatType_24BGR:                         return "kCVPixelFormatType_24BGR";
       case kCVPixelFormatType_32ARGB:                        return "kCVPixelFormatType_32ARGB";
       case kCVPixelFormatType_32BGRA:                        return "kCVPixelFormatType_32BGRA";
       case kCVPixelFormatType_32ABGR:                        return "kCVPixelFormatType_32ABGR";
       case kCVPixelFormatType_32RGBA:                        return "kCVPixelFormatType_32RGBA";
       case kCVPixelFormatType_64ARGB:                        return "kCVPixelFormatType_64ARGB";
       case kCVPixelFormatType_48RGB:                         return "kCVPixelFormatType_48RGB";
       case kCVPixelFormatType_32AlphaGray:                   return "kCVPixelFormatType_32AlphaGray";
       case kCVPixelFormatType_16Gray:                        return "kCVPixelFormatType_16Gray";
       case kCVPixelFormatType_30RGB:                         return "kCVPixelFormatType_30RGB";
       case kCVPixelFormatType_422YpCbCr8:                    return "kCVPixelFormatType_422YpCbCr8";
       case kCVPixelFormatType_4444YpCbCrA8:                  return "kCVPixelFormatType_4444YpCbCrA8";
       case kCVPixelFormatType_4444YpCbCrA8R:                 return "kCVPixelFormatType_4444YpCbCrA8R";
       case kCVPixelFormatType_4444AYpCbCr8:                  return "kCVPixelFormatType_4444AYpCbCr8";
       case kCVPixelFormatType_4444AYpCbCr16:                 return "kCVPixelFormatType_4444AYpCbCr16";
       case kCVPixelFormatType_444YpCbCr8:                    return "kCVPixelFormatType_444YpCbCr8";
       case kCVPixelFormatType_422YpCbCr16:                   return "kCVPixelFormatType_422YpCbCr16";
       case kCVPixelFormatType_422YpCbCr10:                   return "kCVPixelFormatType_422YpCbCr10";
       case kCVPixelFormatType_444YpCbCr10:                   return "kCVPixelFormatType_444YpCbCr10";
       case kCVPixelFormatType_420YpCbCr8Planar:              return "kCVPixelFormatType_420YpCbCr8Planar";
       case kCVPixelFormatType_420YpCbCr8PlanarFullRange:     return "kCVPixelFormatType_420YpCbCr8PlanarFullRange";
       case kCVPixelFormatType_422YpCbCr_4A_8BiPlanar:        return "kCVPixelFormatType_422YpCbCr_4A_8BiPlanar";
       case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:  return "kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange";
       case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:   return "kCVPixelFormatType_420YpCbCr8BiPlanarFullRange";
       case kCVPixelFormatType_422YpCbCr8_yuvs:               return "kCVPixelFormatType_422YpCbCr8_yuvs";
       case kCVPixelFormatType_422YpCbCr8FullRange:           return "kCVPixelFormatType_422YpCbCr8FullRange";
       case kCVPixelFormatType_OneComponent8:                 return "kCVPixelFormatType_OneComponent8";
       case kCVPixelFormatType_TwoComponent8:                 return "kCVPixelFormatType_TwoComponent8";
       case kCVPixelFormatType_30RGBLEPackedWideGamut:        return "kCVPixelFormatType_30RGBLEPackedWideGamut";
       case kCVPixelFormatType_OneComponent16Half:            return "kCVPixelFormatType_OneComponent16Half";
       case kCVPixelFormatType_OneComponent32Float:           return "kCVPixelFormatType_OneComponent32Float";
       case kCVPixelFormatType_TwoComponent16Half:            return "kCVPixelFormatType_TwoComponent16Half";
       case kCVPixelFormatType_TwoComponent32Float:           return "kCVPixelFormatType_TwoComponent32Float";
       case kCVPixelFormatType_64RGBAHalf:                    return "kCVPixelFormatType_64RGBAHalf";
       case kCVPixelFormatType_128RGBAFloat:                  return "kCVPixelFormatType_128RGBAFloat";
       case kCVPixelFormatType_14Bayer_GRBG:                  return "kCVPixelFormatType_14Bayer_GRBG";
       case kCVPixelFormatType_14Bayer_RGGB:                  return "kCVPixelFormatType_14Bayer_RGGB";
       case kCVPixelFormatType_14Bayer_BGGR:                  return "kCVPixelFormatType_14Bayer_BGGR";
       case kCVPixelFormatType_14Bayer_GBRG:                  return "kCVPixelFormatType_14Bayer_GBRG";
       default: return "UNKNOWN";
       }
}
