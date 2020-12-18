//
// Created by Wenchao Ding on 2020-09-03.
//

#include <jni.h>
#include <string>

extern "C"
JNIEXPORT jstring
JNICALL
Java_com_netease_yunxin_nertc_baselib_NativeConfig_getAppKey__(JNIEnv *env, jclass) {
    std::string appKey = "set_your_app_key_here";
    return env->NewStringUTF(appKey.c_str());
}

extern "C"
JNIEXPORT jstring
JNICALL
Java_com_netease_yunxin_nertc_baselib_NativeConfig_getBaseURL__(JNIEnv *env, jclass) {
    std::string baseURL = "set_your_base_url_here";
    return env->NewStringUTF(baseURL.c_str());
}

extern "C"
JNIEXPORT jstring
JNICALL
Java_com_netease_yunxin_nertc_baselib_NativeConfig_getLiveAppKey__(JNIEnv *env, jclass) {
    std::string baseURL = "set_your_live_key_here";
    return env->NewStringUTF(baseURL.c_str());
}