[CmdletBinding()]
param (
    [string] $archiveName, [string] $targetName
)


$scriptDir = $PSScriptRoot
$currentDir = Get-Location
Write-Host "currentDir" $currentDir
Write-Host "scriptDir" $scriptDir

function Main() {

    New-Item -ItemType Directory $archiveName
    
    # 拷贝G2
    Copy-Item PC\nertcsample-multipersoncall-QT\nertc_sdk\dll\x86\SDL2.dll $archiveName\
	Copy-Item PC\nertcsample-multipersoncall-QT\nertc_sdk\dll\x86\nim_tools_http.dll $archiveName\
	Copy-Item PC\nertcsample-multipersoncall-QT\nertc_sdk\dll\x86\nertc_sdk.dll $archiveName\
    
    # 拷贝exe
    Copy-Item PC\nertcsample-multipersoncall-QT\bin\${targetName}.exe ${archiveName}.exe \
 
    # 拷贝依赖
    windeployqt --qmldir . --plugindir $archiveName\plugins --no-translations --compiler-runtime $archiveName\$targetName
    # 删除不必要的文件
    $excludeList = @("*.qmlc", "*.ilk", "*.exp", "*.lib", "*.pdb")
    Remove-Item -Path $archiveName -Include $excludeList -Recurse -Force
    # 打包zip
    Compress-Archive -Path $archiveName $archiveName'.zip'
}

if ($null -eq $archiveName || $null -eq $targetName) {
    Write-Host "args missing, archiveName is" $archiveName ", targetName is" $targetName
    return
}
Main
