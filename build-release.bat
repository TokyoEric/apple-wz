@echo off
chcp 65001 >nul
set JAVA_HOME=D:\Java\jdk-21.0.2
set PATH=%JAVA_HOME%\bin;%PATH%
set MVN=C:\Users\ADMIN\.m2\wrapper\dists\apache-maven-3.9.11\03d7e36a140982eea48e22c1dcac01d8862b2550b2939e09a0809bbc5182a5bc\bin\mvn.cmd
set PROJ=%~dp0
set TARGET=%PROJ%target
set OUTPUT=D:\TokyoRepacker
set L4J=%USERPROFILE%\.m2\repository\net\sf\launch4j\launch4j\3.50

echo [1/4] Maven package...
cd /d "%PROJ%"
call %MVN% clean package -Dmaven.compiler.release= -Dmaven.compiler.source=21 -Dmaven.compiler.target=21 -DskipTests -q
if %ERRORLEVEL% neq 0 exit /b 1

echo [2/4] Launch4j 创建启动器...
copy /y "%TARGET%\TokyoRepacker.jar" "%TARGET%\data.bin" >nul
java -cp "%L4J%\launch4j-3.50-core.jar;%L4J%\launch4j-3.50-workdir-win32.jar" net.sf.launch4j.Main "%PROJ%launch4j.xml" >nul
if %ERRORLEVEL% neq 0 echo Launch4j FAIL && exit /b 1

echo [3/4] 复制到 D:\TokyoRepacker...
rmdir /s /q "%OUTPUT%" 2>nul
mkdir "%OUTPUT%"
copy "%TARGET%\TokyoRepacker.exe" "%OUTPUT%\" >nul
copy "%TARGET%\data.bin" "%OUTPUT%\" >nul
copy "%PROJ%libcrypto-3-x64.dll" "%OUTPUT%\" >nul
echo language = zh_CN > "%OUTPUT%\config.ini"
if exist "%TARGET%\jre" xcopy /e /i /y "%TARGET%\jre" "%OUTPUT%\jre\" >nul

echo [4/4] 打包 ZIP...
if exist "C:\Program Files\7-Zip\7z.exe" (
  "C:\Program Files\7-Zip\7z.exe" a -tzip "%TARGET%\TokyoRepacker-v1.0.0-Beta.zip" "%OUTPUT%\*" -y >nul
)
echo OK

echo.
echo ======== D:\TokyoRepacker ========
dir /b "%OUTPUT%"
if exist "%OUTPUT%\jre" echo jre\
echo ================================
echo 发行版已就绪
