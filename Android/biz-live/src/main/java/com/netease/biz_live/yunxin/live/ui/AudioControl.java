package com.netease.biz_live.yunxin.live.ui;

import android.content.Context;

import androidx.fragment.app.FragmentActivity;

import com.netease.biz_live.yunxin.live.dialog.AudioControlDialog;
import com.netease.biz_live.yunxin.live.liveroom.model.NERTCLiveRoom;
import com.netease.lava.nertc.sdk.audio.NERtcCreateAudioEffectOption;
import com.netease.lava.nertc.sdk.audio.NERtcCreateAudioMixingOption;

import java.io.Closeable;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * 音频控制
 */
public class AudioControl {

    private FragmentActivity activity;
    private NERTCLiveRoom liveRoom;

    //*************************伴音**********************
    private static String MUSIC_DIR = "music";
    private static String MUSIC1 = "music1.mp3";
    private static String MUSIC2 = "music2.mp3";
    private static String EFFECT1 = "effect1.wav";
    private static String EFFECT2 = "effect2.wav";
    private int musicIndex = -1;//默认伴音数组下标
    private int audioMixingVolume = 50;

    private int audioEffectVolume = 50;

    private int[] effectIndex;//音效数组
    private String[] musicPathArray;

    private String[] effectPathArray;

    private AudioControlDialog audioControlDialog;

    public AudioControl(FragmentActivity activity) {
        this.activity = activity;
    }

    public void setLiveRoom(NERTCLiveRoom liveRoom) {
        this.liveRoom = liveRoom;
    }

    /**
     * 初始化伴音和音效
     */
    public void initMusicAndEffect() {
        new Thread(() -> {
            String root = ensureMusicDirectory();
            effectPathArray = new String[]{extractMusicFile(root, EFFECT1), extractMusicFile(root, EFFECT2)};
            musicPathArray = new String[]{extractMusicFile(root, MUSIC1), extractMusicFile(root, MUSIC2)};
        }).start();
    }

    private String extractMusicFile(String path, String name) {
        copyAssetToFile(activity, MUSIC_DIR + "/" + name, path, name);
        return new File(path, name).getAbsolutePath();
    }

    private void copyAssetToFile(Context context, String assetsName,
                                 String savePath, String saveName) {

        File dir = new File(savePath);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        File destFile = new File(dir, saveName);
        InputStream inputStream = null;
        FileOutputStream outputStream = null;
        try {
            inputStream = context.getResources().getAssets().open(assetsName);
            if (destFile.exists() && inputStream.available() == destFile.length()) {
                return;
            }
            destFile.deleteOnExit();
            outputStream = new FileOutputStream(destFile);
            byte[] buffer = new byte[4096];
            int count;
            while ((count = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, count);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeQuiet(inputStream);
            closeQuiet(outputStream);
        }
    }

    private void closeQuiet(Closeable closeable) {
        if (closeable == null) {
            return;
        }

        try {
            closeable.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private String ensureMusicDirectory() {
        File dir = activity.getExternalFilesDir(MUSIC_DIR);
        if (dir == null) {
            dir = activity.getDir(MUSIC_DIR, 0);
        }
        if (dir != null) {
            dir.mkdirs();
            return dir.getAbsolutePath();
        }
        return "";
    }

    /**
     * 显示混音dailog
     */
    public void showAudioControlDialog() {
        audioControlDialog = new AudioControlDialog();
        audioControlDialog.setInitData(musicIndex, effectIndex, audioMixingVolume, audioEffectVolume);
        audioControlDialog.setCallBack(new AudioControlDialog.DialogActionsCallBack() {
            @Override
            public boolean setMusicPlay(int index) {
                musicIndex = index;
                liveRoom.stopAudioMixing();
                NERtcCreateAudioMixingOption option = new NERtcCreateAudioMixingOption();
                option.path = musicPathArray[musicIndex];
                option.playbackVolume = audioMixingVolume;
                option.sendVolume = audioMixingVolume;
                option.loopCount = 0;//无线循环
                return liveRoom.startAudioMixing(option) == 0;
            }

            @Override
            public void onMusicVolumeChange(int progress) {
                audioMixingVolume = progress;
                liveRoom.setAudioMixingSendVolume(progress);
                liveRoom.setAudioMixingPlaybackVolume(progress);
            }

            @Override
            public boolean addEffect(int index) {
                return addAudioEffect(index);
            }

            @Override
            public void onEffectVolumeChange(int progress, int[] index) {
                audioEffectVolume = progress;
                //sample 中简单实用一个seekbar 控制所有effect的音量
                for (int i = 0; i < index.length; i++) {
                    if (index[i] == 1) {
                        liveRoom.setEffectSendVolume(index2Id(i), progress);
                        liveRoom.setEffectPlaybackVolume(index2Id(i), progress);
                    }
                }
            }

            @Override
            public boolean stopEffect(int index) {
                if (liveRoom.stopEffect(index2Id(index)) == 0) {
                    if (effectIndex != null) {
                        effectIndex[index] = 0;
                    }
                    return true;
                }
                return false;
            }

            @Override
            public void stopMusicPlay() {
                musicIndex = -1;
                liveRoom.stopAudioMixing();
            }
        });
        audioControlDialog.show(activity.getSupportFragmentManager(), "audioControlDialog");
    }

    /**
     * 音效添加，音效同时可以有多个
     *
     * @param index
     * @return
     */
    private boolean addAudioEffect(int index) {
        if (effectPathArray == null || effectPathArray.length <= index) {
            return false;
        }
        NERtcCreateAudioEffectOption option = new NERtcCreateAudioEffectOption();
        option.path = effectPathArray[index];
        option.playbackVolume = audioEffectVolume;
        option.sendVolume = audioEffectVolume;
        option.loopCount = 1;
        liveRoom.stopAllEffects();
        if (effectIndex == null) {
            effectIndex = new int[2];
        }
        for (int i = 0; i < 2; i++) {
            if (i == index) {
                effectIndex[index] = 1;
            } else {
                effectIndex[i] = 0;
            }
        }

        return liveRoom.playEffect(index2Id(index), option) == 0;
    }

    public void onMixingFinished(){
        if(audioControlDialog != null){
            audioControlDialog.onMixingFinished();
        }
        musicIndex = -1;
    }

    public void onEffectFinish(int id) {
        if (audioControlDialog != null) {
            audioControlDialog.onEffectFinish(id);
        }
        if (effectIndex != null && effectIndex.length > id2Index(id)) {
            effectIndex[id2Index(id)] = 0;
        }
    }

    /**
     * effect index to id,id can't be 0
     *
     * @param index
     * @return
     */
    private int index2Id(int index) {
        return index + 1;
    }

    private int id2Index(int id) {
        return id - 1;
    }
}
