#ifndef MLINEEDIT_H
#define MLINEEDIT_H

#include <QObject>
#include <QWidget>
#include <QLineEdit>

class QPushButton;

class MLineEdit : public QLineEdit
{
    Q_OBJECT
public:
    explicit MLineEdit(QWidget *parent = nullptr);

    //设置按钮图标大小
    void setButtonSize(int width, int buttonMargin = 3);
    //设置图标
    void setButtonIcon(const QString &iconUrl);

protected:
    virtual void enterEvent(QEvent *event) override;
    virtual void leaveEvent(QEvent *event) override;
    virtual void focusOutEvent(QFocusEvent *event) override;

Q_SIGNALS:
    void sigButtonClicked();

private:
    void addButton();
    void onTextChanged(const QString &text);

private:
    QPushButton  *m_button;
};

#endif // MLINEEDIT_H
