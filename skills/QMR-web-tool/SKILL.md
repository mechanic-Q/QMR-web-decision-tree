---
name: QMR-web-tool
description: "scrape|scraping|crawl|search|research|investigate|web-search|anti-bot|cloudflare-bypass|fetch|spider|抓取|搜索|调研|研究|查找|反爬|浏览器|爬虫"
---

<EXTREMELY-IMPORTANT>
在调用任何网络工具之前，必须先运行安装检查命令确认工具可用。
不可用的工具会自动降级到下一个可用工具。
</EXTREMELY-IMPORTANT>

# 网络工具决策树

## 第一步：安装状态检查

每次使用前运行此命令确认哪些工具可用：

```bash
python3 -c "
tools = {
    'scrapling': 'from scrapling.fetchers import Fetcher',
    'stealthy': 'from scrapling.fetchers import StealthyFetcher',
    'camoufox': 'from camoufox.sync_api import Camoufox',
    'httpcloak': 'import httpcloak',
    'crawl4ai': 'import crawl4ai',
}
for name, imp in tools.items():
    try:
        exec(imp); print(f'  [OK] {name}')
    except Exception as e: print(f'  [--] {name}: {e}')

import os, pathlib
# Check camofox-browser (Node.js REST server)
# Auto-detect: look in project node_modules and global node_modules
for p in [
    pathlib.Path.cwd() / 'node_modules' / 'camofox-browser' / 'bin' / 'camofox-browser.js',
    pathlib.Path.home() / 'node_modules' / 'camofox-browser' / 'bin' / 'camofox-browser.js',
]:
    if p.exists():
        print(f'  [OK] camofox-browser ({p.parent.parent})')
        break
else:
    print('  [--] camofox-browser (npm install --save-dev camofox-browser)')

# Check Go (needed if compiling httpcloak Go bindings)
import shutil
if shutil.which('go'):
    print('  [OK] go (for optional httpcloak Go bindings)')
else:
    print('  [--] go')
"
```

检查结果决定后续决策树的可用分支。

## 第二步：决策树

```
用户请求网络操作？
│
├─ 🔍 搜索信息（不需要完整页面内容）
│   ├─ 通用网页搜索 → ddgs CLI (duckduckgo-search skill)
│   ├─ 多引擎搜索 → multi-search-engine skill
│   ├─ 学术论文 → arxiv skill
│   ├─ RSS/博客监控 → blogwatcher skill
│   └─ 预测市场 → polymarket skill
│
├─ 📄 抓取已知 URL 的内容
│   ├─ 优先级 1：内置 webfetch 工具 → 最简单，零安装，先试这个
│   ├─ 优先级 2：crawl4ai-skill → LLM 优化输出，省 Token 80%
│   │   用法：crawl4ai-skill crawl <url> --format fit_markdown
│   ├─ 优先级 3：scrapling Fetcher → 需要 CSS/XPath 选择器提取
│   │   用法：python3 -c "from scrapling.fetchers import Fetcher; ..."
│   └─ API 调用（POST/PUT/DELETE）→ scrapling Fetcher
│
├─ ⚡ JS 渲染页面（SPA、懒加载内容）
│   ├─ 简单等待即可 → crawl4ai-skill --wait-until networkidle --delay 2
│   ├─ 需要精确选择器 → scrapling DynamicFetcher（Playwright 浏览器）
│   └─ 需要交互（滚动/点击）→ scrapling DynamicFetcher + page_action
│
├─ 🛡️ 反检测/反爬虫场景
│   ├─ 轻度防护（简单 UA 检测）→ scrapling Fetcher + impersonate='chrome'
│   │   说明：scrapling Fetcher 通过 curl_cffi 模拟浏览器 TLS 指纹（JA3/JA4），
│   │   对大多数非 Bot Management 级别的防护有效
│   │
│   ├─ Cloudflare Turnstile（JS 挑战）→ scrapling StealthyFetcher
│   │   说明：solve_cloudflare=True 解决的是 JavaScript 挑战，不是 TLS 指纹。
│   │   对 Cloudflare Turnstile 有效，对 Bot Management TLS 检测无效。
│   │
│   ├─ Cloudflare Bot Management（TLS 指纹级检测）
│   │   │
│   │   ├─ HTTP 层：httpcloak（首选 HTTP 方案）
│   │   │   说明：纯 HTTP 客户端，完美模拟 Chrome/Firefox/Safari 的 TLS 指纹
│   │   │   （JA3/JA4 + HTTP/2 + HTTP/3 + QUIC + ECH + TCP/IP 指纹），
│   │   │   但不执行 JavaScript。适合 API 调用、静态页面抓取。
│   │   │   用法：
│   │   │     python3 -c "
│   │   │     import httpcloak
│   │   │     r = httpcloak.get('https://target.com', preset='chrome-latest')
│   │   │     print(r.status_code, r.protocol, r.text[:500])
│   │   │     "
│   │   │
│   │   └─ 浏览器层：camoufox（需要 JS 渲染时）
│   │       说明：camoufox 是修改过的 Firefox，在 C++ 层实现指纹伪装。
│   │       比任何 JS 层 stealth 插件强一个数量级。
│   │       用法：
│   │         python3 -c "
│   │         from camoufox.sync_api import Camoufox
│   │         with Camoufox() as b:
│   │           p = b.new_page(); p.goto('https://target.com')
│   │           print(p.content())
│   │         "
│   │
│   ├─ camoufox 失败 → Archive.org（兜底 1）
│   │   https://web.archive.org/web/20250101/<url>
│   │
│   ├─ Archive.org 失败 → 搜索引擎缓存（兜底 2）
│   │   Google: https://webcache.googleusercontent.com/search?q=cache:<url>
│   │
│   ├─ 缓存失败 → Google/Bing cache: 搜索栏输入 cache:<url>（兜底 3）
│   │
│   └─ 全部失败 → RSS feed 或联系作者（兜底 4）
│
├─ 🕷️ 大规模爬取
│   ├─ 单域名多页 → scrapling Spider（异步，并发控制）
│   ├─ 全站爬取 → crawl4ai-skill crawl-site --max-pages N
│   └─ 多域名分布式 → 需要额外安装 crawlee (Node.js)
│
└─ 🖱️ 交互式浏览器操作（签到、填表、点击）
    ├─ 普通网站 → agent-browser-cli skill（基于 Playwright）
    ├─ 反检测 + 交互 → camoufox Python 库（C++ 层伪装 + Playwright API）
    └─ 多 agent 并发 → camofox-browser（REST API 浏览器服务）
         启动：node node_modules/camofox-browser/bin/camofox-browser.js
         默认端口 9377，通过 curl 调用 REST API
```

