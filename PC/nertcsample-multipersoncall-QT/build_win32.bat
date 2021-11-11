cd %~dp0

chcp 65001
mkdir bin

copy nertc_sdk\dll\nertc_sdk.dll bin
copy nertc_sdk\dll\protoopp.dll bin
copy nertc_sdk\dll\SDL2.dll bin
copy nertc_sdk\dll\libfreetype-6.dll bin
copy nertc_sdk\dll\libjpeg-9.dll bin
copy nertc_sdk\dll\libpng16-16.dll bin
copy nertc_sdk\dll\libtiff-5.dll bin
copy nertc_sdk\dll\libwebp-7.dll bin
copy nertc_sdk\dll\SDL2_image.dll bin
copy nertc_sdk\dll\SDL2_ttf.dll bin
copy nertc_sdk\dll\zlib1.dll bin
copy CNamaSDK\dll\CNamaSDK.dll bin
copy CNamaSDK\dll\fuai.dll bin
copy third_party\ssl\libcrypto-1_1.dll bin
copy third_party\ssl\libssl-1_1.dll bin

if not exist %WORK_DIR%bin\assert mkdir %WORK_DIR%bin\assert
copy %WORK_DIR%CNamaSDK\assert\* %WORK_DIR%bin\assert /y
