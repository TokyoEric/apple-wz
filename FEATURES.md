# TokyoRepacker 功能全景图

> 项目基于 [leevccc/orange-wz](https://github.com/leevccc/orange-wz) 二次开发  
> 维护者：TokyoEric · 版本：Beta v1.0  
> 仓库：https://github.com/TokyoEric/apple-wz

---

## 一、WZ 解析引擎（Provider 层）

### 1.1 支持的文件格式

| 格式 | 说明 | 读取 | 写入 | 对应类 |
|------|------|:---:|:---:|--------|
| `.wz` | 加密二进制 WZ 存档（含目录结构） | ✅ | ✅ | `WzFile` |
| `.img` | 解包后的 WZ 节点文件（CMS 格式） | ✅ | ✅ | `WzImageFile` |
| `.xml` | XML 格式 WZ 数据 | ✅ | ✅ | `WzXmlFile` |
| 目录 | 包含 .img/.xml 的文件夹 | ✅ | ✅ | `WzFolder` |

### 1.2 WZ 加密体系

| 组件 | 说明 |
|------|------|
| `WzAESConstant` | 加密常量：GMS IV / CMS IV / DEFAULT_KEY 128 字节 |
| `WzMutableKey` | 可变密钥生成器（AES 变形） |
| `BinaryReader` | 加密 WZ 二进制读取器（解密、偏移计算） |
| `BinaryWriter` | 加密 WZ 二进制写入器（加密、校验） |
| `WzKey` / `WzKeyStorage` | 密钥存储/管理（支持多方案） |
| `CryptoUtils` | SHA-256 哈希辅助 |
| `EncryptedFileIO` | 文件级加密 I/O |

### 1.3 节点类型体系

```
WzObject（抽象基类）
├── WzDirectory      — WZ 目录节点（可含子目录和 Image）
├── WzFolder         — 文件系统文件夹节点
├── WzImage          — WZ Image 节点（含 parse 逻辑）
│   └── WzImageFile  — .img 文件节点（extends WzImage）
├── WzXmlFile        — .xml 文件节点
└── WzImageProperty  — 属性节点（不可再包含 Directory）
```

### 1.4 属性类型（18 种）

| 属性类型 | 类 | 说明 |
|---------|----|------|
| String | `WzStringProperty` | 字符串值 |
| Int | `WzIntProperty` | 32 位整数 |
| Short | `WzShortProperty` | 16 位整数 |
| Long | `WzLongProperty` | 64 位整数 |
| Float | `WzFloatProperty` | 单精度浮点 |
| Double | `WzDoubleProperty` | 双精度浮点 |
| Vector | `WzVectorProperty` | 二维向量 (x, y) |
| List | `WzListProperty` | 子属性列表 |
| Canvas | `WzCanvasProperty` | 图像（含 PNG/Raw 格式） |
| PNG | `WzPngProperty` | 压缩 PNG 数据 |
| Raw | `WzRawDataProperty` | 原始二进制数据 |
| Sound | `WzSoundProperty` | 音频（MP3 格式） |
| UOL | `WzUOLProperty` | 链接引用 |
| Null | `WzNullProperty` | 空值占位 |
| Lua | `WzLuaProperty` | Lua 脚本数据（商业加密服） |
| Convex | `WzConvexProperty` | 凸包顶点列表 |
| Extended | `WzExtended` | 扩展属性（内部基类） |
| 子节点 | `WzChildrenProperty` | Image 内部子节点容器 |

### 1.5 核心工具类

| 类 | 关键功能 |
|----|---------|
| `WzTool` | WZ 节点遍历、复制、删除、移动、修改、查找 |
| `WzType` | 节点类型枚举 |
| `WzFileStatus` | 文件解析状态枚举（UNPARSE/PARSE_SUCCESS/ERROR_*） |
| `WzChildrenProperty` | 子节点集合（线程安全） |
| `WzChildrenDirectory` | 目录子节点集合 |
| `WzChildrenFolder` | 文件夹子节点集合 |
| `XmlExport` | WZ→XML 导出（支持缩进、图片音频选项） |
| `XmlImport` | XML→WZ 导入 |
| `ImgTool` | .img 文件打包（含版本号指定） |
| `StringTool` | WZ 编码字符串处理 |
| `FileTool` | 文件 I/O 辅助 |
| `Base64Tool` | Base64 编解码 |
| `MediaExportType` | 媒体导出格式枚举 |
| `WzMutableKey` | 可变密钥 / AES 加密引擎 |
| `BinaryReader` | WZ 二进制读取、解密、字符串解码 |
| `BinaryWriter` | WZ 二进制写入、加密、校验和 |
| `Mp3FileReader` | MP3 格式解析器 |

---

## 二、桌面 GUI（Swing 层）

### 2.1 主界面布局

```
┌─────────────────────────────────────────────┐
│  菜单栏 (JMenuBar)                           │
├──────────────────┬──────────────────────────┤
│                  │                           │
│  树面板          │  编辑面板                  │
│  (JTree)         │  ┌────────────────────┐  │
│                  │  │  属性表单 / 预览    │  │
│  显示 WZ 节点    │  │  Canvas / 音频     │  │
│  层次结构        │  │  编辑面板          │  │
│                  │  └────────────────────┘  │
│                  │                           │
├──────────────────┴──────────────────────────┤
│  状态栏 (状态信息 / 版本 / GC / 内存)        │
└─────────────────────────────────────────────┘
```

### 2.2 顶级菜单

| 菜单 | 功能项 | 快捷键 |
|------|--------|--------|
| **文件** | 加载文件 (wz/img/xml) | — |
| | 加载文件夹 | — |
| | 新建 Wz | — |
| | 新建 Img | — |
| | 卸载全部 | — |
| **工具** | 图像背景 | — |
| | 视图切换 | — |
| | 显示/隐藏 | — |
| | 启用/禁用同步 | — |
| | 清空剪贴板 | — |
| | 内存回收 (GC) | — |
| **帮助** | 论坛 (打开更新检查 URL) | — |
| | 日志 (查看器) | — |

### 2.3 树节点右键菜单（按节点类型区分）

| 节点类型 | 菜单项 |
|---------|--------|
| **WzFile / WzImageFile / WzXmlFile** | 保存 / 另存为 / 卸载 / 重载 / 转移视图 / 修改密钥 |
| **WzFolder** | 重载 / 转移视图（不支持删除/复制） |
| **WzDirectory** | 保存 / 另存为 / 卸载 / 重载 / 转移视图 / 复制 / 粘贴 / 删除 / 导出 (Img/Xml/Directory) |
| **WzImage** | 保存 / 另存为 / 卸载 / 重载 / 转移视图 / 复制 / 粘贴 / 删除 / 导出 (Img/Xml) |
| **List 属性** | 复制 / 粘贴 / 删除 / 新增子节点（15 种类型）/ 汉化 / 图片嗅探 / 删除非时装 / 排序并改名 / 批量删除 |
| **Canvas 属性** | 复制 / 粘贴 / 删除 / 预览 / 保存图片 / 图片对比 / Outlink / 图片格式 / 图片缩放 / 修改 origin |
| **String 属性** | 修改节点名 / 汉化 |
| **Int 属性** | 修改 Int 值 |
| **Sound 属性** | 播放 / 暂停 / 循环 / 保存音频 |
| **Vector/Double/Float/Long/Short/UOL/Null** | 值编辑对话框 |

### 2.4 对话框列表（30 个）

| 对话框 | 文件 | 功能 |
|--------|------|------|
| 密钥管理 | `KeyManager.java` | 多方案 WZ 密钥管理（IV + UserKey 编辑） |
| 新建文件 | `CreateFileDialog.java` | 新建 .wz 或 .img，指定版本号和密钥 |
| 搜索 | `SearchDialog.java` | 名称/值搜索、大小写、完整匹配、全局/选中范围 |
| 搜索结果 | `SearchResultDialog.java` | 搜索结果列表展示 |
| 导出 XML | `ExportXmlDialog.java` | XML 导出配置（缩进、图片音频、导出路径） |
| 修改密钥 | `ChangeKeyDialog.java` | 修改节点密钥方案 |
| 图片对比 | `ImageCompareDialog.java` | 原图/替换图并排对比、差异率显示 |
| 图片嗅探 | `CanvasWall.java` | 批量浏览 Canvas 图片，保存全部 |
| 图片格式 | `ChangeCavFmtDialog.java` | 批量修改图片格式 |
| 图片缩放 | `ScaleDialog.java` | 图片缩放比例设置 |
| 修改节点名 | `ChangeNodeNameDialog.java` | 节点重命名 |
| 日志查看 | `LogDialog.java` | 日志过滤（正则）、暂停、清空 |
| 字符串编辑 | `StringDialog.java` | 字符串属性编辑 |
| 整数编辑 | `IntDialog.java` | 整数属性编辑 |
| 短整型编辑 | `ShortDialog.java` | Short 属性编辑 |
| 长整型编辑 | `LongDialog.java` | Long 属性编辑 |
| 浮点编辑 | `FloatDialog.java` | Float 属性编辑 |
| 双精度编辑 | `DoubleDialog.java` | Double 属性编辑 |
| 向量编辑 | `VectorDialog.java` | Vector (x,y) 编辑 |
| 音频编辑 | `SoundDialog.java` | 音频播放/导入/保存 |
| 列表编辑器 | `ListEditor.java` | 列表属性编辑 |
| 节点详情 | `NodeDialog.java` | 节点信息查看 |
| 画布详情 | `CanvasDialog.java` | Canvas 属性预览/编辑 |
| 图片预览 | `PreviewImagePanel.java` | 图片缩放预览 |
| 覆盖确认 | `OverwriteDialog.java` | 文件覆盖确认（覆盖/跳过/全部覆盖/全部跳过） |

### 2.5 图形操作功能

| 功能 | 说明 |
|------|------|
| Image Compare | 原图 vs 替换图并排对比，支持空格键快速替换 |
| Outlink | 收集 Canvas 文件的引用链 |
| Image Sniffer | 批量浏览节点下的所有 Canvas 图片 |
| Canvas Origin 编辑 | 修改图片的 origin (x,y) 偏移 |
| Image Format 转换 | 批量修改 PNG 压缩格式 |
| Image Scaling | 按比例缩放所有匹配图片 |
| Raw → Icon | Raw 数据转图标 |
| PNG 保存/导入 | 保存 Canvas 为 PNG、导入 PNG 替换 |
| 音频播放 | 内嵌 MP3 播放器（播放/暂停/循环） |
| 音频保存 | 保存为 MP3 文件 |
| 音频替换 | 从文件导入音频 |
| 汉化 | 自动本地化字符串节点（引用中文版 WZ） |

### 2.6 批量操作

| 操作 | 说明 |
|------|------|
| 排序并改名 | 将子节点按序数重命名（0, 1, 2...） |
| 批量删除 | 删除所有匹配条件的子节点 |
| 删除非时装 | 从 EQP 节点中移除非 Cash 装备 |
| 图片格式批量修改 | 批量转换 Canvas 格式 |
| 图片缩放批量处理 | 批量缩放图片 |

---

## 三、MCP HTTP 服务（Service 层）

### 3.1 HTTP 端点

| 方法 | 路由 | 说明 |
|------|------|------|
| `POST` | `/mcp` | JSON-RPC 请求（initialize/tools/list/tools/call/notifications/ping） |
| `GET` | `/mcp` | SSE 事件流（需要有效 Session） |
| `DELETE` | `/mcp` | 删除会话（需要 Mcp-Session-Id） |

### 3.2 22 个 MCP 工具

| 分类 | 工具名 | 功能 | 关键参数 |
|------|--------|------|---------|
| **加载/卸载** | `load_files` | 加载 .wz/.img/.xml 文件或目录 | `paths[]`, `key` |
| | `list_loaded_roots` | 列出已加载根节点 | 无 |
| | `unload_node` | 卸载指定节点 | `rootPath` |
| | `unload_all` | 卸载全部 | 无 |
| | `create_wz_file` | 创建新 .wz 文件 | `fileName`, `version`, `key` |
| | `create_img_file` | 创建新 .img 文件 | `fileName`, `key` |
| **查询** | `list_children` | 列子节点 | `rootPath`, `nodePath?`, `autoParse?` |
| | `find_node` | 按路径查找 | `rootPath`, `nodePath` |
| | `get_node_detail` | 获取节点详情/值 | `rootPath`, `nodePath` |
| | `get_node_tree_json` | 获取 JSON 树 | `rootPath`, `nodePath?`, `maxDepth?` |
| | `search_node` | 关键字搜索 | `rootPath`, `keyword` |
| | `batch_find_nodes` | 批量查找 | `queries[]` |
| | `query_nodes` | 统一查询入口 | 支持路径/搜索/类型/详情/子节点/树 |
| **修改** | `create_child_node` | 创建子节点 | `rootPath`, `type`, `name`, `value?` |
| | `delete_node` | 删除节点 | `rootPath`, `nodePath` |
| | `copy_nodes` | 复制到剪贴板 | `sources[]` |
| | `paste_nodes` | 从剪贴板粘贴 | `rootPath`, `strategy?` |
| | `mutate_nodes` | 统一写入入口 | `operations[]` 支持 9 种操作 |
| | `batch_update_nodes` | 批量更新 | `operations[]` |
| **保存** | `save_node` | 保存文件 | `rootPath` |
| | `save_as` | 另存为 | `rootPath`, `filePath` |
| **其他** | `ping` | 心跳检测 | 无 |

### 3.3 MCP 协议流程

```
Client                             Server
  │                                   │
  │── POST /mcp (initialize) ────────→│ 创建 Session
  │←── Mcp-Session-Id + result ──────│
  │                                   │
  │── POST /mcp (tools/call) ────────→│ 携带 Session-Id 头
  │←── result ────────────────────────│
  │                                   │
  │── DELETE /mcp ───────────────────→│ 销毁 Session
  │←── 204 No Content ───────────────│
```

### 3.4 会话管理

- 每个 `initialize` 创建独立 Session（UUID）
- Session 存储：已加载根节点列表、剪贴板内容
- 线程安全：读写锁保护
- 不会话过期机制（需手动 DELETE）

### 3.5 安全限制

- Origin 验证：仅允许 `localhost` / `127.0.0.1` / `::1`
- 非法 Origin 返回 403

---

## 四、配置与国际化

### 4.1 配置文件

| 文件 | 说明 |
|------|------|
| `application.properties` | Spring Boot 配置（端口、MCP 开关、版本号、密钥） |
| `config.ini` | 用户配置（语言选择：zh_CN / en_US） |
| `keys.dat` | WZ 密钥库（二进制加密存储） |
| `logback-spring.xml` | 日志配置（按日期滚动） |

### 4.2 国际化

| 语言 | 文件 | 覆盖范围 |
|------|------|---------|
| 简体中文 | `messages_zh_CN.properties` | 356 条（全部） |
| 英文 | `messages_en_US.properties` | — |

### 4.3 CORS / Web

| 配置 | 说明 |
|------|------|
| `CorsConfig.java` | 允许 localhost 跨域（MCP 客户端访问） |
| `WebMvcConfig.java` | Web MVC 静态资源配置 |
| `SpaController.java` | 根路径转发到 index.html |

---

## 五、实用工具

| 工具 | 文件 | 说明 |
|------|------|------|
| XML→IMG 转换 | `Xml2Img2.java` | 将 XML 游戏数据批量转换为 .img 格式 |
| 版本号更新 | `UpdateVersionNumber.java` | 自动从 Git tag 更新 application.properties 版本号 |
| 文件字节对比 | `FileByteDiffPrinter.java` | 两个文件逐字节差异对比 |

---

## 六、已知局限

| 局限 | 说明 |
|------|------|
| `.ms` 格式 | 新版 WZ 变体，不支持 |
| BC7 编码 | 可解析但不可编辑 |
| 高版本 WZ (v2xx+) | 部分支持 |
| 商业加密 | 部分商业服 Lua 加密无法解析 |
| MCP 无头模式 | 需手动指定 `--orange.gui.enabled=false` |

---

> 文档版本：v1.0 · 2026-07-07  
> 由 TokyoRepacker GUIDE.md 生成
