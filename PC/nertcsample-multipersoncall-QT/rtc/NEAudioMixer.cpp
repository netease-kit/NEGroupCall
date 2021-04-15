#include <QDebug>

#include "NEAudioMixer.h"
#include "NERtcEngine.h"

NEAudioMixer::NEAudioMixer(NERtcEngine* engine)
    : m_engine(engine)
{
    qDebug() << "NEAudioMixer";
}

NEAudioMixer::~NEAudioMixer()
{
    qDebug() << "~NEAudioMixer";
}

int NEAudioMixer::startAudioMixing(const QString& filePath, int loopCount, bool send,
                                   unsigned int sendVolume, bool playback,
                                   unsigned int playbackVolume)
{
    if(m_engine.isNull())
    {
        return -1;
    }

    nertc::NERtcCreateAudioMixingOption opt;
    memcpy(opt.path, filePath.toLocal8Bit().data(), kNERtcMaxURILength);
    opt.loop_count = loopCount;
    opt.send_enabled = send;
    opt.send_volume = sendVolume;
    opt.playback_enabled = playback;
    opt.playback_volume =playbackVolume;
    return m_engine->GetRtcEngine()->startAudioMixing(&opt);
}

int NEAudioMixer::stopAudioMixing()
{
    if(m_engine.isNull())
    {
        return -1;
    }

    return m_engine->GetRtcEngine()->stopAudioMixing();
}

int NEAudioMixer::pauseAudioMixing()
{
    if(m_engine.isNull())
    {
        return -1;
    }

    return m_engine->GetRtcEngine()->pauseAudioMixing();
}

int NEAudioMixer::resumeAudioMixing()
{
    if(m_engine.isNull())
    {
        return -1;
    }

    return m_engine->GetRtcEngine()->resumeAudioMixing();
}

int NEAudioMixer::adjustAudioMixingSendVolume(unsigned int volume)
{
    if(m_engine.isNull())
    {
        return -1;
    }

    return m_engine->GetRtcEngine()->setAudioMixingSendVolume(volume);
}

int NEAudioMixer::adjustAudioMixingPlaybackVolume(unsigned int volume)
{
    if(m_engine.isNull())
    {
        return -1;
    }

    return m_engine->GetRtcEngine()->setAudioMixingPlaybackVolume(volume);
}

quint64 NEAudioMixer::getAudioMixingDuration()
{
    if(m_engine.isNull())
    {
        return -1;
    }

    quint64 duration;
    m_engine->GetRtcEngine()->getAudioMixingDuration(&duration);
    return duration;
}

quint64 NEAudioMixer::getAudioMixingCurrentPosition()
{
    if(m_engine.isNull())
    {
        return -1;
    }

    quint64 position;
    m_engine->GetRtcEngine()->getAudioMixingCurrentPosition(&position);
    return position;
}

int NEAudioMixer::setAudioMixingPosition(quint64 position)
{
    if(m_engine.isNull())
    {
        return -1;
    }

    return m_engine->GetRtcEngine()->setAudioMixingPosition(position);
}

quint32 NEAudioMixer::getAudioMixingSendVolume()
{
    if(m_engine.isNull())
    {
        return -1;
    }

    quint32 volume;
    m_engine->GetRtcEngine()->getAudioMixingSendVolume(&volume);
    return volume;
}

quint32 NEAudioMixer::getAudioMixingPlaybackVolume()
{
    if(m_engine.isNull())
    {
        return -1;
    }

    quint32 volume;
    m_engine->GetRtcEngine()->getAudioMixingPlaybackVolume(&volume);
    return volume;
}
