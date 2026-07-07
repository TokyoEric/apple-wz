## TokyoRepacker

> 基于 [leevccc/orange-wz](https://github.com/leevccc/orange-wz) 二次开发  
> Fork 维护 / 二次开发作者：**TokyoEric**

WZ 解析/编辑库 + GUI 桌面工具 (Swing) + MCP HTTP 服务。  
支持 GMS v83、CMS v079、TMS/KMS/JMS 等经典 WZ 格式。

### 与原版的差异

- **MCP 服务修复** — `list_children` 加载 .img 根节点不再返回空（补上 `WzImage.parse()`）
- **MCP 启动配置** — `web-application-type=servlet`，自编译版可直接启动无头 MCP 服务
- **编译兼容** — 跳过 `--release 21` 与 Lombok 的冲突

### 使用方法

**全新安装**
1. 下载 [Environment.7z](https://github.com/leevccc/orange-wz/releases/download/v1.155.47/Environment.7z)
2. 到 [Release](https://github.com/TokyoEric/orange-wz/releases) 下载最新的 TokyoRepacker-version.7z
3. 将两个压缩包里的文件解压后放在同一个文件夹中
4. 运行 TokyoRepacker.exe

**版本升级**
1. 下载最新的 TokyoRepacker-version.7z
2. 解压后将 TokyoRepacker.exe 和 data.bin 替换到原来的目录即可

### I18n 多语言配置方法
创建 config.ini 文件
```ini
# zh_CN / en_US
language = zh_CN
```

### MCP连接方式

将配置里的
`spring.main.web-application-type=none`
改为
`spring.main.web-application-type=servlet`
启用web端口

本地默认开启10002端口

参考配置

```json
{
  "mcpServers": {
    "orange-wz": {
      "url": "http://127.0.0.1:10002/mcp"
    }
  }
}
```
