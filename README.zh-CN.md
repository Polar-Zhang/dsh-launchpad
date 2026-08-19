# dsh-launchpad

[English](README.md) | **简体中文**

[DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) 插件：为 Web UI 增加**优雅的启动加载页**和**就绪状态接口**，并附赠 **Windows 桌面启动脚本**——双击启动 DSH，关闭浏览器标签 DSH 自动退出。

## 🤖 复制给 AI 的一键安装指令

把下面的代码块整段复制给你的 AI 助手（DSH agent 会话、Claude 等均可）。指令自包含——AI 可以先拉取本仓库再按步骤正确安装。

````text
请帮我安装 DeepSeek Harness 的 dsh-launchpad 插件（Windows），仓库地址：
https://github.com/Polar-Zhang/dsh-launchpad

1. 拉取仓库：`git clone https://github.com/Polar-Zhang/dsh-launchpad.git`
   到临时目录；或直接用
   `dsh plugin --profile web add github:Polar-Zhang/dsh-launchpad`
   从 GitHub 安装。
2. 检查 bundle 列表：读取 `<DSH_HOME>/profiles/web/package.json`
   （DSH_HOME 默认是 `%USERPROFILE%\.dsh`）。`dsh.profile.bundles` 数组
   必须包含 `dsh-launchpad`（该包声明了 `dsh.bundle.patch`）。注意：
   `dsh plugin add` 不一定会自动把它加进 bundles——如果缺失，手动在
   该数组里补上这个字符串（与其他 bundle 名并列）。pnpm 的 peer
   依赖警告是预期现象、无害（运行时由 dsh 提供这些 peer）。
3. 部署启动脚本：运行仓库里的 `scripts/install.cmd`（若是通过
   npm/GitHub 装的，则运行
   `call "%USERPROFILE%\.dsh\profiles\web\node_modules\dsh-launchpad\scripts\install.cmd"`）。
   它会把 `loading.html`、`start-dsh.cmd`、`watch-dsh-idle.cmd`、
   `hide-run.vbs`、`stop-dsh.cmd` 复制到 `%USERPROFILE%\.dsh\`。
4. 创建桌面快捷方式（双击即启动、无控制台窗口）：
   `wscript.exe "%USERPROFILE%\.dsh\hide-run.vbs" "cmd /c %USERPROFILE%\.dsh\start-dsh.cmd"`
   （可选：在快捷方式属性里把图标换成用户喜欢的 .ico）。
5. 重启 dsh web profile 让 bundle 生效——如果 dsh 正在运行，先用
   `%USERPROFILE%\.dsh\stop-dsh.cmd` 停止，再重新启动（例如用新建的快捷方式）。
6. 验证：`GET http://127.0.0.1:3080/launchpad/status` 应返回
   `"ok":true` 的 JSON；`GET http://127.0.0.1:3080/launchpad` 应返回加载页。
   最后打开 `http://127.0.0.1:3080/` 确认应用正常。
````

## 包含什么

| 组件 | 作用 |
|---|---|
| `GET /launchpad` | 启动加载页：官方 DeepSeek 鲸鱼 logo（`prefers-color-scheme` 自动明暗切换）、四段进度条（清理 → 启动 → 就绪 → 进入）、等待计时。 |
| `GET /launchpad/status` | JSON 就绪探测接口，加载页轮询它；服务一就绪立即跳转进入。 |
| `scripts/start-dsh.cmd` | 静默启动器：清理 3080 端口残留 → 隐藏启动 `dsh web` → 浏览器打开加载页。 |
| `scripts/watch-dsh-idle.cmd` | 隐藏监控：浏览器断开 3080 约 10 秒后自动杀 dsh。关标签 = 停服务。 |
| `scripts/hide-run.vbs` | 3 行隐藏运行工具（Windows 没有纯 cmd 的完全隐藏后台进程方案）。 |
| `scripts/stop-dsh.cmd` | 应急停止：杀掉占用 3080 端口的进程。 |

## 安装

作为插件安装（需要 DSH CLI）：

```bash
dsh plugin --profile web add dsh-launchpad
```

然后把启动脚本和加载页部署到 `~/.dsh`：

```cmd
:: 在包目录里执行
scripts\install.cmd
```

或者手动把 `assets/loading.html` 和 `scripts/*` 复制到 `%USERPROFILE%\.dsh\`。

创建桌面快捷方式，体验双击即开：

```cmd
wscript.exe "%USERPROFILE%\.dsh\hide-run.vbs" "cmd /c %USERPROFILE%\.dsh\start-dsh.cmd"
```

（快捷方式属性里可把图标换成你喜欢的任意 .ico。）

## 使用

1. **启动**：双击快捷方式（或运行 `start-dsh.cmd`）。全程无窗口——浏览器瞬间打开加载页，四段进度条走完，就绪后自动进入 DSH 界面。
2. **停止**：直接关闭浏览器标签。约 10 秒后 dsh 自动退出。
3. **应急**：`stop-dsh.cmd`。

### 加载页预览

```cmd
start "" "%USERPROFILE%\.dsh\loading.html?p"
```

`?p` 为预览模式（不轮询、不跳转）。切换 Windows 深浅色模式可看主题联动。

## 接口

```
GET /launchpad           → 加载页 (text/html)
GET /launchpad/status    → {"ok":true,"service":"dsh","pid":...,"uptime":...,"time":...}
```

## 自定义

加载页是单个自包含 HTML——改 `assets/loading.html`（logo、配色、阶段文案、超时）重新部署即可。全部内联，无 CDN 依赖，离线可用。

## 为什么是"插件 + 脚本"

- **插件部分**跑在 DSH 进程内（Cordis bundle）：通过 DSH web server 托管加载页和就绪接口，同源零 CORS 摩擦。
- **脚本部分**本质是操作系统级：进程无法自己启动自己，启停 dsh 必须借助 Windows shell 工具。它们随包一起发布，一站式安装。

## License

MIT
