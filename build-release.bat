@echo off
chcp 65001 >nul
set JAVA_HOME=D:\Java\jdk-21.0.2
set PATH=%JAVA_HOME%\bin;%PATH%
set MVN=C:\Users\ADMIN\.m2\wrapper\dists\apache-maven-3.9.11\03d7e36a140982eea48e22c1dcac01d8862b2550b2939e09a0809bbc5182a5bc\bin\mvn.cmd
set PROJ=%~dp0
set TARGET=%PROJ%target
set OUTPUT=D:\TokyoRepacker

echo [1/3] Maven 编译+打包...
cd /d "%PROJ%"
call %MVN% clean package -Dmaven.compiler.release= -Dmaven.compiler.source=21 -Dmaven.compiler.target=21 -DskipTests -q
if %ERRORLEVEL% neq 0 echo 编译失败 && exit /b 1
echo OK

echo [2/3] 复制到 %OUTPUT%...
rmdir /s /q "%OUTPUT%" 2>nul
mkdir "%OUTPUT%"
copy "%TARGET%\TokyoRepacker.exe" "%OUTPUT%\" >nul
copy "%PROJ%libcrypto-3-x64.dll" "%OUTPUT%\" >nul
echo language = zh_CN > "%OUTPUT%\config.ini"
REM 复制 JRE（注意：直接复制目录内容，不能多嵌套一层）
if exist "%TARGET%\jre" (
  mkdir "%OUTPUT%\jre"
  xcopy /e /i /y "%TARGET%\jre\*" "%OUTPUT%\jre\" >nul
)
echo OK

echo [3/3] 打包 ZIP...
if exist "C:\Program Files\7-Zip\7z.exe" (
  "C:\Program Files\7-Zip\7z.exe" a -tzip "%TARGET%\TokyoRepacker-v1.0.0-Beta.zip" "%OUTPUT%\*" -y >nul
  echo ZIP 已生成
)

echo.
echo ======== D:\TokyoRepacker ========
dir /b "%OUTPUT%"
echo ================================
echo 发行版已就绪
echo 双击 TokyoRepacker.exe 启动（需 jre\ 目录中有 Java）
