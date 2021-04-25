#ifndef NESEETINGWIDGETINGWIDGET_H
#define NESEETINGWIDGETINGWIDGET_H

#include <QDialog>
#include <QMap>
#include "utils/NERoomLiveConfig.h"

namespace Ui {
class NESettingWidget;
}

class NESettingWidget : public QDialog
{
    Q_OBJECT

public:
    explicit NESettingWidget(QWidget *parent = nullptr);
    ~NESettingWidget();

private:
    void initWidget();
    void initQualityComboBox(bool bMusicSence);

private:
    Ui::NESettingWidget *ui;

    unsigned int m_musicSenceQualityIndex = 3;
    unsigned int m_voiceSenceQualityIndex = 1;
};

#endif // NESEETINGWIDGETINGWIDGET_H
