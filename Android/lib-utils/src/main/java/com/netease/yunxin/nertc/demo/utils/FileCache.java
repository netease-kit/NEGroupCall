package com.netease.yunxin.nertc.demo.utils;

import android.content.Context;
import android.text.TextUtils;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

/**
 * Created by luc on 2020/11/8.
 */
public final class FileCache {
  private static final String CACHE_NAME = "temp";
  private static File cacheRoot = null;

  public static <T> boolean cacheValue(Context context, T data, TypeToken<T> token) {
    return cacheValue(context, getCommonFileName(token), data, token);
  }

  public static <T> boolean cacheValue(Context context, String name, T data, TypeToken<T> token) {
    String jsonStr = new Gson().toJson(data, token.getType());
    String fileName = getFullFileName(context, name);
    return writeStr(jsonStr, fileName);
  }

  public static <T> T getCacheValue(Context context, TypeToken<T> token) {
    return getCacheValue(context, getCommonFileName(token), token);
  }

  public static <T> T getCacheValue(Context context, String name, TypeToken<T> token) {
    String jsonStr = readStr(getFullFileName(context, name));
    return new Gson().fromJson(jsonStr, token.getType());
  }

  public static <T> boolean removeCache(Context context, TypeToken<T> token) {
    return removeCache(context, getCommonFileName(token));
  }

  public static boolean removeCache(Context context, String name) {
    String fileName = getFullFileName(context, name);
    File cache = new File(fileName);
    return !cache.exists() || cache.delete();
  }

  /**
   * 写入字符串至指定文件中
   *
   * @return true 写入成功，false 写入失败
   */
  private static boolean writeStr(String json, String fileName) {
    if (TextUtils.isEmpty(fileName)) {
      return false;
    }

    boolean result = false;
    try (BufferedWriter writer = new BufferedWriter(new FileWriter(fileName))) {
      writer.write(json);
      result = true;
    } catch (IOException e) {
      e.printStackTrace();
    }
    return result;
  }

  /**
   * 从指定文件中读取对应的字符串内容
   */
  private static String readStr(String fileName) {
    StringBuilder builder = new StringBuilder();
    try (BufferedReader reader = new BufferedReader(new FileReader(fileName))) {

      String line;
      do {
        line = reader.readLine();
        if (line != null) {
          builder.append(line);
        }
      } while (line != null);
    } catch (Exception e) {
      e.printStackTrace();
    }
    return builder.toString();
  }

  private static <T> String getCommonFileName(TypeToken<T> token) {
    return token.getRawType().getCanonicalName();
  }

  private static String getFullFileName(Context context, String fileName) {
    return new File(getCacheFile(context), fileName).getAbsolutePath();
  }

  /**
   * 获取 缓存文件夹
   *
   * @param context 当前 app 上下文
   * @return 缓存文件夹
   */
  private static File getCacheFile(Context context) {
    if (cacheRoot != null) {
      return cacheRoot;
    }
    File cacheParent = context.getCacheDir();
    File cache = new File(cacheParent, CACHE_NAME);
    if (!cache.exists()) {
      cache.mkdirs();
    }
    cacheRoot = cache;
    return cacheRoot;
  }
}
