# QMR-web-decision-tree

> **智能网络工具决策树 — 为 AI 编程智能体而生**
>
> 一套 skill 搞定所有网络操作。根据任务描述自动选择最优的网络抓取、搜索、爬取和反爬虫工具。

---

## 解决的问题

AI 编程智能体需要频繁获取网络内容，但选择正确的工具让人困惑：

- **`webfetch`** — 内置，简单，但遇到任何反爬保护就失效
- **`scrapling`** — Fetcher？DynamicFetcher？StealthyFetcher？该用哪个？
- **`camoufox`** vs **`httpcloak`** — 都能绕过 Cloudflare，但原理完全不同
- **`crawl4ai`** — 适合 LLM 优化输出，但抓取单个 URL 太重了
- **`ddgs`** — 搜索还是新闻？图片还是视频？

**QMR-web-tool** 通过决策树解决这个问题：描述你的任务，skill 自动路由到正确的工具并附带可直接使用的代码片段。

---

## 快速开始

```bash
git clone https://github.com/mechanic-Q/QMR-web-decision-tree.git
cd QMR-web-decision-tree
chmod +x install.sh && ./install.sh
```

安装程序会自动：
1. 检测你安装了哪些 AI 编程智能体（Claude Code、OpenCode、Codex 等）
2. 安装所有 Python/Node.js 依赖
3. 把 skill 部署到每个智能体的 skill 目录
4. 生成 `AGENTS.md` 实现跨平台兼容

---

## 支持的平台

| 平台 | 格式 | 安装位置 |
|------|------|---------|
| **Claude Code** | `.claude/skills/<name>/SKILL.md` | 项目级 + 全局 |
| **OpenCode** | `.opencode/skills/<name>/SKILL.md` | 项目级 + 全局 |
| **Codex** | `.agents/skills/<name>/SKILL.md` | 项目级 + 全局 |
| **OpenClaw** | `skills/<name>/SKILL.md` | 工作区 |
| **Cursor** | `.cursor/rules/*.mdc` | 项目级 |
| **Cline** | `.clinerules/*.md` | 项目级 + 全局 |
| **Windsurf** | `.windsurfrules` (追加) | 项目级 |
| **Aider** | `.aider.conf.yml` (读取列表) | 项目级 |

### 跨平台兼容

所有支持读取 `AGENTS.md` 的平台（Codex、Cline、Cursor、Claude Code 通过 `@AGENTS.md`）
都能自动获得决策树内容。

---

## 工具清单

所有工具已验证可用：

| 工具 | 类型 | 最佳场景 | 安装方式 |
|------|------|---------|---------|
| **scrapling** | Python 库 | 通用抓取（HTTP + JS + Turnstile） | ✅ pip |
| **camoufox** | Python 库 | 反检测浏览器（C++ 层指纹伪装） | ✅ pip |
| **httpcloak** | Python 库 | HTTP/2+3 TLS 完美模拟 | ✅ pip |
| **crawl4ai** | Python 库 | LLM 优化输出、全站爬取 | ✅ pip |
| **ddgs** | Python/CLI | DuckDuckGo 搜索（文本/新闻/图片/视频） | ✅ pip |
| **camofox-browser** | Node.js | 多智能体共享浏览器（REST API） | ✅ npm |
| **Playwright** | Python/Node | 浏览器自动化（DynamicFetcher） | ✅ pip |

---

## 决策树

