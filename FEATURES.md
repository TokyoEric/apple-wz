# TokyoRepacker 功能全景图

> 项目基于 [leevccc/orange-wz](https://github.com/leevccc/orange-wz) 二次开发  
> 维护者：TokyoEric · 版本：Beta v1.0  
> 仓库：https://github.com/TokyoEric/apple-wz

---

## 一、WZ 解析引擎（文件解析层）

### 1.1 支持的文件格式

| 格式 | 说明 | 读取 | 写入 | 对应类 |
|------|------|:---:|:---:|--------|
| `.wz` | 加密的二进制 WZ 存档（含目录结构） | ✅ | ✅ | `WzFile` |
| `.img` | 解包后的 WZ 节点文件（国服格式） | ✅ | ✅ | `WzImageFile` |
| `.xml` | XML 格式的 WZ 数据 | ✅ | ✅ | `WzXmlFile` |
| 目录 | 包含 .img/.xml 的文件夹 | ✅ | ✅ | `WzFolder` |

### 1.2 WZ 加密体系

| 组件 | 说明 |
|------|------|
| `WzAESConstant` | 加密常量：国际服 IV、国服 IV、默认密钥（128 字节） |
| `WzMutableKey` | 可变密钥生成器（基于 AES 改造） |
| `BinaryReader` | 加密 WZ 文件的二进制读取器（解密、偏移计算） |
| `BinaryWriter` | 加密 WZ 文件的二进制写入器（加密、校验和） |
| `WzKey` / `WzKeyStorage` | 密钥存储/管理（支持多个密钥方案） |
| `CryptoUtils` | SHA-256 哈希辅助工具 |
| `EncryptedFileIO` | 文件级加密输入输出 |

### 1.3 节点类型体系

```
WzObject（抽象基类，所有节点的祖宗）
├── WzDirectory      — WZ 目录节点（可以包含子目录和 Image）
├── WzFolder         — 文件系统文件夹节点
├── WzImage          — WZ Image 节点（含解析逻辑）
│   └── WzImageFile  — .img 文件节点（继承自 WzImage）
├── WzXmlFile        — .xml 文件节点
└── WzImageProperty  — 属性节点（不能包含 Directory）
```

### 1.4 属性类型（共 18 种）

| 属性类型 | 类 | 说明 |
|---------|----|------|
| 字符串 | `WzStringProperty` | 文字值 |
| 整数 | `WzIntProperty` | 32 位整数 |
| 短整数 | `WzShortProperty` | 16 位整数 |
| 长整数 | `WzLongProperty` | 64 位整数 |
| 单精度浮点 | `WzFloatProperty` | 小数 |
| 双精度浮点 | `WzDoubleProperty` | 高精度小数 |
| 向量 | `WzVectorProperty` | 二维坐标 (x, y) |
| 列表 | `WzListProperty` | 子属性列表 |
| 画布 | `WzCanvasProperty` | 图像（含 PNG 和 Raw 两种格式） |
| PNG 图片 | `WzPngProperty` | 压缩的 PNG 图片数据 |
| 原始数据 | `WzRawDataProperty` | 原始二进制数据 |
| 音频 | `WzSoundProperty` | 声音（MP3 格式） |
| 链接 | `WzUOLProperty` | 引用其他节点（类似快捷方式） |
| 空值 | `WzNullProperty` | 占位空节点 |
| Lua 脚本 | `WzLuaProperty` | Lua 脚本数据（商业加密服用） |
| 凸包 | `WzConvexProperty` | 凸包顶点列表（碰撞体积用） |
| 扩展属性 | `WzExtended` | 内部基类 |
| 子节点容器 | `WzChildrenProperty` | Image 内部用来存子节点的容器 |

### 1.5 核心工具类

| 类 | 关键功能 |
|----|---------|
| `WzTool` | WZ 节点遍历、复制、删除、移动、修改、查找 |
| `WzType` | 节点类型枚举 |
| `WzFileStatus` | 文件解析状态（未解析/解析成功/各种错误） |
| `WzChildrenProperty` | 子节点集合（线程安全） |
| `WzChildrenDirectory` | 目录子节点集合 |
| `WzChildrenFolder` | 文件夹子节点集合 |
| `XmlExport` | 把 WZ 导出成 XML（支持缩进、图片音频选项） |
| `XmlImport` | 把 XML 导入成 WZ |
| `ImgTool` | .img 文件打包（可指定版本号） |
| `StringTool` | WZ 编码字符串处理 |
| `FileTool` | 文件读写辅助 |
| `Base64Tool` | Base64 编解码 |
| `MediaExportType` | 媒体导出格式枚举 |
| `WzMutableKey` | 可变密钥 / AES 加密引擎 |
| `BinaryReader` | WZ 二进制读取、解密、字符串解码 |
| `BinaryWriter` | WZ 二进制写入、加密、校验和计算 |
| `Mp3FileReader` | MP3 格式解析器 |

---

## 二、桌面图形界面

### 2.1 主界面布局

```
┌─────────────────────────────────────────────┐
│  菜单栏                                      │
├──────────────────┬──────────────────────────┤
│                  │                           │
│  树面板          │  编辑面板                  │
│  (左边)          │  ┌────────────────────┐  │
│                  │  │  属性表单 / 预览    │  │
│  显示 WZ 文件    │  │  图片 / 音频       │  │
│  的目录树结构    │  │  编辑面板          │  │
│                  │  └────────────────────┘  │
│                  │                           │
├──────────────────┴──────────────────────────┤
│  状态栏 (显示状态信息 / 版本 / 内存 / 回收)  │
└─────────────────────────────────────────────┘
```

### 2.2 顶级菜单

| 菜单 | 功能项 |
|------|--------|
| **文件** | 加载文件（.wz/.img/.xml）/ 加载文件夹 / 新建 Wz / 新建 Img / 卸载全部 |
| **工具** | 图像背景 / 视图切换 / 显示或隐藏 / 启用或禁用同步 / 清空剪贴板 / 内存回收 |
| **帮助** | 论坛（打开更新检查网址）/ 日志（打开查看器） |

### 2.3 右键菜单（不同类型的节点，菜单不一样）

| 节点类型 | 可以做的操作 |
|---------|--------|
| **WzFile / WzImageFile / WzXmlFile**（文件根节点） | 保存 / 另存为 / 卸载 / 重载 / 转移到其他视图 / 修改密钥 |
| **WzFolder**（文件夹） | 重载 / 转移视图（不支持删除和复制） |
| **WzDirectory**（WZ 目录） | 保存 / 另存为 / 卸载 / 重载 / 转移视图 / 复制 / 粘贴 / 删除 / 导出（可导出为 Img、Xml、目录） |
| **WzImage**（Image 节点） | 保存 / 另存为 / 卸载 / 重载 / 转移视图 / 复制 / 粘贴 / 删除 / 导出（Img 或 Xml） |
| **列表属性（List）** | 复制 / 粘贴 / 删除 / 新增子节点（15 种类型可选）/ 汉化 / 图片嗅探 / 删除非时装装备 / 排序并改名 / 批量删除 |
| **画布属性（Canvas）** | 复制 / 粘贴 / 删除 / 预览 / 保存图片 / 图片对比 / 查找引用（Outlink）/ 改图片格式 / 缩放图片 / 修改原点坐标 |
| **字符串属性（String）** | 修改节点名 / 汉化 |
| **整数属性（Int）** | 修改整数值 |
| **音频属性（Sound）** | 播放 / 暂停 / 循环 / 保存音频文件 |
| **其他类型（Vector/Double/Float/Long/Short/UOL/Null）** | 弹出对应编辑框 |

### 2.4 对话框列表（共 26 个）

| 对话框 | 文件 | 功能 |
|--------|------|------|
| 密钥管理 | `KeyManager.java` | 管理多套 WZ 密钥方案（编辑 IV 和 UserKey） |
| 新建文件 | `CreateFileDialog.java` | 新建 .wz 或 .img 文件，指定版本号和密钥 |
| 搜索 | `SearchDialog.java` | 按名称或值搜索，可设大小写、完整匹配、全局/选中范围 |
| 搜索结果 | `SearchResultDialog.java` | 展示搜索结果列表 |
| 导出 XML | `ExportXmlDialog.java` | 配置 XML 导出（缩进、图片音频、导出路径） |
| 修改密钥 | `ChangeKeyDialog.java` | 修改某个节点的密钥方案 |
| 图片对比 | `ImageCompareDialog.java` | 原图和替换图并排对比，显示差异率 |
| 图片嗅探 | `CanvasWall.java` | 批量浏览图片，可以全部保存 |
| 图片格式 | `ChangeCavFmtDialog.java` | 批量修改图片压缩格式 |
| 图片缩放 | `ScaleDialog.java` | 设置图片缩放比例 |
| 修改节点名 | `ChangeNodeNameDialog.java` | 重命名节点 |
| 日志查看 | `LogDialog.java` | 查看日志，支持正则过滤、暂停、清空 |
| 字符串编辑 | `StringDialog.java` | 编辑字符串属性 |
| 整数编辑 | `IntDialog.java` | 编辑整数属性 |
| 短整数编辑 | `ShortDialog.java` | 编辑短整数属性 |
| 长整数编辑 | `LongDialog.java` | 编辑长整数属性 |
| 浮点数编辑 | `FloatDialog.java` | 编辑单精度浮点数属性 |
| 双精度编辑 | `DoubleDialog.java` | 编辑双精度浮点数属性 |
| 向量编辑 | `VectorDialog.java` | 编辑二维坐标 (x,y) |
| 音频编辑 | `SoundDialog.java` | 播放/导入/保存音频 |
| 列表编辑器 | `ListEditor.java` | 编辑列表属性 |
| 节点详情 | `NodeDialog.java` | 查看节点信息 |
| 画布详情 | `CanvasDialog.java` | 预览和编辑画布属性 |
| 图片预览 | `PreviewImagePanel.java` | 缩放预览图片 |
| 覆盖确认 | `OverwriteDialog.java` | 文件覆盖时提示（覆盖/跳过/全部覆盖/全部跳过） |

### 2.5 图形操作功能

| 功能 | 说明 |
|------|------|
| 图片对比 | 原图和替换图并排对比，按空格键快速替换 |
| 查找引用（Outlink） | 查找某个画布文件被哪些节点引用 |
| 图片嗅探 | 批量浏览某个节点下的所有图片 |
| 修改图片原点 | 修改图片的 (x,y) 偏移坐标 |
| 批量改图片格式 | 批量转换 PNG 压缩格式 |
| 批量缩放图片 | 按比例缩放所有匹配的图片 |
| Raw 转图标 | 把原始数据转成图标 |
| 保存/导入 PNG | 把画布保存为 PNG 文件，或导入 PNG 替换 |
| 播放音频 | 内置 MP3 播放器（播放/暂停/循环） |
| 保存音频 | 保存为 MP3 文件 |
| 替换音频 | 从文件导入音频替换 |
| 汉化 | 自动把字符串节点翻译成中文（引用中文版 WZ） |

### 2.6 批量操作

| 操作 | 说明 |
|------|------|
| 排序并改名 | 把子节点按顺序重命名（0, 1, 2...） |
| 批量删除 | 删除所有符合条件的子节点 |
| 删除非时装 | 从装备节点中删掉非现金装备 |
| 批量改图片格式 | 批量转换画布格式 |
| 批量缩放图片 | 批量缩放图片 |

---

## 三、MCP 服务（HTTP 接口层）

### 3.1 接口地址

| 方法 | 地址 | 说明 |
|------|------|------|
| `POST` | `/mcp` | 发 JSON-RPC 请求（初始化、列工具、调工具、通知、心跳） |
| `GET` | `/mcp` | SSE 事件流（需要有效会话） |
| `DELETE` | `/mcp` | 删除会话（需要传 Mcp-Session-Id） |

### 3.2 22 个 MCP 工具

| 分类 | 工具名 | 功能 | 关键参数 |
|------|--------|------|---------|
| **加载/卸载** | `load_files` | 加载 .wz/.img/.xml 文件或目录 | `paths[]`, `key` |
| | `list_loaded_roots` | 列出已加载的根节点 | 无 |
| | `unload_node` | 卸载指定节点 | `rootPath` |
| | `unload_all` | 卸载所有节点 | 无 |
| | `create_wz_file` | 新建 .wz 文件 | `fileName`, `version`, `key` |
| | `create_img_file` | 新建 .img 文件 | `fileName`, `key` |
| **查询** | `list_children` | 列出某节点的子节点 | `rootPath`, `nodePath?`, `autoParse?` |
| | `find_node` | 按路径找节点 | `rootPath`, `nodePath` |
| | `get_node_detail` | 获取节点详情和值 | `rootPath`, `nodePath` |
| | `get_node_tree_json` | 获取节点及其子节点的 JSON 树 | `rootPath`, `nodePath?`, `maxDepth?` |
| | `search_node` | 按关键字搜索 | `rootPath`, `keyword` |
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
| **其他** | `ping` | 心跳检测（看服务是否活着） | 无 |

### 3.3 调用流程

```
客户端                             服务端
  │                                   │
  │── 发送初始化请求 ────────────────→│ 创建会话
  │←── 返回会话 ID ──────────────────│
  │                                   │
  │── 发送调用工具请求 ──────────────→│ 带上会话 ID
  │←── 返回结果 ─────────────────────│
  │                                   │
  │── 发送删除会话请求 ─────────────→│ 销毁会话
  │←── 返回 204 ────────────────────│
```

### 3.4 会话管理

- 每次 `initialize` 会创建一个独立会话（用 UUID 标识）
- 会话里存着：已加载的根节点列表、剪贴板内容
- 线程安全：用读写锁保护
- 会话不会自动过期（需要手动调 DELETE 删除）

### 3.5 安全限制

- 来源检查：只允许 `localhost` / `127.0.0.1` / `::1`
- 非法的来源会返回 403 禁止访问

---

## 四、配置与国际化

### 4.1 配置文件

| 文件 | 说明 |
|------|------|
| `application.properties` | Spring Boot 配置（端口、MCP 开关、版本号、密钥） |
| `config.ini` | 用户配置（语言选择：zh_CN / en_US） |
| `keys.dat` | WZ 密钥库（加密存储） |
| `logback-spring.xml` | 日志配置（按日期自动归档） |

### 4.2 国际化

| 语言 | 文件 | 覆盖范围 |
|------|------|---------|
| 简体中文 | `messages_zh_CN.properties` | 356 条（完整） |
| 英文 | `messages_en_US.properties` | 待补充 |

### 4.3 网络相关

| 配置 | 说明 |
|------|------|
| `CorsConfig.java` | 允许本机跨域访问（MCP 客户端用） |
| `WebMvcConfig.java` | 静态资源配置 |
| `SpaController.java` | 根路径转发到 index.html |

---

## 五、实用工具

| 工具 | 文件 | 说明 |
|------|------|------|
| XML→IMG 转换 | `Xml2Img2.java` | 把 XML 游戏数据批量转成 .img 格式 |
| 版本号更新 | `UpdateVersionNumber.java` | 自动从 Git 标签更新配置文件中的版本号 |
| 文件字节对比 | `FileByteDiffPrinter.java` | 两个文件逐字节比较差异 |

---

## 六、已知局限

| 局限 | 说明 |
|------|------|
| `.ms` 格式 | 新版 WZ 变体，不支持 |
| BC7 编码 | 能读但不能编辑 |
| 高版本 WZ（v2xx 以上） | 只能部分支持 |
| 商业服加密 | 部分商业服的 Lua 加密无法解析 |
| 无头模式 | 启动时要手动加参数 `--orange.gui.enabled=false` |

---

> 文档版本：v1.0 · 2026-07-07  
> 由 TokyoRepacker 项目生成
