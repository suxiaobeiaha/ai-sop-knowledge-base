# 个人知识库(knowledge-base)

把个人能力"蒸馏"成可持续检索、可迁移的知识资产。
底座:[Dify](https://dify.ai) 本地部署(接本地 Ollama)→ 稳定后上云。

> **核心设计原则:知识源(git)是唯一真相源,Dify 只是派生索引。**
> 笔记先落盘在 `knowledge/` 并提交 git,再导入 Dify 做检索问答。
> 这样 Dify 挂了、要迁云、要换平台,知识都丢不了，支持多平台。

## 主线定位

| 主线 | 域 | 目标 |
|---|---|---|
| **工作** | `knowledge/10-工作/`:支付业务、技术支持、研发产品、项目管理、跨境清结算


## 当前状态

| 阶段 | 内容 | 状态 |
|---|---|---|
| P0 | 项目骨架 + 需求/设计文档 | 
| P1 | Dify 本地部署 + Ollama 接入 | 
| P2 | 工作域首批蒸馏入库| 
| P3 | 持续沉淀(每周迭代) | 
| P4 | 上云迁移 | 

## 技术栈

- **应用层**:Dify(开源 LLM 知识库平台,Docker Compose 部署)
- **模型层**:本地 Ollama— 对话 qwen2.5:14b、嵌入 bge-m3;上云后切换 DeepSeek/通义 API
- **存储层**:Dify 内置 PostgreSQL(业务)+ Weaviate(向量)+ Redis(缓存)
- **知识源**:`knowledge/` Markdown 文件 + git 版本管理(Knowledge as Code)

## 目录结构

```
knowledge-base/
├── docs/                # 软件工程文档:需求 → 设计 → 部署 → 管理
├── deploy/              # Dify 部署材料(脚本/配置模板;dify)
├── knowledge/           # ★ 知识源(蒸馏笔记,git 管理)
│   ├── _templates/      #   笔记模板
│   ├── 10-工作/         #   职场主线:支付业务/技术支持/研发产品/项目管理/软考
└── scripts/             # 备份等运维脚本
```

## 快速开始

1. **部署**:装好 Docker Desktop → `bash deploy/setup-dify.sh`,按 [docs/03](docs/03-部署方案-本地.md) 接 Ollama
2. **蒸馏**:照 [笔记模板](knowledge/_templates/笔记模板.md) 在 `knowledge/` 写一条笔记
3. **入库**:Dify 控制台建知识库 → 上传 md → 检索测试通过 → git 提交
4. **流程细节**:见 [docs/05](docs/05-知识库设计.md)

## 文档导航

| 文档 | 内容 |
|---|---|
| [docs/01-需求分析.md](docs/01-需求分析.md) | 目标、功能/非功能需求、验收标准 |
| [docs/02-总体设计.md](docs/02-总体设计.md) | 架构、选型、模型策略、蒸馏工作流 |
| [docs/03-部署方案-本地.md](docs/03-部署方案-本地.md) | 本地部署操作手册(中国网络适配) |
| [docs/04-部署方案-上云.md](docs/04-部署方案-上云.md) | 上云方案与迁移步骤(P4 细化) |
| [docs/05-知识库设计.md](docs/05-知识库设计.md) | 分类体系、模板、分段策略、入库 SOP |
| [docs/06-项目管理.md](docs/06-项目管理.md) | WBS、里程碑、风险登记册 |
