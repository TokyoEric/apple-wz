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

TokyoRepacker 是一款 **MapleStory WZ 文件解析/编辑工具**，提供三种使用模式：

| 模式 | 说明 | 启动方式 |
|------|------|---------|
| **GUI 桌面工具** | WZ 文件浏览器/编辑器，Swing 界面 | `TokyoRepacker.exe` 或 `TokyoRepacker.bat` |
| **MCP HTTP 服务** | 通过 JSON-RPC 协议远程操作 WZ 文件，22 个工具 | `--orange.gui.enabled=false` |
| **Java 库** | 直接调用 API 读取/修改 WZ 文件 | Maven 依赖 |

支持 WZ 格式：**GMS v83**、**CMS v079**（.img 解包格式）、**TMS/KMS/JMS** 等经典版本。

---

## 2. 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Java | 21 (JDK 21+) | 主语言 |
| Spring Boot | 4.0.0 | 应用框架 + MCP HTTP 服务 |
| Lombok | 1.18.42 | 代码简化（@Getter/@Setter/@Slf4j） |
| Swing + FlatLaf | 3.7 | 桌面 GUI（扁平化主题） |
| Jackson | 2.15.2 / 3.0.2 | JSON 序列化（MCP 协议） |
| Gson | 2.10.1 | JSON 工具 |
| Maven | 3.9+ | 构建工具 |
| classfinal | 1.2.1 | JAR 加密（打包时） |
| MP3SPI / JLayer | — | 音频解码（WZ 背景音乐） |

---

## 3. 项目结构

