@echo off
chcp 65001 >nul
REM ============================================
REM TokyoRepacker 发行版构建脚本
REM Maven 编译 + classfinal 加密 + C# 启动器
REM ============================================
set JAVA_HOME=D:\Java\jdk-21.0.2
set PATH=%JAVA_HOME%\bin;%PATH%
set MVN=C:\Users\ADMIN\.m2\wrapper\dists\apache-maven-3.9.11\03d7e36a140982eea48e22c1dcac01d8862b2550b2939e09a0809bbc5182a5bc\bin\mvn.cmd
set CSC=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe
set PROJ=%~dp0
set TARGET=%PROJ%target
set OUTPUT=D:\TokyoRepacker

echo [1/3] Maven 编译 + classfinal 加密...
cd /d "%PROJ%"
call %MVN% clean package -Dmaven.compiler.release= -Dmaven.compiler.source=21 -Dmaven.compiler.target=21 -DskipTests -q
if %ERRORLEVEL% neq 0 echo 编译失败 && exit /b 1

echo [2/3] 编译 C# 启动器（winexe，无窗口）...
"%CSC%" /target:winexe /win32icon:"%PROJ%src\main\resources\icons\TokyoRepacker.ico" /out:"%PROJ%src\launcher\TokyoRepacker.exe" "%PROJ%src\launcher\Launcher.cs" >nul
if %ERRORLEVEL% neq 0 echo C# 编译失败 && exit /b 1

echo [3/3] 复制到 %OUTPUT%...
rmdir /s /q "%OUTPUT%" 2>nul
mkdir "%OUTPUT%"
copy "%PROJ%src\launcher\TokyoRepacker.exe" "%OUTPUT%\" >nul
copy "%TARGET%\data.bin" "%OUTPUT%\" >nul
copy "%PROJ%libcrypto-3-x64.dll" "%OUTPUT%\" >nul
echo language = zh_CN > "%OUTPUT%\config.ini"
if exist "%TARGET%\jre" (
  mkdir "%OUTPUT%\jre"
  xcopy /e /i /y "%TARGET%\jre\*" "%OUTPUT%\jre\" >nul
)
echo.
echo ======== D:\TokyoRepacker ========
dir /b "%OUTPUT%"
echo ================================
echo 发行版已就绪（C# 启动器 + classfinal 加密）
