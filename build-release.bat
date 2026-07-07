@echo off
REM TokyoRepacker 一键构建脚本
REM 编译 + Launch4j 打包 EXE + 发行版

set JAVA_HOME=D:\Java\jdk-21.0.2
set PATH=%JAVA_HOME%\bin;%PATH%
set MVN=C:\Users\ADMIN\.m2\wrapper\dists\apache-maven-3.9.11\03d7e36a140982eea48e22c1dcac01d8862b2550b2939e09a0809bbc5182a5bc\bin\mvn.cmd

echo === [1/3] Maven 编译+Launch4j打包EXE ===
call %MVN% clean package ^
  -Dmaven.compiler.release= ^
  -Dmaven.compiler.source=21 ^
  -Dmaven.compiler.target=21 ^
  -DskipTests
if %ERRORLEVEL% neq 0 (
  echo 编译失败，退出
  exit /b 1
)

echo === [2/3] 复制发行版到 D:\TokyoRepacker ===
rmdir /s /q D:\TokyoRepacker 2>nul
mkdir D:\TokyoRepacker
copy target\TokyoRepacker.exe D:\TokyoRepacker\
if exist libcrypto-3-x64.dll copy libcrypto-3-x64.dll D:\TokyoRepacker\
echo language = zh_CN > D:\TokyoRepacker\config.ini

echo === [3/3] 打包 ZIP ===
set SZIP="C:\Program Files\7-Zip\7z.exe"
if exist %SZIP% (
  %SZIP% a -tzip target\TokyoRepacker-v1.0.0-Beta.zip D:\TokyoRepacker\* -y
) else (
  echo 7z 未找到，跳过打包
)

echo === 完成 ===
echo 发行版: D:\TokyoRepacker
echo 双击 TokyoRepacker.exe 启动
echo 全新安装需下载 JRE 并放到 D:\TokyoRepacker\jre\
echo (打包时已自动捆绑 JRE 在 target/jre/ 下)
