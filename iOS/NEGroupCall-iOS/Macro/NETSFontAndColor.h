//
//  NETSFontAndColor.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#ifndef NETSFontAndColor_h
#define NETSFontAndColor_h


// UIColor宏定义

#define HEXCOLORA(rgbValue, alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define HEXCOLOR(rgbValue) HEXCOLORA(rgbValue, 1.0)


/// 颜色
#define KThemColor          [UIColor colorWithRed:26/255.0 green:26/255.0 blue:36/255.0 alpha:1.0]

//字号
#define Font_Size(fname,fsize) [UIFont fontWithName:fname size:fsize]

#define Font_Default(fsize) [UIFont systemFontOfSize:fsize]
//13号字体
#define TextFont_13 Font_Default(13)
//14号字体
#define TextFont_14 Font_Default(14)
//15号字体
#define TextFont_15 Font_Default(15)
//16号字体
#define TextFont_16 Font_Default(16)
//17号字体
#define TextFont_17 Font_Default(17)
//18号字体
#define TextFont_18 Font_Default(18)
//20号字体
#define TextFont_20 Font_Default(20)


#endif /* NETSFontAndColor_h */
