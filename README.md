# TokyoRepacker

> 基于 [leevccc/orange-wz](https://github.com/leevccc/orange-wz) 二次开发  
> Fork 维护：[TokyoEric](https://github.com/TokyoEric) · 版本：**Beta V1.0**  
> 仓库：[TokyoEric/apple-wz](https://github.com/TokyoEric/apple-wz)

MapleStory WZ 文件解析/编辑工具，提供桌面 GUI + MCP HTTP 服务两种使用方式。

---

## 快速安装

### 方式一：完整版（含 JRE，推荐）

下载 [TokyoRepacker-v1.0.0-Beta.zip](https://github.com/TokyoEric/apple-wz/releases/download/v1.0.0-Beta/TokyoRepacker-v1.0.0-Beta.zip)，解压后双击 `TokyoRepacker.exe` 即可运行。

### 方式二：轻量版（不含 JRE）

下载 [TokyoRepacker-v1.0.0-Beta-lite.zip](https://github.com/TokyoEric/apple-wz/releases/download/v1.0.0-Beta/TokyoRepacker-v1.0.0-Beta-lite.zip)，解压后需系统已安装 **JDK 21**。

### MCP 无头模式

```bash
TokyoRepacker.exe --orange.gui.enabled=false --server.port=10002
```

---

## 编译说明

### 环境要求

- JDK 21
- Maven 3.9+（项目自带 `mvnw.cmd`）
- .NET Framework 4.x（系统自带，编译 C# 启动器用）

### 编译步骤

```bash
# 1. Maven 编译 + classfinal 加密
mvn clean package -Dmaven.compiler.release= -Dmaven.compiler.source=21 -Dmaven.compiler.target=21 -DskipTests

# 2. 编译 C# 启动器（winexe，无控制台窗口）
csc /target:winexe /win32icon:src/main/resources/icons/TokyoRepacker.ico^
    /out:src/launcher/TokyoRepacker.exe src/launcher/Launcher.cs
```

> ⚠️ Maven 的 `--release 21` 与 Lombok 冲突，必须用以上参数覆写。

### 打包产物

| 文件 | 说明 |
|------|------|
| `target/TokyoRepacker.jar` | 加密后的 Spring Boot JAR |
| `target/data.bin` | 同上，重命名为 data.bin（发布用） |
| `src/launcher/TokyoRepacker.exe` | C# 启动器（winexe，84KB，带图标） |
| `src/launcher/Launcher.cs` | C# 启动器源码（33行） |

### 启动流程

```
TokyoRepacker.exe (C# winexe)
  → java -javaagent:data.bin -jar data.bin [参数]
  → classfinal 解密 → Spring Boot 启动 → GUI / MCP
```

---

## 功能概览

### 支持的文件格式

.wz（加密二进制）、.img（解包）、.xml、目录

### 18 种 WZ 属性类型

| 类型 | 说明 | 类型 | 说明 |
|------|------|------|------|
| String | 字符串 | Canvas | 图像 |
| Int | 32 位整数 | Sound | 音频（MP3） |
| Short / Long | 短/长整数 | UOL | 链接引用 |
| Float / Double | 浮点数 | Vector | 二维向量 |
| List | 子属性列表 | PNG / Raw | 图片数据格式 |
| Null | 空值占位 | Lua | Lua 脚本 |
| Convex | 凸包顶点 | Extended | 扩展属性 |

### 桌面 GUI

- 树形 WZ 节点浏览 + 属性编辑表单
- 30 个功能对话框（搜索/导出/图片对比/音频播放等）
- 右键菜单按节点类型区分（15 种子节点创建、批量操作、汉化等）

### MCP HTTP 服务（22 个工具）

| 分类 | 工具 |
|------|------|
| 加载/卸载 | `load_files` `list_loaded_roots` `unload_node` `unload_all` `create_wz_file` `create_img_file` |
| 查询 | `list_children` `find_node` `get_node_detail` `get_node_tree_json` `search_node` `batch_find_nodes` `query_nodes` |
| 修改 | `create_child_node` `delete_node` `copy_nodes` `paste_nodes` `mutate_nodes` `batch_update_nodes` |
| 保存 | `save_node` `save_as` |
| 其他 | `ping` |

---

## MCP 服务协议

### 初始化

```bash
curl -s -D - http://127.0.0.1:10002/mcp -X POST \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"my-client","version":"1.0"}}}'
# 响应头: Mcp-Session-Id: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### 调用工具

```bash
curl -s http://127.0.0.1:10002/mcp -X POST \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: {会话ID}" \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"load_files","arguments":{"paths":["D:/Mob.img"],"key":{"name":"CMS","ivBase64":"uX1j6Q==","userKeyBase64":"..."}}}}'
```

### WZ 密钥

| 参数 | 值 |
|------|-----|
| ivBase64 | `uX1j6Q==` |
| userKeyBase64 | `EwAAAFIAAAAqAAAAWwAAAAgAAAACAAAAEAAAAGAAAAAGAAAAAgAAAEMAAAAPAAAAtAAAAEsAAAA1AAAABQAAABsAAAAKAAAAXwAAAAkAAAAPAAAAUAAAAAwAAAAbAAAAMwAAAFUAAAABAAAACQAAAFIAAADeAAAAxwAAAB4AAAA=` |

> userKey 必须为 128 字节（base64 172 字符），长度不对会报 `Index XX out of bounds for length 99`。

---

## 项目结构

```
src/main/java/orange/wz/
├── OrangeWzApplication.java      # Spring Boot 入口
├── provider/                     # WZ 文件解析核心
│   ├── WzFile.java              # .wz 文件
│   ├── WzImageFile.java         # .img 文件
│   ├── WzImage.java             # Image 节点（含 parse）
│   ├── WzAESConstant.java       # 加密常量
│   ├── properties/              # 18 种属性类型
│   └── tools/                   # BinaryReader/Writer 等
├── mcp/                         # MCP HTTP 服务（22 工具）
├── gui/                         # Swing 桌面 GUI
├── config/                      # CORS / WebMVC
├── launcher/                    # C# 启动器源码
└── manager/                     # ServerManager
```

---

## 常见问题

### EXE 双击没反应？

确保 `data.bin` 和 `jre/` 与 EXE 在同一目录。完整版 ZIP 解压即用，轻量版需要系统安装 JDK 21。

### Maven 编译报 Lombok 错误？

Spring Boot 4.0.0 的 `--release 21` 与 Lombok 不兼容。编译时加参数 `-Dmaven.compiler.release= -Dmaven.compiler.source=21 -Dmaven.compiler.target=21`。

### MCP 查子节点返回空？

原版代码在 `DefaultMcpWorkspaceService.getChildren()` 中缺了 `WzImage.parse()` 调用。我们的分支已修复。

### 怎么知道 WZ 文件中某个节点路径？

用 `list_children` 逐层展开，或 `search_node` 按关键字搜索。

---

## 与上游差异

| 维度 | 上游 (leevccc/orange-wz) | TokyoRepacker |
|------|:---:|:---:|
| 产品名 | OrzRepacker | TokyoRepacker |
| 版本 | v1.162.50 | Beta V1.0 |
| EXE 打包方式 | Launch4j 启动模式 | **C# winexe 启动器** |
| classfinal 加密 | ✅ 有 | ✅ 有 |
| 自定义图标 | 有 | ✅ 256x256 嵌入 |
| MCP `list_children` | ❌ 根节点返回空 | ✅ 已修复 |
| MCP 自编译启动 | ❌ `web-application-type=none` | ✅ `=servlet` |
| 中文文档 | ❌ 无 | ✅ README.md 全覆盖 |

---

## 更新日志

- **Beta V1.0**（2026-07-07）— 首次发布。修复 MCP 缺陷、改用 C# 启动器（替代 Launch4j）、classfinal 加密、自定义图标、全中文文档。
