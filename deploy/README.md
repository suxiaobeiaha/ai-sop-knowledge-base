# deploy/ — Dify 部署材料

| 文件 | 说明 |
|---|---|
| [setup-dify.sh](setup-dify.sh) | 一键部署引导脚本(中国网络适配) |
| [.env.example](.env.example) | 关键配置参考(精简版;完整版在克隆后 `dify/docker/.env.example`) |
| `dify/` | setup 脚本克隆的 Dify 源码,**不入库**(已在 .gitignore) |

## 用法

```bash
# 在 knowledge-base/ 目录下
bash deploy/setup-dify.sh            # 默认最新版
bash deploy/setup-dify.sh 1.5.0      # 或指定版本 tag
```

前提:Docker Desktop 已启动。详细步骤与 Ollama 接入见 [../docs/03-部署方案-本地.md](../docs/03-部署方案-本地.md)。
