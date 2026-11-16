#!/usr/bin/env bash
# ============================================================
# Dify 本地部署引导脚本(中国网络适配版)
# 用法: bash setup-dify.sh [dify版本tag]   默认: 最新 main
# 前提: 已安装 Docker Desktop(WSL2 后端)并已启动
# ============================================================
set -euo pipefail

DIFY_TAG="${1:-}"
MIRROR="https://gh-proxy.com/"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIFY_DIR="$HERE/dify"

step() { printf '\n==> [%s] %s\n' "$1" "$2"; }
die()  { printf '[错误] %s\n' "$1" >&2; exit 1; }

step 1/4 "检查依赖"
command -v git    >/dev/null 2>&1 || die "未找到 git,请先安装 Git for Windows"
command -v docker >/dev/null 2>&1 || die "未找到 docker,请先安装 Docker Desktop"
docker info >/dev/null 2>&1 || die "Docker 未运行,请启动 Docker Desktop 后重试"

step 2/4 "获取 Dify 源码(gh-proxy 镜像通道)"
if [ -d "$DIFY_DIR/.git" ]; then
  echo "    已存在 $DIFY_DIR,执行 git pull 更新"
  git -C "$DIFY_DIR" pull --ff-only || die "更新失败,可删除 $DIFY_DIR 后重跑"
else
  if [ -n "$DIFY_TAG" ]; then
    echo "    克隆 tag: $DIFY_TAG"
    git clone --depth 1 --branch "$DIFY_TAG" "${MIRROR}https://github.com/langgenius/dify.git" "$DIFY_DIR" \
      || die "克隆失败,检查镜像可用性或换 tag"
  else
    git clone --depth 1 "${MIRROR}https://github.com/langgenius/dify.git" "$DIFY_DIR" \
      || die "克隆失败,检查镜像可用性"
  fi
fi

step 3/4 "生成 .env 配置"
cd "$DIFY_DIR/docker"
if [ ! -f .env ]; then
  cp .env.example .env
  if command -v openssl >/dev/null 2>&1; then
    KEY="$(openssl rand -hex 32)"
  else
    KEY="$(python -c 'import secrets;print(secrets.token_hex(32))')"
  fi
  sed -i "s|^SECRET_KEY=.*|SECRET_KEY=${KEY}|" .env
  echo "    已生成随机 SECRET_KEY"
else
  echo "    检测到已有 .env,跳过(如需重置请手动删除后重跑)"
fi

step 4/5 "生成核心服务 env 文件(缺失会导致 plugin_daemon 等重启循环)"
find "$DIFY_DIR/docker/envs" -name "*.env.example" -exec sh -c 'cp "$1" "${1%.example}"' _ {} \;
# 空字符串会触发 pydantic URL 校验失败,注释掉让其走默认值
sed -i 's|^DIFY_AGENT_TRAJECTORY_OTLP_TRACES_ENDPOINT=|# DIFY_AGENT_TRAJECTORY_OTLP_TRACES_ENDPOINT=|' "$DIFY_DIR/docker/envs/core-services/dify-agent.env"
# agent local sandbox 鉴权 token(模板里为空,必须生成)
if ! grep -q "^DIFY_AGENT_LOCAL_SANDBOX_AUTH_TOKEN=.\+" .env 2>/dev/null; then
  TOKEN="$(openssl rand -hex 32 2>/dev/null || python -c 'import secrets;print(secrets.token_hex(32))')"
  echo "DIFY_AGENT_LOCAL_SANDBOX_AUTH_TOKEN=${TOKEN}" >> .env
  echo "    已生成 DIFY_AGENT_LOCAL_SANDBOX_AUTH_TOKEN"
fi
# 国内 PyPI 镜像(模型插件 pip 装依赖用,直连 files.pythonhosted.org 会 120s 超时被杀)
grep -q "^PIP_MIRROR_URL=" .env 2>/dev/null || echo "PIP_MIRROR_URL=https://pypi.tuna.tsinghua.edu.cn/simple" >> .env
grep -q "^PLUGIN_PYTHON_ENV_INIT_TIMEOUT=" .env 2>/dev/null || echo "PLUGIN_PYTHON_ENV_INIT_TIMEOUT=300" >> .env

step 5/5 "启动 Dify(首次拉镜像约 10GB,耗时取决于网络)"
docker compose up -d

cat <<'EOF'

============================================================
  完成。接下来:
  1. 浏览器打开 http://localhost/install 完成初始化(设置管理员)
     (80 端口被占用时,改 deploy/dify/docker/.env 的
      EXPOSE_NGINX_PORT 后重跑本脚本)
  2. Dify 控制台 → 头像 → 设置 → 模型供应商 → Ollama:
       Base URL: http://host.docker.internal:11434
     (本机 Ollama 需设环境变量 OLLAMA_HOST=0.0.0.0 并重启)
  3. 模型建议: 对话 qwen2.5:14b,嵌入 bge-m3
     详见 docs/03-部署方案-本地.md
============================================================
EOF
