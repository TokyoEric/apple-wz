# TokyoRepacker — 项目开发指南

> 基于 [leevccc/orange-wz](https://github.com/leevccc/orange-wz) 二次开发  
> Fork 维护 / 二次开发作者：[TokyoEric](https://github.com/TokyoEric)  
> 仓库：https://github.com/TokyoEric/apple-wz  
> 上游：https://github.com/leevccc/orange-wz  
> 当前版本：**Beta v1.0**

---

## 目录

- [1. 项目概述](#1-项目概述)
- [2. 技术栈](#2-技术栈)
- [3. 项目结构](#3-项目结构)
- [4. 编译说明](#4-编译说明)
- [5. 运行说明](#5-运行说明)
- [6. MCP 服务](#6-mcp-服务)
- [7. 二次开发流程](#7-二次开发流程)
- [8. 与上游的差异](#8-与上游的差异)
- [9. 常见问题](#9-常见问题)

---

## 1. 项目概述

TokyoRepacker 是一款 **冒险岛 WZ 文件解析/编辑工具**，提供三种使用模式：

| 模式 | 说明 | 启动方式 |
|------|------|---------|
| **桌面工具（图形界面）** | WZ 文件浏览器/编辑器 | `TokyoRepacker.exe` 或 `TokyoRepacker.bat` |
| **MCP 服务（HTTP 接口）** | 通过网络远程操作 WZ 文件，共 22 个工具 | 启动时加参数 `--orange.gui.enabled=false` |
| **Java 库** | 直接在代码中调用 API 读写 WZ 文件 | 添加 Maven 依赖 |

支持 WZ 版本：**国际服 v83**、**国服 v079**（.img 解包格式）、**台服/韩服/日服**等经典版本。

---

## 2. 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Java | 21（JDK 21+） | 主语言 |
| Spring Boot | 4.0.0 | 应用框架 + MCP 服务 |
| Lombok | 1.18.42 | 简化代码（自动生成 Getter/Setter 等） |
| Swing + FlatLaf | 3.7 | 桌面图形界面（扁平化主题） |
| Jackson | 2.15.2 / 3.0.2 | JSON 序列化（MCP 协议用） |
| Gson | 2.10.1 | JSON 工具 |
| Maven | 3.9 以上 | 构建工具 |
| classfinal | 1.2.1 | JAR 加密（打包时用） |
| MP3SPI / JLayer | — | 音频解码（播放 WZ 中的背景音乐） |

---

## 3. 项目结构

```
TokyoRepacker/
├── pom.xml                           # Maven 构建配置
├── TokyoRepacker.bat                 # Windows 启动脚本
├── libcrypto-3-x64.dll               # OpenSSL（WZ 加解密用）
├── keys.dat                          # WZ 密钥库（图形界面加载用）
├── config.ini                        # 用户配置（语言等）
├── .gitignore
│
├── src/main/java/orange/wz/
│   │
│   ├── OrangeWzApplication.java      # Spring Boot 启动入口
│   ├── Xml2Img2.java                 # XML→IMG 转换工具（独立运行）
│   │
│   ├── provider/                     # ★ WZ 文件解析核心
│   │   ├── WzFile.java              # .wz 文件（加密二进制格式）
│   │   ├── WzImageFile.java         # .img 文件（解包格式）
│   │   ├── WzXmlFile.java           # .xml WZ 数据
│   │   ├── WzImage.java             # WZ 中的 Image 节点（含解析逻辑）
│   │   ├── WzDirectory.java         # WZ 目录节点
│   │   ├── WzFolder.java            # 文件系统文件夹节点
│   │   ├── WzImageProperty.java     # 属性节点（字符串/整数/向量等）
│   │   ├── WzObject.java            # 所有 WZ 节点的基类
│   │   ├── WzHeader.java            # WZ 文件头
│   │   ├── WzAESConstant.java       # 加密常量（IV 和密钥）
│   │   ├── WzSavableFile.java       # 可保存文件接口
│   │   ├── properties/              # 各种属性类型实现
│   │   │   ├── WzStringProperty.java
│   │   │   ├── WzIntProperty.java
│   │   │   ├── WzListProperty.java
│   │   │   ├── WzCanvasProperty.java
│   │   │   ├── WzPngProperty.java
│   │   │   ├── WzSoundProperty.java
│   │   │   ├── WzUOLProperty.java
│   │   │   └── WzLuaProperty.java
│   │   ├── audio/                   # 音频解码
│   │   └── tools/                   # 工具类
│   │       ├── BinaryReader.java    # WZ 二进制读取（含解密）
│   │       ├── BinaryWriter.java    # WZ 二进制写入
│   │       ├── WzFileStatus.java    # 文件解析状态
│   │       └── wzkey/               # WZ 密钥管理
│   │
│   ├── mcp/                         # ★ MCP 服务
│   │   ├── http/
│   │   │   ├── McpHttpController.java     # 接口端点
│   │   │   ├── McpHttpConfig.java         # HTTP 配置
│   │   │   ├── JsonRpcResponse.java       # 响应格式
│   │   │   ├── McpSseSessionRegistry.java # 会话注册
│   │   │   └── McpToolDescriptor.java     # 工具描述
│   │   ├── server/
│   │   │   └── McpServerBootstrap.java    # 服务启动引导
│   │   ├── service/
│   │   │   ├── McpWorkspaceService.java   # 工作空间接口
│   │   │   └── impl/DefaultMcpWorkspaceService.java  # ★ 实现（含我们的修复）
│   │   ├── session/
│   │   │   ├── McpSessionManager.java     # 会话管理器
│   │   │   └── McpSessionState.java       # 会话状态
│   │   ├── resolve/
│   │   │   └── NodePathResolver.java      # 节点路径解析
│   │   ├── tool/
│   │   │   ├── McpTool.java              # 工具接口
│   │   │   ├── McpToolRegistry.java      # 工具注册表
│   │   │   ├── support/                  # 工具基类和辅助
│   │   │   └── impl/                     # ★ 22 个工具实现
│   │   │       ├── LoadFilesTool.java
│   │   │       ├── ListChildrenTool.java
│   │   │       ├── FindNodeTool.java
│   │   │       ├── ...
│   │   ├── dto/                      # 数据传输对象
│   │   └── ui/
│   │       └── McpUiBridge.java      # MCP↔图形界面桥接
│   │
│   ├── gui/                          # ★ 桌面图形界面
│   │   ├── MainFrame.java           # 主窗口
│   │   ├── Icons.java               # 图标
│   │   ├── component/
│   │   │   ├── panel/               # 面板（树、编辑区等）
│   │   │   ├── menu/                # 右键菜单
│   │   │   ├── form/                # 属性编辑表单
│   │   │   ├── dialog/              # 对话框
│   │   │   ├── canvas/              # 画布（图片预览等）
│   │   │   └── key/                 # 密钥管理
│   │   └── filter/                  # 文件过滤器
│   │
│   ├── config/
│   │   ├── CorsConfig.java          # 跨域配置
│   │   └── WebMvcConfig.java        # Web 配置
│   ├── controller/                  # 普通接口控制器
│   ├── manager/
│   │   └── ServerManager.java       # Spring 管理器 / 版本读取
│   ├── model/                       # 数据模型
│   ├── exception/                   # 异常定义
│   └── log/                         # 日志配置
│
├── src/main/resources/
│   ├── application.properties       # ★ 应用配置（关键）
│   ├── logback-spring.xml           # 日志配置
│   ├── i18n/                        # 国际化
│   │   ├── messages_zh_CN.properties
│   │   └── messages_en_US.properties
│   └── icons/                       # 图标资源
│
└── src/test/                        # 测试
```

---

## 4. 编译说明

### 4.1 前置要求

- **JDK 21**（推荐 `D:\Java\jdk-21.0.2`）
- **Maven 3.9 以上**（项目自带 `mvnw.cmd`）
- **IntelliJ IDEA 2023.3 以上**（推荐，也可以用命令行编译）

### 4.2 命令行编译

Spring Boot 4.0.0 的父 POM 会把 `<java.version>21` 变成编译参数 `--release 21`，这个参数会导致 Lombok 无法正常工作。解决方法是在编译时覆盖它：

```bash
# 编译（跳过 --release 参数）
mvn clean compile ^
  -Dmaven.compiler.release= ^
  -Dmaven.compiler.source=21 ^
  -Dmaven.compiler.target=21

# 打包（含加密 + JRE 捆绑）
mvn clean package ^
  -Dmaven.compiler.release= ^
  -Dmaven.compiler.source=21 ^
  -Dmaven.compiler.target=21 ^
  -DskipTests
```

**打包产物：**
- `target/TokyoRepacker.jar` — classfinal 加密后的可执行 JAR
- `target/TokyoRepacker-bundle.zip` — 含 JRE 的完整发布包
- `target/TokyoRepacker-encrypted.jar` — 加密中间产物

### 4.3 IDEA 编译

1. 打开 IDEA，`File → Open` 选择 `pom.xml`
2. `File → Project Structure → SDK`，添加 JDK 21
3. `Settings → Build → Compiler → Annotation Processors`，勾选 **启用注解处理**
4. `Build → Build Project`（或按 Ctrl+F9）

---

## 5. 运行说明

### 5.1 图形界面模式（桌面工具）

```bash
# 直接双击 OrzRepacker.exe（Release 版）
# 或者通过编译产物：
java -jar target/TokyoRepacker.jar
```

### 5.2 无头模式（仅 MCP 服务，不显示窗口）

```bash
# 方法一：通过 classpath 启动（推荐，包含我们的修复）
mvn dependency:build-classpath -Dmdep.outputFile=cp.txt ^
  -Dmaven.compiler.release= ^
  -Dmaven.compiler.source=21 ^
  -Dmaven.compiler.target=21

java -cp "target/classes;%CP%" ^
  orange.wz.OrangeWzApplication ^
  --spring.main.web-application-type=servlet ^
  --orange.gui.enabled=false ^
  --server.port=10003

# 方法二：通过 JAR 启动（Release 版 JAR 有 classfinal 加密，需加 -p# 密码）
java -jar target/TokyoRepacker.jar -p# ^
  --spring.main.web-application-type=servlet ^
  --orange.gui.enabled=false ^
  --server.port=10003
```

### 5.3 WZ 密钥说明

加载 WZ 文件时，需要指定加密密钥。**国服标准密钥：**

| 参数 | 值 |
|------|-----|
| ivBase64 | `uX1j6Q==` |
| userKeyBase64 | `EwAAAFIAAAAqAAAAWwAAAAgAAAACAAAAEAAAAGAAAAAGAAAAAgAAAEMAAAAPAAAAtAAAAEsAAAA1AAAABQAAABsAAAAKAAAAXwAAAAkAAAAPAAAAUAAAAAwAAAAbAAAAMwAAAFUAAAABAAAACQAAAFIAAADeAAAAxwAAAB4AAAA=` |

> ⚠️ 注意：userKey 必须是 **128 字节**（base64 编码后 172 个字符），长度不对会报 `Index XX out of bounds for length 99`。国际服的 IV 是 `{0x4D, 0x23, 0xC7, 0x2B}`。

---

## 6. MCP 服务

### 6.1 协议说明

MCP 使用 **JSON-RPC 2.0** 协议，通过 HTTP POST 发送到 `http://127.0.0.1:10002/mcp`。

### 6.2 调用流程

**步骤 1：初始化（获取会话 ID）**

```bash
curl -s -D - http://127.0.0.1:10002/mcp -X POST ^
  -H "Content-Type: application/json" ^
  -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2025-03-26\",\"capabilities\":{},\"clientInfo\":{\"name\":\"my-client\",\"version\":\"1.0\"}}}"
# 响应头会返回: Mcp-Session-Id: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

**步骤 2：列出可用工具**

```bash
curl -s http://127.0.0.1:10002/mcp -X POST ^
  -H "Content-Type: application/json" ^
  -H "Mcp-Session-Id: {会话ID}" ^
  -d "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/list\",\"params\":{}}"
```

**步骤 3：调用工具**

```bash
curl -s http://127.0.0.1:10002/mcp -X POST ^
  -H "Content-Type: application/json" ^
  -H "Mcp-Session-Id: {会话ID}" ^
  -d "{\"jsonrpc\":\"2.0\",\"id\":3,\"method\":\"tools/call\",\"params\":{\"name\":\"load_files\",\"arguments\":{\"paths\":[\"C:/Data/Mob.img\"],\"key\":{\"name\":\"CMS\",\"ivBase64\":\"uX1j6Q==\",\"userKeyBase64\":\"...\"}}}}"
```

### 6.3 可用工具（共 22 个）

| 分类 | 工具名 | 说明 |
|------|--------|------|
| **加载/卸载** | `load_files` | 加载 .wz/.img/.xml 文件或目录 |
| | `list_loaded_roots` | 列出已加载的根节点 |
| | `unload_node` | 卸载指定节点 |
| | `unload_all` | 卸载所有节点 |
| | `create_wz_file` | 创建新的 .wz 文件 |
| | `create_img_file` | 创建新的 .img 文件 |
| **查询** | `list_children` | 列出子节点 |
| | `find_node` | 按路径查找节点 |
| | `get_node_detail` | 获取节点详细信息和值 |
| | `get_node_tree_json` | 获取节点及其子节点的 JSON 树 |
| | `search_node` | 按关键字搜索节点 |
| | `batch_find_nodes` | 批量查找 |
| | `query_nodes` | 统一查询入口 |
| **修改** | `create_child_node` | 创建子节点 |
| | `delete_node` | 删除节点 |
| | `copy_nodes` | 复制节点到剪贴板 |
| | `paste_nodes` | 从剪贴板粘贴 |
| | `mutate_nodes` | 统一写入入口 |
| | `batch_update_nodes` | 批量更新 |
| **保存** | `save_node` | 保存文件 |
| | `save_as` | 另存为 |
| **其他** | `ping` | 心跳检测 |

---

## 7. 二次开发流程

### 7.1 仓库管理

```bash
# 查看当前远程仓库：
git remote -v
# origin    → https://github.com/TokyoEric/apple-wz.git（我们推送用）
# upstream  → https://github.com/leevccc/orange-wz.git（拉取原版更新用）

# 拉取原版最新功能
git fetch upstream
git rebase upstream/main

# 推送我们的更新
git push origin main
```

### 7.2 添加新的 MCP 工具

1. 在 `mcp/tool/impl/` 目录下创建新类，实现 `McpTool` 接口（或继承 `BaseSessionTool`）
2. 在 `McpToolRegistry.java` 中注册
3. 编译验证，重启 MCP 服务

### 7.3 处理上游合并冲突

以下文件包含我们的修改，合并时需特别注意：

| 文件 | 我们的修改 |
|------|-----------|
| `application.properties` | `web-application-type=none` 改为 `servlet` |
| `DefaultMcpWorkspaceService.java` | `getChildren()` 中加了 `image.parse()` |
| `Xml2Img2.java` | 类名从 `Xml2Img` 改为 `Xml2Img2` |
| `pom.xml` | `finalName`、`version`、`name`、`description` |

---

## 8. 与上游的差异

| 维度 | 上游 (leevccc/orange-wz) | TokyoRepacker |
|------|:---:|:---:|
| 产品名 | OrzRepacker | TokyoRepacker |
| 版本 | v1.162.50 | Beta v1.0 |
| MCP 查子节点 | ❌ 根节点返回空（漏了 `parse()`） | ✅ 已修复 |
| MCP 自编译启动 | ❌ 默认关掉网页服务器 | ✅ 默认开启 |
| Maven 编译 | ❌ `--release 21` 与 Lombok 冲突 | ✅ 已知解决方法 |
| 类名错误 | ❌ 文件名 `Xml2Img2.java` 但类名叫 `Xml2Img` | ✅ 已修复 |
| 作者信息 | 无 | ✅ README 标注 TokyoEric |

---

## 9. 常见问题

### 问：Maven 编译报 Lombok 错误？

**原因**：Spring Boot 4.0.0 父 POM 的 `--release 21` 参数和 Lombok 不兼容。  
**解决**：编译时加上参数 `-Dmaven.compiler.release= -Dmaven.compiler.source=21 -Dmaven.compiler.target=21`。

### 问：MCP 服务启动后报 `Index XX out of bounds for length 99`？

**原因**：WZ 密钥的 userKey 长度不对（必须是 128 字节）。  
**解决**：用上面提供的国服标准密钥。

### 问：`list_children` 返回空列表？

**原因**：原版代码在 `DefaultMcpWorkspaceService.getChildren()` 中忘了调用 `WzImage.parse()`。  
**解决**：已在我们的分支中修复。如果用 Release 版，需要换成自编译版本。

### 问：IDEA 编译报 `java: 类 Xml2Img 是公共的...`？

**原因**：文件名是 `Xml2Img2.java`，但类名声明写的是 `Xml2Img`。  
**解决**：已在我们的分支中修复。

### 问：怎么知道 WZ 文件中某个节点在哪个路径？

用 `list_children` 逐层展开，或用 `search_node` 按关键字搜索。  
`get_node_tree_json` 可以一次获取指定深度的完整树结构。

---

> 最后更新：2026-07-07  
> 维护者：[TokyoEric](https://github.com/TokyoEric)
