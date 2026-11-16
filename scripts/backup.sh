#!/usr/bin/env bash
# ============================================================
# 知识库数据备份脚本
# 设计原则: knowledge/ 是知识源头,由 git 托管;Dify 是派生
# 索引,丢了可重建。因此备份分两层:
#   1) 知识源: git 提交即可(本脚本只做提醒)
#   2) Dify 状态: 导出 PostgreSQL,便于整站还原
# 用法: bash scripts/backup.sh   (需 Dify 容器在运行)
# ============================================================
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$HERE/../deploy/dify/docker/docker-compose.yaml"
BACKUP_DIR="$HERE/../backups"
STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "[错误] 未找到 $COMPOSE_FILE,请先运行 deploy/setup-dify.sh" >&2
  exit 1
fi

echo "==> 备份 PostgreSQL(dify 数据库)到 $BACKUP_DIR/dify-db-${STAMP}.sql"
docker compose -f "$COMPOSE_FILE" exec -T db \
  pg_dump -U postgres dify > "$BACKUP_DIR/dify-db-${STAMP}.sql"

echo "==> 检查知识源是否已提交 git"
if git -C "$HERE/.." status --porcelain | grep -q .; then
  echo "    [注意] knowledge/ 有未提交改动,建议:"
  echo "    cd .. && git add knowledge && git commit -m \"knowledge: 备份点 ${STAMP}\""
else
  echo "    知识源已全部提交 ✓"
fi

echo "==> 完成。备份文件:"
ls -lh "$BACKUP_DIR" | tail -n +2