```
TokyoRepacker/
├── pom.xml                           # Maven 构建配置
├── TokyoRepacker.bat                 # Windows 启动脚本
├── libcrypto-3-x64.dll               # OpenSSL（WZ 加密解密）
├── keys.dat                          # WZ 密钥库（GUI 加载用）
├── config.ini                        # 用户配置（语言等）
├── .gitignore
│
├── src/main/java/orange/wz/
│   │
│   ├── OrangeWzApplication.java      # Spring Boot 入口
│   ├── Xml2Img2.java                 # XML→IMG 转换工具（独立）
│   │
│   ├── provider/                     # ★ WZ 文件解析核心
│   │   ├── WzFile.java              # .wz 文件（加密二进制格式）
│   │   ├── WzImageFile.java         # .img 文件（解包格式，extends WzImage）
│   │   ├── WzXmlFile.java           # .xml WZ 数据
│   │   ├── WzImage.java             # WZ image 节点（含 parse 逻辑）
│   │   ├── WzDirectory.java         # WZ 目录节点
│   │   ├── WzFolder.java            # 文件系统文件夹节点
│   │   ├── WzImageProperty.java     # 属性节点（字符串/整数/向量等）
│   │   ├── WzObject.java            # 所有 WZ 节点的基类
│   │   ├── WzHeader.java            # WZ 文件头
│   │   ├── WzAESConstant.java       # 加密常量（IV/DEFAULT_KEY）
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
│   │       ├── WzFileStatus.java    # 文件解析状态枚举
│   │       └── wzkey/               # WZ 密钥管理
│   │
│   ├── mcp/                         # ★ MCP HTTP 服务
│   │   ├── http/
│   │   │   ├── McpHttpController.java     # HTTP 端点（POST/GET/DELETE）
│   │   │   ├── McpHttpConfig.java         # HTTP 配置
│   │   │   ├── JsonRpcResponse.java       # JSON-RPC 响应模型
│   │   │   ├── McpSseSessionRegistry.java # SSE 会话注册
│   │   │   └── McpToolDescriptor.java     # 工具描述
│   │   ├── server/
│   │   │   └── McpServerBootstrap.java    # MCP 服务引导
│   │   ├── service/
│   │   │   ├── McpWorkspaceService.java   # MCP 工作空间接口
│   │   │   └── impl/DefaultMcpWorkspaceService.java  # ★ 实现（含我们修复）
│   │   ├── session/
│   │   │   ├── McpSessionManager.java     # 会话管理器
│   │   │   └── McpSessionState.java       # 会话状态
│   │   ├── resolve/
│   │   │   └── NodePathResolver.java      # 节点路径解析
│   │   ├── tool/
│   │   │   ├── McpTool.java              # 工具接口
│   │   │   ├── McpToolRegistry.java      # 工具注册表
│   │   │   ├── support/                  # 工具基类/辅助
│   │   │   └── impl/                     # ★ 22 个工具实现
│   │   │       ├── LoadFilesTool.java
│   │   │       ├── ListChildrenTool.java
│   │   │       ├── FindNodeTool.java
│   │   │       ├── GetNodeDetailTool.java
│   │   │       ├── GetNodeTreeJsonTool.java
│   │   │       ├── SearchNodeTool.java
│   │   │       ├── QueryNodesTool.java
│   │   │       ├── CreateChildNodeTool.java
│   │   │       ├── DeleteNodeTool.java
│   │   │       ├── CopyNodesTool.java
│   │   │       ├── PasteNodesTool.java
│   │   │       ├── MutateNodesTool.java
│   │   │       ├── SaveNodeTool.java
│   │   │       ├── SaveNodeAsTool.java
│   │   │       ├── ...（共 22 个）
│   │   ├── dto/                      # 数据传输对象
│   │   └── ui/
│   │       └── McpUiBridge.java      # MCP↔GUI 桥接
│   │
│   ├── gui/                          # ★ 桌面 GUI（Swing）
│   │   ├── MainFrame.java           # 主窗口
│   │   ├── Icons.java               # 图标
│   │   ├── component/
│   │   │   ├── panel/               # 面板（树、编辑区等）
│   │   │   ├── menu/                # 右键菜单
│   │   │   ├── form/                # 属性编辑表单
│   │   │   ├── dialog/              # 对话框
│   │   │   ├── canvas/              # 画布（PNG 预览等）
│   │   │   └── key/                 # 密钥管理
│   │   └── filter/                  # 文件过滤器
│   │
│   ├── config/
│   │   ├── CorsConfig.java          # CORS 配置
│   │   └── WebMvcConfig.java        # Web MVC 配置
│   ├── controller/                  # 普通 REST 控制器
│   ├── manager/
│   │   └── ServerManager.java       # Spring Bean 管理器 / 版本读取
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
- **Maven 3.9+**（项目自带 `mvnw.cmd` wrapper）
- **IntelliJ IDEA 2023.3+**（推荐，也可命令行编译）

### 4.2 命令行编译（绕过 Lombok / --release 21 冲突）

Spring Boot 4.0.0 父 POM 将 `<java.version>21` 映射为 `javac --release 21`，该 flag 会禁止 Lombok 访问编译器内部 API。解决方法是在编译时覆写：

```bash
# 编译（跳过 --release）
mvn clean compile \
  -Dmaven.compiler.release= \
  -Dmaven.compiler.source=21 \
  -Dmaven.compiler.target=21

# 打包（含加密 + JRE 捆绑）
mvn clean package \
  -Dmaven.compiler.release= \
  -Dmaven.compiler.source=21 \
  -Dmaven.compiler.target=21 \
  -DskipTests
```

**输出产物：**
- `target/TokyoRepacker.jar` — classfinal 加密后的可执行 JAR
- `target/TokyoRepacker-bundle.zip` — 含 JRE 的全量发布包
- `target/TokyoRepacker-encrypted.jar` — 加密中间产物

### 4.3 IDEA 编译

1. `File → Open` 选择 `pom.xml`
2. `File → Project Structure → SDK` → 添加 JDK 21
3. `Settings → Build → Compiler → Annotation Processors` → 勾选 **Enable annotation processing**
4. `Build → Build Project`（Ctrl+F9）

---

## 5. 运行说明

### 5.1 GUI 模式（桌面工具）

```bash
# 直接双击 OrzRepacker.exe（Release 版）
# 或通过编译产物：
java -jar target/TokyoRepacker.jar
```

### 5.2 无头模式（MCP 服务，无 GUI）

```bash
# 方法 A：通过 classpath 启动（推荐，含我们修复的 bugfix）
mvn dependency:build-classpath -Dmdep.outputFile=cp.txt \
  -Dmaven.compiler.release= \
  -Dmaven.compiler.source=21 \
  -Dmaven.compiler.target=21

