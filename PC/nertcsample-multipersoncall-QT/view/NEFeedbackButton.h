#ifndef NEFEEDBACKBUTTON_H
#define NEFEEDBACKBUTTON_H

#include <QWidget>

namespace Ui {
class NEFeedbackButton;
}

class NEFeedbackButton : public QWidget
{
    Q_OBJECT

public:
    explicit NEFeedbackButton(QWidget *parent = nullptr);
    ~NEFeedbackButton();

    virtual void mousePressEvent(QMouseEvent *event) override;

    void setIsGoodFeedback(bool isGood);

    void setIsCheck(bool isCheck);

Q_SIGNALS:
    void clicked();

private:
    void updateButtonStyle();

private:
    Ui::NEFeedbackButton *ui;

    bool m_bCheck;

    bool m_bGoodFeedback;
};

#endif // NEFEEDBACKBUTTON_H
