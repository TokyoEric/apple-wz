@echo off
chcp 65001 >nul
REM ============================================
REM TokyoRepacker 发行版构建脚本
REM 1. Maven 编译 JAR
REM 2. Launch4j GUI 版打包 EXE（含自定义图标）
REM 3. 复制到 D:\TokyoRepacker
REM ============================================
set JAVA_HOME=D:\Java\jdk-21.0.2
set PATH=%JAVA_HOME%\bin;%PATH%
set MVN=C:\Users\ADMIN\.m2\wrapper\dists\apache-maven-3.9.11\03d7e36a140982eea48e22c1dcac01d8862b2550b2939e09a0809bbc5182a5bc\bin\mvn.cmd
set L4JC=C:\temp\launch4j-gui\extracted\launch4j\launch4jc.exe
set PROJ=%~dp0
set TARGET=%PROJ%target
set OUTPUT=D:\TokyoRepacker
set BUILD=%TEMP%\TokyoRepacker-build

echo [1/3] Maven 编译...
cd /d "%PROJ%"
call %MVN% clean package -Dmaven.compiler.release= -Dmaven.compiler.source=21 -Dmaven.compiler.target=21 -DskipTests -q
if %ERRORLEVEL% neq 0 echo 编译失败 && exit /b 1

echo [2/3] Launch4j 打包 EXE（含图标）...
rmdir /s /q "%BUILD%" 2>nul
mkdir "%BUILD%"
copy "%TARGET%\TokyoRepacker.jar" "%BUILD%\" >nul
copy "%PROJ%src\main\resources\icons\TokyoRepacker.ico" "%BUILD%\" >nul

REM 生成 Launch4j 配置
echo ^<?xml version="1.0" encoding="UTF-8"?^> > "%BUILD%\config.xml"
echo ^<launch4jConfig^> >> "%BUILD%\config.xml"
echo   ^<headerType^>gui^</headerType^> >> "%BUILD%\config.xml"
echo   ^<jar^>TokyoRepacker.jar^</jar^> >> "%BUILD%\config.xml"
echo   ^<outfile^>TokyoRepacker.exe^</outfile^> >> "%BUILD%\config.xml"
echo   ^<errTitle^>TokyoRepacker^</errTitle^> >> "%BUILD%\config.xml"
echo   ^<icon^>TokyoRepacker.ico^</icon^> >> "%BUILD%\config.xml"
echo   ^<chdir^>.^</chdir^> >> "%BUILD%\config.xml"
echo   ^<jre^> >> "%BUILD%\config.xml"
echo     ^<minVersion^>21^</minVersion^> >> "%BUILD%\config.xml"
echo     ^<path^>jre^</path^> >> "%BUILD%\config.xml"
echo     ^<requires64Bit^>true^</requires64Bit^> >> "%BUILD%\config.xml"
echo   ^</jre^> >> "%BUILD%\config.xml"
echo   ^<versionInfo^> >> "%BUILD%\config.xml"
echo     ^<fileVersion^>1.0.0.0^</fileVersion^> >> "%BUILD%\config.xml"
echo     ^<txtFileVersion^>Beta v1.0^</txtFileVersion^> >> "%BUILD%\config.xml"
echo     ^<fileDescription^>TokyoRepacker - WZ Editor^</fileDescription^> >> "%BUILD%\config.xml"
echo     ^<productName^>TokyoRepacker^</productName^> >> "%BUILD%\config.xml"
echo     ^<internalName^>TokyoRepacker^</internalName^> >> "%BUILD%\config.xml"
echo     ^<originalFilename^>TokyoRepacker.exe^</originalFilename^> >> "%BUILD%\config.xml"
echo     ^<productVersion^>1.0.0.0^</productVersion^> >> "%BUILD%\config.xml"
echo     ^<txtProductVersion^>Beta v1.0^</txtProductVersion^> >> "%BUILD%\config.xml"
echo     ^<copyright^>TokyoEric 2026^</copyright^> >> "%BUILD%\config.xml"
echo   ^</versionInfo^> >> "%BUILD%\config.xml"
echo ^</launch4jConfig^> >> "%BUILD%\config.xml"

cd /d "%BUILD%"
"%L4JC%" config.xml
if %ERRORLEVEL% neq 0 echo Launch4j 打包失败 && exit /b 1
echo EXE 已生成（含图标）

echo [3/3] 复制到 %OUTPUT%...
rmdir /s /q "%OUTPUT%" 2>nul
mkdir "%OUTPUT%"
copy "%BUILD%\TokyoRepacker.exe" "%OUTPUT%\" >nul
copy "%PROJ%libcrypto-3-x64.dll" "%OUTPUT%\" >nul
echo language = zh_CN > "%OUTPUT%\config.ini"
REM 复制 JRE
if exist "%TARGET%\jre" (
  mkdir "%OUTPUT%\jre"
  xcopy /e /i /y "%TARGET%\jre\*" "%OUTPUT%\jre\" >nul
)

echo.
echo ======== D:\TokyoRepacker ========
dir /b "%OUTPUT%"
echo ================================
echo 发行版已就绪，TokyoRepacker.exe 已嵌入自定义图标
