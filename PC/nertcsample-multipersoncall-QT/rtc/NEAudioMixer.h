#ifndef UPQCLOUDAUDIOMIXER_H
#define UPQCLOUDAUDIOMIXER_H

#include <QObject>
#include <QPointer>

#include "NERtcEngine.h"

class NEAudioMixer
{
public:
    NEAudioMixer(NERtcEngine *engine);

    ~NEAudioMixer();

    int startAudioMixing(const QString& filePath, int loopCount, bool send,
                         unsigned int sendVolume, bool playback,
                         unsigned int playbackVolume);

    int stopAudioMixing();

    int pauseAudioMixing();

    int resumeAudioMixing();

    int adjustAudioMixingSendVolume(unsigned int volume);

    int adjustAudioMixingPlaybackVolume(unsigned int volume);

    quint64 getAudioMixingDuration();

    quint64 getAudioMixingCurrentPosition();

    int setAudioMixingPosition(quint64 position);

    quint32 getAudioMixingSendVolume();

    quint32 getAudioMixingPlaybackVolume();

private:
    QPointer<NERtcEngine> m_engine;
};

#endif // UPQCLOUDAUDIOMIXER_H