java -cp "target/classes;$(cat cp.txt)" \
  orange.wz.OrangeWzApplication \
  --spring.main.web-application-type=servlet \
  --orange.gui.enabled=false \
  --server.port=10003

# 方法 B：通过 JAR 启动（Release 版 JAR 有 classfinal 加密，需要 -p# 密码）
java -jar target/TokyoRepacker.jar -p# \
  --spring.main.web-application-type=servlet \
  --orange.gui.enabled=false \
  --server.port=10003
```

### 5.3 WZ 密钥说明

加载 WZ 文件时必须传入加密密钥。**CMS（国服）标准密钥：**

| 参数 | 值 |
|------|-----|
| ivBase64 | `uX1j6Q==` |
| userKeyBase64 | `EwAAAFIAAAAqAAAAWwAAAAgAAAACAAAAEAAAAGAAAAAGAAAAAgAAAEMAAAAPAAAAtAAAAEsAAAA1AAAABQAAABsAAAAKAAAAXwAAAAkAAAAPAAAAUAAAAAwAAAAbAAAAMwAAAFUAAAABAAAACQAAAFIAAADeAAAAxwAAAB4AAAA=` |

> ⚠️ 注意：userKey 必须为 **128 字节**（base64 172 字符），长度不对会导致 `Index XX out of bounds for length 99` 错误。GMS 的 IV 为 `{0x4D, 0x23, 0xC7, 0x2B}`。

---

## 6. MCP 服务

### 6.1 协议

MCP 使用 **JSON-RPC 2.0** 协议，HTTP POST 到 `http://127.0.0.1:10002/mcp`。

### 6.2 流程

**Step 1：初始化（获取 Session ID）**

```bash
curl -s -D - http://127.0.0.1:10002/mcp -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc":"2.0","id":1,"method":"initialize",
    "params":{
      "protocolVersion":"2025-03-26",
      "capabilities":{},
      "clientInfo":{"name":"my-client","version":"1.0"}
    }
  }'
# 响应头: Mcp-Session-Id: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

**Step 2：列出可用工具**

```bash
curl -s http://127.0.0.1:10002/mcp -X POST \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: {sessionId}" \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'
```

**Step 3：调用工具**

```bash
curl -s http://127.0.0.1:10002/mcp -X POST \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: {sessionId}" \
  -d '{
    "jsonrpc":"2.0","id":3,"method":"tools/call",
    "params":{
      "name":"load_files",
      "arguments":{
        "paths":["/path/to/Mob.img"],
        "key":{"name":"CMS","ivBase64":"uX1j6Q==","userKeyBase64":"..."}
      }
    }
  }'
