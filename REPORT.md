# TokyoRepacker 项目分析报告

> 生成日期：2026-07-07  
> 维护者：TokyoEric  
> 仓库：https://github.com/TokyoEric/apple-wz  
> 上游：https://github.com/leevccc/orange-wz  
> 当前版本：**Beta v1.0**

---

## 一、项目定位

TokyoRepacker 是一款 **MapleStory WZ 文件解析/编辑工具**，基于 leevccc/orange-wz 二次开发。

### 三种使用模式

| 模式 | 说明 |
|------|------|
| **桌面 GUI** | Swing 图形界面，浏览/编辑 WZ 文件 |
| **MCP HTTP 服务** | JSON-RPC 协议远程操作，22 个工具 |
| **Java 库** | 直接调用 API 读写 WZ 文件 |

---

## 二、技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Java | 21 | 主语言 |
| Spring Boot | 4.0.0 | 应用框架 + MCP 服务 |
| Lombok | 1.18.42 | 代码简化 |
| Swing + FlatLaf | 3.7 | 桌面 GUI |
| Maven | 3.9+ | 构建工具 |
| Launch4j | 3.50 | EXE 打包（包装模式） |

---

## 三、WZ 解析能力

### 支持的文件格式

.wz、.img（解包）、.xml、目录

### 18 种属性类型

String / Int / Short / Long / Float / Double / Vector / List / Canvas / PNG / Raw / Sound / UOL / Null / Lua / Convex / Extended / Children

### WZ 加密

国服 CMS、国际服 GMS、自定密钥，AES 变形加密

---

## 四、与上游的差异

| 维度 | 上游 (leevccc/orange-wz) | TokyoRepacker |
|------|:---:|:---:|
| 产品名 | OrzRepacker | TokyoRepacker |
| 版本 | v1.162.50 | Beta v1.0 |
| MCP `list_children` | 根节点返回空（缺 parse()） | ✅ 已修复 |
| MCP 自编译启动 | `web-application-type=none` | ✅ `=servlet` |
| Maven 编译 | `--release 21` 与 Lombok 冲突 | ✅ 已知 workaround |
| 类名错误 | Xml2Img2.java 但类名 Xml2Img | ✅ 已修复 |
| 作者署名 | 无 | ✅ README 标注 TokyoEric |
| 自定义图标 | ✅ 有 | ✅ 已嵌入（Launch4j GUI 版编译） |
| 文档 | 仅 README | ✅ GUIDE.md + FEATURES.md 全中文 |

---

## 五、编译打包流程

### 一键构建（完整发行版）

```bash
build-release.bat
```

自动执行：
1. `mvn clean package` — 编译 Java + Spring Boot 打包
2. `launch4jc` — 生成带图标的 EXE（启动模式）
3. 复制到 `D:\TokyoRepacker`

### 手动步骤

```bash
# 1. 编译
mvn clean package -Dmaven.compiler.release= -Dmaven.compiler.source=21 -Dmaven.compiler.target=21 -DskipTests

# 2. 用 Launch4j CLI 打包 EXE
launch4jc config.xml

# 3. 部署
cp TokyoRepacker.exe D:\TokyoRepacker\
cp data.bin D:\TokyoRepacker\
cp libcrypto-3-x64.dll D:\TokyoRepacker\
```

### Maven 编译参数说明

`--release 21` 与 Lombok 不兼容，必须覆写：

```
-Dmaven.compiler.release= -Dmaven.compiler.source=21 -Dmaven.compiler.target=21
```

---

## 六、已知问题

| 问题 | 状态 | 说明 |
|------|:----:|------|
| EXE 自定义图标 | ⚠️ 需 launch4jc 编译 | Maven 插件内置 windres 太老（2011），`--preprocessor=type` 不兼容 |
| Maven 插件包装模式 | ✅ 工作稳定 | 不带自定义图标，Launch4j 默认图标 |
| Launch4j CLI 启动模式 | ⚠️ 可编译但参数传递异常 | 小 EXE + data.bin 结构，GUI 正常但 MCP 无头模式参数不生效 |
| Java 21 依赖 | ✅ 自带 jre/ | 双击即用，无需系统预装 Java |

---

## 七、发行版

### 当前版本：Beta v1.0

| 版本 | 大小 | 内容 |
|------|:----:|------|
| `TokyoRepacker-v1.0.0-Beta.zip` | **212 MB** | 含 JRE，完整绿色版 |
| `TokyoRepacker-v1.0.0-Beta-lite.zip` | **25 MB** | 不含 JRE（需系统安装 JDK 21） |
| `Environment.7z`（待制作） | ~200 MB | JRE 独立包（首次使用下载） |

### D:\TokyoRepacker 结构

```
D:\TokyoRepacker\
├── TokyoRepacker.exe   (25MB)   双击运行
├── data.bin            (25MB)   程序本体
├── libcrypto-3-x64.dll (7MB)    WZ 加解密
├── config.ini                  语言配置
└── jre/bin/java.exe             JDK 21（运行环境）
```

---

## 八、项目文档

| 文档 | 内容 |
|------|------|
| `README.md` | 项目首页、快速安装 |
| `GUIDE.md` | 开发指南、编译流程、架构说明、常见问题 |
| `FEATURES.md` | 完整功能清单（解析引擎/GUI/MCP/配置） |

---

> 本报告由 Hermes Agent 自动生成