```
用户请求网络操作？
│
├─ 🔍 搜索信息（不需要完整页面）
│   ├─ 通用搜索 → ddgs CLI
│   ├─ 多引擎搜索 → multi-search-engine skill
│   ├─ 学术论文 → arxiv skill
│   └─ RSS/博客 → blogwatcher skill
│
├─ 📄 抓取已知 URL
│   ├─ 优先级 1：webfetch（内置，零成本）
│   ├─ 优先级 2：crawl4ai-skill（LLM 优化输出）
│   ├─ 优先级 3：scrapling Fetcher（CSS/XPath 提取）
│   └─ API 调用 → scrapling Fetcher
│
├─ ⚡ JS 渲染页面（SPA）
│   ├─ 简单等待 → crawl4ai-skill --wait-until networkidle
│   ├─ 需要选择器 → scrapling DynamicFetcher
│   └─ 需要交互 → DynamicFetcher + page_action
│
├─ 🛡️ 反检测/反爬虫场景
│   ├─ 轻度（UA 检测）→ scrapling Fetcher impersonate
│   ├─ Cloudflare Turnstile → scrapling StealthyFetcher
│   ├─ Bot Management（TLS 指纹级）
│   │   ├─ HTTP 层 → httpcloak（JA3/JA4 + HTTP/2+3 + QUIC）
│   │   └─ 浏览器层 → camoufox（C++ 层伪装）
│   └─ 全部失败 → Archive.org → 搜索引擎缓存
│
├─ 🕷️ 大规模爬取
│   ├─ 单域名 → scrapling Spider
│   ├─ 全站 → crawl4ai-skill crawl-site
│   └─ 多域名 → crawlee（Node.js，需额外安装）
│
└─ 🖱️ 交互式浏览器（签到、填表）
    ├─ 普通网站 → agent-browser-cli（基于 Playwright）
    ├─ 反检测 → camoufox Python 库
    └─ 多智能体并发 → camofox-browser（REST API）
```

---

## 工具降级链

```
camoufox > httpcloak > StealthyFetcher > Fetcher(impersonate)
> DynamicFetcher > Fetcher > crawl4ai > webfetch
> Archive.org > 搜索引擎缓存
```

一个工具失败时，自动降级到链上下一个可用工具。

---

## 使用示例

```bash
# 简单页面抓取
python3 examples/simple_scrape.py

# JS 渲染页面
python3 examples/js_render.py

# Cloudflare 绕过（带自动降级）
python3 examples/cloudflare_bypass.py https://protected-site.com

# DuckDuckGo 新闻搜索
bash examples/search_news.sh "人工智能"

# 交互式浏览器（REST API）
bash examples/interactive.sh
```

---

## 依赖说明

### Python（requirements.txt）

```
scrapling>=0.4.0     — 网页抓取框架
camoufox>=0.4.0      — 反检测浏览器
httpcloak>=1.6.0     — HTTP/2+3 TLS 指纹模拟
crawl4ai>=0.8.0      — LLM 优化爬虫
ddgs>=9.0.0          — DuckDuckGo 搜索
playwright>=1.50.0   — 浏览器自动化
python-dotenv>=1.0.0 — 环境变量配置
```

### Node.js（package.json）

```
camofox-browser ^2.4.0  — 多智能体共享浏览器 REST API
agent-browser ^0.27.0   — 交互式浏览器自动化（可选）
```

### 额外安装步骤

```bash
# 下载 camoufox 浏览器二进制（约 300MB）
python3 -m camoufox fetch

# 安装 Playwright 浏览器
python3 -m playwright install chromium
```

---

## 协议

MIT © mechanic-Q

---

## 常见问题

**问：需要安装所有工具吗？**
答：不需要。决策树会自动跳过不可用的工具并降级。

**问：我只用其中一个智能体（比如只有 Claude Code）？**
答：安装程序会检测你的实际环境，只部署必要的部分。

**问：中国网络环境有问题？**
答：`pip install -i https://pypi.tuna.tsinghua.edu.cn/simple` 使用清华镜像。
浏览器二进制下载可能需要代理。

**问：如何贡献新的工具到决策树？**
答：修改 SKILL.md，更新降级链，提交 PR。

---

## 项目起源

该项目最初是为 [OpenCode](https://github.com/anomalyco/opencode) 环境设计
的 web-tools skill，后扩展为通用智能体工具。项目完整设计在[这里](https://github.com/mechanic-Q/QMR-web-decision-tree/wiki)。
