#!/usr/bin/env bash
# 빌드 + Firebase Hosting 배포
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

"$ROOT/scripts/build-site.sh"

echo "▶ Firebase 배포 중..."
firebase deploy --only hosting

echo "✅ 배포 완료"
echo "   https://wons-wiki.web.app"
echo "   https://wons-wiki.firebaseapp.com"
