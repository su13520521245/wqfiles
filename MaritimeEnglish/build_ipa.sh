#!/bin/bash
# 在 Mac 上用您的簽名證書打包 .ipa（需要 Xcode 16+ 與 xcodegen）
# 用法：./build_ipa.sh            → 簽名 ipa（需先在 project.yml / ExportOptions.plist 填 Team ID）
#       ./build_ipa.sh unsigned   → 未簽名 ipa（GitHub Actions 用）
set -euo pipefail
cd "$(dirname "$0")"
command -v xcodegen >/dev/null || brew install xcodegen
xcodegen generate
mkdir -p build

run() {  # 執行 xcodebuild，失敗時印出錯誤行
  local log="build/$1.log"; shift
  if ! "$@" > "$log" 2>&1; then
    grep -E "error:|BUILD FAILED|ARCHIVE FAILED" "$log" | head -n 60
    tail -n 30 "$log"; exit 1
  fi
  grep -E "warning:" "$log" | sort -u | head -n 30 || true
  tail -n 3 "$log"
}

echo "▶ 模擬器建置檢查"
run sim xcodebuild -project MaritimeEnglish.xcodeproj -scheme MaritimeEnglish \
  -destination 'generic/platform=iOS Simulator' -configuration Debug \
  CODE_SIGNING_ALLOWED=NO build

if [[ "${1:-}" == "unsigned" ]]; then
  echo "▶ Archive（未簽名）"
  run archive-unsigned xcodebuild -project MaritimeEnglish.xcodeproj -scheme MaritimeEnglish \
    -destination 'generic/platform=iOS' -configuration Release \
    -archivePath build/MaritimeEnglish.xcarchive \
    CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" archive
  rm -rf build/Payload && mkdir -p build/Payload
  cp -R build/MaritimeEnglish.xcarchive/Products/Applications/MaritimeEnglish.app build/Payload/
  (cd build && rm -f MaritimeEnglish-unsigned.ipa && zip -qry MaritimeEnglish-unsigned.ipa Payload)
  echo "✅ build/MaritimeEnglish-unsigned.ipa"
else
  echo "▶ Archive（簽名）"
  run archive xcodebuild -project MaritimeEnglish.xcodeproj -scheme MaritimeEnglish \
    -destination 'generic/platform=iOS' -configuration Release \
    -archivePath build/MaritimeEnglish.xcarchive -allowProvisioningUpdates archive
  run export xcodebuild -exportArchive -archivePath build/MaritimeEnglish.xcarchive \
    -exportOptionsPlist ExportOptions.plist -exportPath build -allowProvisioningUpdates
  echo "✅ $(pwd)/build/MaritimeEnglish.ipa"
fi
