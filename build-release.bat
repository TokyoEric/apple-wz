@echo off
REM ============================================
REM TokyoRepacker 完整构建脚本
REM 1. Maven 编译 + 打包
REM 2. 生成 .exe 启动器（Launch4j / jpackage）
REM 3. 打包为 .7z 发行版
REM ============================================
setlocal enabledelayedexpansion

set JAVA_HOME=D:\Java\jdk-21.0.2
set PATH=%JAVA_HOME%\bin;%PATH%
set MVN=C:\Users\ADMIN\.m2\wrapper\dists\apache-maven-3.9.11\03d7e36a140982eea48e22c1dcac01d8862b2550b2939e09a0809bbc5182a5bc\bin\mvn.cmd

echo === [1/4] Maven 编译与打包 ===
call %MVN% clean package ^
  -Dmaven.compiler.release= ^
  -Dmaven.compiler.source=21 ^
  -Dmaven.compiler.target=21 ^
  -DskipTests
if %ERRORLEVEL% neq 0 (
  echo 编译失败，退出
  exit /b 1
)

echo === [2/4] 准备发行文件 ===
set DIST_DIR=target\TokyoRepacker-release
set TARGET_DIR=target
rmdir /s /q %DIST_DIR% 2>nul
mkdir %DIST_DIR%

REM 复制加密后的 JAR
copy %TARGET_DIR%\TokyoRepacker.jar %DIST_DIR%\data.bin
if exist libcrypto-3-x64.dll copy libcrypto-3-x64.dll %DIST_DIR%\
echo libcrypto-3-x64.dll> %DIST_DIR%\.gitkeep

echo === [3/4] 生成 EXE 启动器（jpackage） ===
REM jpackage 需要模块化 JAR，TokyoRepacker 不是模块化项目
REM 使用 jlink 制作精简 JRE + jar 启动方式
mkdir %DIST_DIR%\jre 2>nul
xcopy /e /i /y %TARGET_DIR%\jre %DIST_DIR%\jre\

REM 创建启动脚本
echo @echo off > %DIST_DIR%\TokyoRepacker.bat
echo title TokyoRepacker>> %DIST_DIR%\TokyoRepacker.bat
echo jre\bin\java -javaagent:data.bin -jar data.bin>> %DIST_DIR%\TokyoRepacker.bat
echo 启动脚本已生成

echo === [4/4] 打包发行版 ===
REM 检查 7z
set SZIP="C:\Program Files\7-Zip\7z.exe"
if exist %SZIP% (
  %SZIP% a -tzip target\TokyoRepacker-windows.zip %DIST_DIR%\* -y
  echo ZIP 包已生成: target\TokyoRepacker-windows.zip
) else (
  echo 7z 未找到，跳过打包
)

echo === 完成 ===
echo 发行目录: %DIST_DIR%
echo 运行方式: %DIST_DIR%\TokyoRepacker.bat
echo 手工打包: 将 %DIST_DIR%\ 目录压缩为 .7z 或 .zip 发布