```

### 6.3 可用工具（22 个）

| 分类 | 工具名 | 说明 |
|------|--------|------|
| **加载/卸载** | `load_files` | 加载 .wz/.img/.xml 文件或目录 |
| | `list_loaded_roots` | 列出已加载根节点 |
| | `unload_node` | 卸载指定节点 |
| | `unload_all` | 卸载全部 |
| | `create_wz_file` | 创建新 .wz 文件 |
| | `create_img_file` | 创建新 .img 文件 |
| **查询** | `list_children` | 列子节点 |
| | `find_node` | 按路径查找 |
| | `get_node_detail` | 获取节点详情/值 |
| | `get_node_tree_json` | 获取节点 JSON 树 |
| | `search_node` | 关键字搜索 |
| | `batch_find_nodes` | 批量查找 |
| | `query_nodes` | 统一查询入口 |
| **修改** | `create_child_node` | 创建子节点 |
| | `delete_node` | 删除节点 |
| | `copy_nodes` | 复制节点 |
| | `paste_nodes` | 粘贴节点 |
| | `mutate_nodes` | 统一写入入口 |
| | `batch_update_nodes` | 批量更新 |
| **保存** | `save_node` | 保存文件 |
| | `save_as` | 另存为 |
| **其他** | `ping` | 心跳检测 |

---

## 7. 二次开发流程

### 7.1 仓库管理

```bash
# 已有本地仓库：
git remote -v
# origin    → https://github.com/TokyoEric/apple-wz.git（推送）
# upstream  → https://github.com/leevccc/orange-wz.git（拉取）

# 拉取上游最新功能
git fetch upstream
git rebase upstream/main

# 推送我们的更新
git push origin main
```

### 7.2 添加新 MCP 工具

1. 在 `mcp/tool/impl/` 下创建新类，实现 `McpTool` 接口（或继承 `BaseSessionTool`）
2. 在 `McpToolRegistry.java` 中注册
3. 编译验证，重启 MCP 服务

### 7.3 处理上游合并冲突

重点关注以下文件，因为包含我们的修复：

| 文件 | 我们的修改 |
|------|-----------|
| `application.properties` | `web-application-type=servlet` |
| `DefaultMcpWorkspaceService.java` | `getChildren()` 加 `image.parse()` |
| `Xml2Img2.java` | 类名 `Xml2Img` → `Xml2Img2` |
| `pom.xml` | `finalName`, `version`, `name`, `description` |

---

## 8. 与上游的差异

| 维度 | 上游 (leevccc/orange-wz) | TokyoRepacker |
|------|:---:|:---:|
| 产品名 | OrzRepacker | TokyoRepacker |
| 版本 | v1.162.50 | Beta v1.0 |
| MCP `list_children` | ❌ 根节点返回空（缺 `parse()`） | ✅ 已修复 |
| MCP 自编译启动 | ❌ `web-application-type=none` | ✅ `=servlet` |
| Maven 编译兼容性 | ❌ `--release 21` 与 Lombok 冲突 | ✅ 已知 workaround |
| XML2IMG 类名 | ❌ `Xml2Img2.java` 但类名 `Xml2Img` | ✅ 类名与文件名一致 |
| 作者署名 | 无 | ✅ README 标注 TokyoEric |

---

## 9. 常见问题

### Q: Maven 编译报 Lombok 错误？

**原因**：Spring Boot 4.0.0 父 POM 的 `--release 21` 与 Lombok 不兼容。  
**解决**：编译时添加参数 `-Dmaven.compiler.release= -Dmaven.compiler.source=21 -Dmaven.compiler.target=21`。

### Q: MCP 服务启动后报 `Index XX out of bounds for length 99`？

**原因**：WZ 密钥的 userKey 长度错误（应为 128 字节）。  
**解决**：使用上述 CMS 标准密钥。

### Q: `list_children` 返回空列表？

**原因**：上游代码在 `DefaultMcpWorkspaceService.getChildren()` 中未调用 `WzImage.parse()`。  
**解决**：已在我们分支中修复。如果遇到，确认使用的是自编译版本而非 Release EXE。

### Q: IDEA 编译报 `java: 类 Xml2Img 是公共的...`？

**原因**：文件名 `Xml2Img2.java` 但类声明为 `Xml2Img`。  
**解决**：已在我们的分支中修复。

### Q: 如何知道 WZ 文件中某个节点的路径？

使用 `list_children` 逐层展开，或使用 `search_node` 按关键字搜索。  
`get_node_tree_json` 可一次获取指定深度的完整树结构。

---

> 最后更新：2026-07-07  
> 维护者：[TokyoEric](https://github.com/TokyoEric)