## 第三步：错误处理模板

所有 Python 抓取代码必须包含 try/except：

```python
import sys
try:
    from scrapling.fetchers import Fetcher
    page = Fetcher.get('https://example.com')
    print(page.css('h1::text').get())
except Exception as e:
    print(f"Fetcher failed: {e}", file=sys.stderr)
    # 自动降级：尝试 webfetch 或标记为失败
```

## 工具速查表

| 工具 | 类型 | 最适场景 |
|------|------|---------|
| webfetch | 内置 | 简单页面抓取，零成本 |
| ddgs | CLI/Python | DuckDuckGo 搜索 |
| crawl4ai-skill | CLI | LLM 优化输出，全站爬取 |
| scrapling Fetcher | Python | HTTP 抓取 + curl_cffi TLS 模拟 |
| scrapling DynamicFetcher | Python | JS 渲染页面 |
| scrapling StealthyFetcher | Python | Turnstile 绕过 |
| httpcloak | Python | HTTP 层完美 TLS/JA3/JA4/HTTP3 模拟 |
| camoufox | Python | 反检测浏览器，C++ 层指纹伪装 |
| camofox-browser | Node REST | 多 agent 共享浏览器，会话持久化 |
| agent-browser-cli | Node CLI | 交互式浏览器操作 |

## 重要修正

**TLS 指纹真相：**
- scrapling `StealthyFetcher.solve_cloudflare=True` 解决的是 **Cloudflare Turnstile JS 挑战**，不是 TLS 指纹
- scrapling `Fetcher.impersonate='chrome'` 才是通过 curl_cffi 实现 **TLS 指纹模拟**（HTTP 层）
- Cloudflare Bot Management 使用 TLS ClientHello 指纹（JA3/JA4 fingerprinting）检测自动化工具
- `StealthyFetcher` + `solve_cloudflare=True` + `hide_canvas=True` 都无法改变 TLS 指纹
- 真正的 TLS 指纹绕过方案：camoufox（C++ 层）或 httpcloak（Go，需自行编译）

**Cloudflare 防护等级区分：**
| 等级 | 检测方式 | 绕过方案 |
|------|---------|---------|
| Turnstile (免费) | JS 挑战 | StealthyFetcher + solve_cloudflare |
| WAF (Pro) | 规则引擎 | Fetcher + impersonate |
| Bot Management (企业) | TLS 指纹 + 行为分析 | camoufox / 手动绕过 |

## 中国网络环境注意事项

1. **pip/npm 安装**：可能需要镜像源
   ```bash
   pip install --break-system-packages -i https://pypi.tuna.tsinghua.edu.cn/simple <package>
   ```
2. **浏览器二进制下载**：camoufox/Playwright 浏览器下载可能需代理
3. **中文网站编码**：部分中文网站使用 GBK/GB2312，需 `.encoding = 'gbk'`
   ```python
   page = Fetcher.get('https://cn-site.com')
   page.encoding = 'gbk'
   ```
4. **被墙网站**：需要代理，通过 `proxy` 参数传入

## 降级优先级链

```
camoufox > httpcloak > StealthyFetcher > Fetcher(impersonate) > DynamicFetcher > Fetcher > crawl4ai > webfetch > Archive.org > 搜索引擎缓存
```

选择一个工具失败时，**自动**沿链条降级，不要卡住。
