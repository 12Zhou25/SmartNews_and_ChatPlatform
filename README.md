[PROJECT.md](https://github.com/user-attachments/files/30516565/PROJECT.md)
# FastAPI-LLM 智能新闻与对话平台

> 基于 FastAPI + Vue 3 的全栈 AI 新闻阅读应用，集成 RAG 检索增强生成与 LLM 智能对话。

---

## 项目概述

FastAPI-LLM 是一个面向移动端的智能新闻聚合与 AI 问答平台。后端采用 FastAPI 异步架构，通过 LangChain + Chroma 向量数据库实现 RAG（检索增强生成），前端基于 Vue 3 + Vant 4 构建移动端 SPA。核心能力包括新闻分类浏览、收藏、历史记录、关键词搜索、热榜排行，以及基于大语言模型的智能问答助手——不仅可以通过语义检索找到相关新闻，还能回答用户关于个人收藏和浏览历史的查询。

---

## 技术栈

### 后端

| 技术 | 说明 |
|------|------|
| **FastAPI 0.125** | 异步 Web 框架 |
| **SQLAlchemy 2.0** | 异步 ORM |
| **SQLite / MySQL** | 数据库（开发用 SQLite，生产可切 MySQL） |
| **Redis** | 缓存层 |
| **LangChain** | LLM 应用编排框架 |
| **Chroma** | 向量数据库（新闻语义检索） |
| **DashScope** | 阿里云通义千问 API（qwen-max + text-embedding-v3） |
| **JWT + bcrypt** | 认证与密码加密 |
| **SSE** | 流式对话推送 |

### 前端

| 技术 | 说明 |
|------|------|
| **Vue 3** | Composition API + `<script setup>` |
| **Vite 7** | 构建工具 |
| **Vant 4** | 移动端 UI 组件库 |
| **Pinia 3** | 状态管理 + localStorage 持久化 |
| **Vue Router 4** | 路由管理（含 keep-alive 页面缓存） |
| **Axios + Fetch** | HTTP 请求 + SSE 流式消费 |
| **marked + DOMPurify** | Markdown 渲染 + XSS 防护 |
| **vue-i18n 9** | 中英文国际化 |

---

## 项目结构

```
FastAPI-LLM/
├── PROJECT.md                      # 本文件 — 项目说明文档
├── backend/                        # FastAPI 后端
│   ├── main.py                     # 应用入口，中间件与路由注册
│   ├── .env                        # 环境变量（API Key、数据库连接等）
│   ├── requirements.txt            # Python 依赖
│   ├── init_db.py                  # 数据库初始化脚本（种子数据）
│   ├── news.db                     # SQLite 数据库文件
│   │
│   ├── config/                     # 配置模块
│   │   ├── db_conf.py              # 数据库引擎（SQLAlchemy async）
│   │   ├── cache_conf.py           # Redis 客户端与缓存工具
│   │   ├── chroma_conf.py          # Chroma 向量库配置
│   │   ├── system_prompt.txt       # AI 主系统提示词
│   │   ├── retrieval_rag_system.txt# 检索查询改写提示词
│   │   ├── summary_system_prompt.txt# 会话摘要生成提示词
│   │   └── user_prompt.txt         # 用户消息模板
│   │
│   ├── models/                     # SQLAlchemy ORM 模型
│   │   ├── users.py                # User, UserToken
│   │   ├── news.py                 # News, NewsCategory
│   │   ├── favorite.py            # Favorite
│   │   ├── history.py             # History
│   │   └── ai_chat.py             # UserChatSession, ChatMessage
│   │
│   ├── schemas/                    # Pydantic 数据验证
│   │   ├── base.py, users.py, news.py
│   │   ├── favorite.py, history.py, ai_chat.py
│   │
│   ├── crud/                       # 异步数据操作层
│   │   ├── users.py                # 用户 CRUD
│   │   ├── news.py                 # 新闻 CRUD（含搜索/热榜/最新）
│   │   ├── news_cache.py           # 新闻 CRUD（带 Redis 缓存）
│   │   ├── favorite.py            # 收藏 CRUD
│   │   ├── history.py             # 历史 CRUD
│   │   └── ai_chat.py             # 对话 CRUD
│   │
│   ├── routers/                    # API 路由层
│   │   ├── news.py                 # 新闻接口（分类/列表/详情/搜索/热榜/最新）
│   │   ├── users.py                # 用户接口（注册/登录/信息/密码）
│   │   ├── favorite.py            # 收藏接口
│   │   ├── history.py             # 历史接口
│   │   └── ai_chat.py             # AI 对话接口（SSE 流式 + 非流式）
│   │
│   ├── services/                   # 核心业务服务
│   │   ├── model_factory.py        # LLM 模型单例工厂
│   │   ├── retriever_factory.py    # Chroma Retriever 单例工厂
│   │   ├── get_retrievel.py        # RAG 检索改写链
│   │   ├── update_summary.py       # 会话摘要自动更新
│   │   ├── db_bootstrap.py         # 启动时自动建表
│   │   └── RAG_chroma/
│   │       └── add_to_chroma.py    # 新闻向量化入库脚本
│   │
│   ├── cache/                      # Redis 缓存操作
│   │   └── news_cache.py           # 新闻分类/列表/详情/相关缓存
│   │
│   └── utils/                      # 工具模块
│       ├── auth.py                 # JWT Token 鉴权
│       ├── create_prompt.py        # Prompt 模板加载
│       ├── response.py             # 统一响应格式
│       ├── security.py             # 密码加密（bcrypt）
│       ├── exception.py            # 自定义异常
│       └── exception_handlers.py   # 全局异常处理器
│
├── frontend/                       # Vue 3 + Vite 前端
│   ├── package.json                # 前端依赖
│   ├── vite.config.js              # Vite 配置
│   ├── index.html                  # 入口 HTML
│   └── src/
│       ├── main.js                 # Vue 入口
│       ├── App.vue                 # 根组件
│       ├── style.css               # 全局样式
│       │
│       ├── config/
│       │   └── api.js              # API BaseURL + 全局配置
│       │
│       ├── router/
│       │   └── index.js            # 路由定义（11 个页面 + 前置守卫）
│       │
│       ├── store/                  # Pinia 状态管理
│       │   ├── index.js            # Pinia 实例 + 持久化插件
│       │   ├── user.js             # 用户状态
│       │   ├── theme.js            # 主题切换（4 主题）
│       │   ├── language.js         # 语言切换（zh/en）
│       │   └── modules/
│       │       ├── news.js         # 新闻列表/分类
│       │       ├── chat.js         # AI 对话管理
│       │       ├── favorite.js     # 收藏管理
│       │       └── history.js      # 浏览历史
│       │
│       ├── components/
│       │   ├── TabBar.vue          # 底部导航栏
│       │   └── NewsItem.vue        # 新闻卡片组件
│       │
│       ├── views/                  # 页面视图（11 个页面）
│       │   ├── Home.vue            # 首页（分类 Tab + 新闻列表）
│       │   ├── Login.vue           # 登录
│       │   ├── Register.vue        # 注册
│       │   ├── AIChat.vue          # AI 问答（流式对话）
│       │   ├── My.vue              # 个人中心
│       │   ├── Profile.vue         # 个人信息编辑
│       │   ├── Settings.vue        # 设置（主题/语言）
│       │   ├── Category.vue        # 分类浏览
│       │   ├── NewsDetail.vue      # 新闻详情
│       │   ├── Favorite.vue        # 收藏列表
│       │   └── History.vue         # 浏览历史
│       │
│       └── i18n/                   # 国际化
│           ├── index.js
│           └── locales/
│               ├── zh-CN.js
│               └── en-US.js
│
└── mysql/                          # MySQL 初始化 SQL（可选）
    └── init.sql
```

---

## API 接口文档

所有接口统一返回格式：

```json
{
  "code": 200,
  "message": "success",
  "data": { "..."}
}
```

### 新闻模块 `/api/news`

| 方法 | 路径 | 参数 | 说明 |
|------|------|------|------|
| GET | `/api/news/categories` | skip, limit | 获取新闻分类列表（Redis 缓存 2 小时） |
| GET | `/api/news/list` | categoryId, page, pageSize | 分页获取某分类新闻（缓存 30 分钟） |
| GET | `/api/news/detail` | id | 新闻详情 + 浏览量+1 + 相关推荐 |
| GET | `/api/news/search` | keyword, page, pageSize | 关键词搜索（标题+内容模糊匹配） |
| GET | `/api/news/hot` | limit (max 50) | 热门新闻排行（按浏览量降序） |
| GET | `/api/news/latest` | limit (max 50) | 最新新闻（按发布时间降序） |

### 用户模块 `/api/user`

| 方法 | 路径 | 参数 | 认证 | 说明 |
|------|------|------|------|------|
| POST | `/api/user/register` | username, password | 否 | 用户注册 |
| POST | `/api/user/login` | username, password | 否 | 用户登录 |
| GET | `/api/user/info` | - | 是 | 获取个人信息 |
| PUT | `/api/user/update` | nickname, avatar, gender, bio, phone | 是 | 更新个人信息 |
| PUT | `/api/user/password` | oldPassword, newPassword | 是 | 修改密码 |

### 收藏模块 `/api/favorite`

| 方法 | 路径 | 参数 | 认证 | 说明 |
|------|------|------|------|------|
| GET | `/api/favorite/check` | newsId | 是 | 检查是否已收藏 |
| POST | `/api/favorite/add` | newsId (body) | 是 | 添加收藏 |
| DELETE | `/api/favorite/remove` | newsId | 是 | 取消收藏 |
| GET | `/api/favorite/list` | page, pageSize | 是 | 收藏列表（联表查询新闻详情） |
| DELETE | `/api/favorite/clear` | - | 是 | 清空所有收藏 |

### 浏览历史模块 `/api/history`

| 方法 | 路径 | 参数 | 认证 | 说明 |
|------|------|------|------|------|
| POST | `/api/history/add` | newsId (body) | 是 | 添加浏览记录（已存在则更新时间） |
| GET | `/api/history/list` | page, pageSize | 是 | 浏览历史列表 |
| DELETE | `/api/history/delete/{history_id}` | history_id (path) | 是 | 删除单条记录 |
| DELETE | `/api/history/clear` | - | 是 | 清空所有历史 |

### AI 对话模块 `/api/ai`

| 方法 | 路径 | 参数 | 认证 | 说明 |
|------|------|------|------|------|
| GET | `/api/ai/sessions` | - | 是 | 获取用户所有对话会话 |
| GET | `/api/ai/sessions/{session_id}/messages` | session_id (path) | 是 | 获取某会话消息记录 |
| POST | `/api/ai/chat` | model, messages, stream, session_id | 是 | 核心 AI 对话（支持 SSE 流式） |

---

## 数据库设计

共 **8 张表**：

| 表名 | 说明 | 核心字段 |
|------|------|----------|
| `user` | 用户信息 | id, username, password(bcrypt), nickname, avatar, gender, bio, phone, created_at, updated_at |
| `user_token` | 用户令牌 | id, user_id(FK), token(UUID), expires_at(7天) |
| `news_category` | 新闻分类 | id, name(科技/财经/体育/娱乐/国际), sort_order |
| `news` | 新闻 | id, title, description, content, image, author, category_id(FK), views, publish_time, created_at, updated_at |
| `favorite` | 收藏 | id, user_id(FK), news_id(FK), created_at（唯一约束: user+news） |
| `history` | 浏览历史 | id, user_id(FK), news_id(FK), view_time |
| `user_chat_session` | AI 对话会话 | id, user_id, session_id(UUID), title, summary, last_summary_index, created_at, updated_at |
| `chat_message` | 对话消息 | id, user_id, session_id, role(user/assistant/system/tool), content, message_index, model_name, finish_reason |

**种子数据**：初始化脚本 `init_db.py` 包含 **50 条新闻**（5 个分类各 10 条）+ 测试用户 `admin / 123456`。

### 新闻种子数据概览

| 分类 | 条数 | 涵盖主题 |
|------|------|----------|
| 科技 | 10 | 人工智能、量子计算、操作系统、6G、自动驾驶、人形机器人、芯片、脑机接口、云计算、AR 眼镜 |
| 财经 | 10 | 股市、数字人民币、新能源车出口、降准、黄金、房地产、跨境电商、IPO、养老金、绿色债券 |
| 体育 | 10 | 女排、马拉松、足球、奥运会、篮球、电竞、网球、健身设施、冬奥场馆、武术 |
| 娱乐 | 10 | 科幻电影、音乐节、动画、短剧、数字艺术、演唱会、博物馆文创、虚拟偶像、沉浸式戏剧、非遗 |
| 国际 | 10 | 气候变化、贸易、人口、中美对话、太空探索、非洲自贸区、粮食安全、一带一路、网络安全、可再生能源 |

---

## AI 对话流水线（RAG Pipeline）

AI Chat 是整个项目的核心，采用 **RAG（检索增强生成）** 架构，处理流程如下：

```
[用户提问]
    │
    ▼
┌─────────────────────────────────────────────┐
│ 1. JWT 鉴权 → 会话管理（创建/复用）            │
└─────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────┐
│ 2. 构建上下文                                 │
│   ├─ 加载系统提示词（system_prompt.txt）        │
│   ├─ 注入用户个人数据（收藏 + 浏览历史）         │
│   ├─ 获取会话摘要（summary）                    │
│   └─ 加载近期 10 条历史消息                     │
└─────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────┐
│ 3. RAG 检索流水线                             │
│   ├─ Step 1: 检索改写                          │
│   │   └─ 用 LLM 根据对话历史优化检索查询        │
│   ├─ Step 2: 向量检索                          │
│   │   └─ Chroma + DashScope embedding → Top-5 │
│   └─ Step 3: 格式化结果                        │
│       └─ 提取标题、时间、内容片段               │
└─────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────┐
│ 4. LLM 生成回答                               │
│   ├─ system: 系统提示 + RAG结果 + 用户数据      │
│   ├─ history: 摘要 + 近期消息                   │
│   ├─ human: 用户当前问题                        │
│   └─ 模型: qwen-max（通过 DashScope API）       │
└─────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────┐
│ 5. 响应                                      │
│   ├─ 流式: SSE 逐 chunk 推送                   │
│   └─ 非流式: 一次性返回 JSON                    │
└─────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────┐
│ 6. 后处理                                     │
│   ├─ 保存 assistant 消息到数据库               │
│   └─ 条件触发会话摘要更新（每 10 条消息）        │
└─────────────────────────────────────────────┘
```

### 三层提示词策略

| 提示词文件 | 用途 |
|------------|------|
| `system_prompt.txt` | 主对话提示：定义 Qxia 助手角色、信息来源（RAG + 用户数据）、回答规则、风格约束 |
| `retrieval_rag_system.txt` | 检索改写提示：根据对话历史优化检索关键词 |
| `summary_system_prompt.txt` | 摘要生成提示：基于旧摘要 + 新增对话生成 ≤200 字摘要 |

### AI 能力边界

AI 助手 **Qxia** 能回答：

- **新闻类问题**：基于 RAG 检索结果回答，如"最近有什么科技新闻？""关于人工智能的新闻有哪些？"
- **个人数据问题**：基于用户收藏/历史回答，如"我的收藏有什么？""我看过哪些财经新闻？"
- **综合问题**：结合两部分信息，如"我收藏的科技类新闻有哪些？"
- **关键词搜索**：支持模糊匹配标题和内容

AI 助手会拒绝：
- 与新闻无关的闲聊
- 敏感话题

---

## Redis 缓存策略

| 缓存内容 | Key 格式 | 过期时间 | 失效策略 |
|----------|----------|----------|----------|
| 新闻分类 | `news:categories` | 2 小时 | 数据稳定，依赖过期 |
| 新闻列表 | `news_list:{cat_id}:{page}:{size}` | 30 分钟 | 依赖过期 |
| 新闻详情 | `news:detail:{news_id}` | 5 分钟 | **主动失效**：浏览时清缓存 |
| 相关新闻 | `news:related:{news_id}:{cat_id}` | 30 分钟 | 依赖过期 |

**缓存容错**：Redis 不可用时自动回退到数据库查询，不影响服务可用性。

---

## 前端架构

### 路由页面（11 个）

| 路径 | 页面 | keepAlive | 说明 |
|------|------|-----------|------|
| `/home` | Home.vue | ✅ | 首页：分类 Tab + 下拉刷新 + 上拉加载 |
| `/aichat` | AIChat.vue | ✅ | AI 问答：SSE 流式 + Markdown + 多会话 |
| `/my` | My.vue | ✅ | 个人中心：用户信息 + 菜单入口 |
| `/category` | Category.vue | ✅ | 分类浏览：全部分类列表 |
| `/news/detail/:id` | NewsDetail.vue | ❌ | 新闻详情：收藏 + 历史 + 相关推荐 |
| `/favorite` | Favorite.vue | ❌ | 收藏列表 |
| `/history` | History.vue | ❌ | 浏览历史 |
| `/login` | Login.vue | ❌ | 登录页 |
| `/register` | Register.vue | ❌ | 注册页 |
| `/profile` | Profile.vue | ❌ | 个人信息编辑 |
| `/settings` | Settings.vue | ❌ | 设置：4 主题 + 中英文切换 |

### 底部导航栏

| Tab | 图标 | 路由 |
|-----|------|------|
| 首页 | home | `/home` |
| AI 问答 | chat | `/aichat` |
| 我的 | user | `/my` |

### 状态管理（Pinia 7 个 Store）

| Store | 持久化 | 主要职责 |
|-------|--------|----------|
| `user` | localStorage | 登录/注册/登出、用户信息、密码修改 |
| `chat` | localStorage | AI 会话列表、消息历史、流式状态 |
| `news` | 否 | 新闻分类、列表加载、分页 |
| `favorite` | localStorage | 收藏增删查（API + 本地双模式） |
| `history` | localStorage | 浏览历史（API + 本地双模式） |
| `theme` | 否 | 4 主题切换 |
| `language` | 否 | 中英文切换 |

---

## 快速开始

### 环境要求

- Python 3.10+
- Node.js 18+
- Redis（可选，用于缓存加速）

### 后端启动

```bash
# 1. 进入后端目录
cd backend

# 2. 创建虚拟环境并安装依赖
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows
pip install -r requirements.txt

# 3. 配置环境变量（复制 .env.example 或直接编辑 .env）
# 必填：DASHSCOPE_API_KEY=你的阿里云API密钥

# 4. 初始化数据库（种子数据）
python init_db.py

# 5. （可选）将新闻向量化到 Chroma
python services/RAG_chroma/add_to_chroma.py

# 6. 启动服务
uvicorn main:app --host 127.0.0.1 --port 8000 --reload
```

### 前端启动

```bash
# 1. 进入前端目录
cd frontend

# 2. 安装依赖
npm install

# 3. 启动开发服务器
npm run dev
```

访问 `http://localhost:5173` 即可使用。

### 测试账号

- 用户名：`admin`
- 密码：`123456`

---

## 最近更新（2026-07-29）

本次更新涉及以下改动：

### 1. 清理冗余文件
- 删除 `HelloWorld.vue`、`vue.svg`、`test_main.http`
- 删除 `inspect_chroma.py`（调试脚本）
- 清理所有 `__pycache__` 目录
- 修正文件名拼写错误：`retrievel_rag_sysytem.txt` → `retrieval_rag_system.txt`

### 2. 扩展数据库种子数据
- 从 12 条扩展到 **50 条**新闻，每分类各 10 条
- 涵盖科技、财经、体育、娱乐、国际五大领域的热门话题
- 每条新闻包含真实详细的正文内容

### 3. 修复浏览量不一致问题
- **问题**：新闻详情页显示的浏览数比列表页少 1
- **根因**：详情页先读取缓存/数据库的旧对象，浏览量递增后 ORM 对象未刷新
- **修复**：手动 `+1` 计算当前浏览量 + 主动失效 Redis 缓存，确保下次访问获取最新值

### 4. 升级 AI 聊天能力
- 新增用户上下文注入：系统提示中自动注入用户收藏（20 条）和浏览历史（20 条）
- AI 现在可以回答"我的收藏有什么？""我看过哪些新闻？"等个人数据问题
- RAG 无结果时返回明确提示"（未检索到相关新闻）"而非空白
- 个人数据获取失败时优雅降级为"暂无法获取"

### 5. 新增 API 端点
- `GET /api/news/search` — 关键词搜索（标题+内容模糊匹配）
- `GET /api/news/hot` — 热门新闻排行（按浏览量降序）
- `GET /api/news/latest` — 最新新闻（按发布时间降序）

### 6. 新增缓存失效机制
- 新增 `delete_cache()` 和 `invalidate_news_detail_cache()` 函数
- 新闻浏览时主动失效详情缓存，避免数据不一致

---

## 环境变量参考

```env
# 必填
DASHSCOPE_API_KEY=sk-xxxxxxxx

# 可选
DASHSCOPE_CHAT_MODEL=qwen-max
DASHSCOPE_EMBEDDING_MODEL=text-embedding-v3
DASHSCOPE_API_ENDPOINT=https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions
DATABASE_URL=sqlite+aiosqlite:///./news.db

# Chroma 向量库（可选）
CHROMA_COLLECTION_NAME=news_rag
CHROMA_PERSIST_DIR=backend/chroma_db
```
