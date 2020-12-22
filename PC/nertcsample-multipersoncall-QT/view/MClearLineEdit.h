#ifndef MCLEARLINEEDIT_H
#define MCLEARLINEEDIT_H

#include <QObject>
#include <QWidget>

#include "view/MLineEdit.h"

class MClearLineEdit : public MLineEdit
{
    Q_OBJECT
public:
    explicit MClearLineEdit(QWidget *parent = nullptr);

    //设置编辑框文本颜色
    void setNormalTextColor(const QString& color);
    //设置编辑框输入状态时的文本颜色
    void setInputTextColor(const QString& color);
    //设置placeHoderText的颜色
    void setHolderTextColor(const QString& color);

protected:
    void focusInEvent(QFocusEvent *event) override;
    void focusOutEvent(QFocusEvent *event) override;

protected Q_SLOTS:
    void onTextChanged(const QString &text);
    void onClearText();

private:
    void addBottomLine();
    void setTextStyle(const QString& color);
    void initBottomLine();

private:
    QString holderTextColor;
    QString inputColor;
    QString textColor;

    QFrame *line;//下划线
};

#endif // MCLEARLINEEDIT_H
