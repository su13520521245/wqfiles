# 三副航海英語 (MaritimeEnglish)

SwiftUI iOS App（iOS 17+、iPhone、只支援直式、Swift 6、無第三方套件）。內容來自 `MaritimeEnglish/Resources/MaritimeEnglish_content.json`，打包在 App 內離線讀取。

## 功能
- 主頁：16 章列表（英文章名＋中文章名＋句數），右上角齒輪進入設定
- 設定：繁體／简体（@AppStorage，全 App 即時生效）、語速 0.3–0.6（預設 0.45）、美式／英式口音
- 章節頁：一句一頁左右滑動；點英文朗讀（AVSpeechSynthesizer，離線），朗讀中變色，再點一次停止；`___` 會唸成 "blank"
- 有 notes 的章節第一頁是「註」頁；底部顯示進度「12 / 25」；記住每章上次看到的頁數
- AVAudioSession `.playback`：靜音鍵開著時也能發音

## 建置
- **雲端（Codemagic）**：repo 根目錄的 `codemagic.yaml`，推到 `claude/maritime-english-ios-app-q0yq4w` 分支會自動在 Mac mini M2 上建置，並在 Artifacts 產出 `MaritimeEnglish-unsigned.ipa`（未簽名）。
- **Mac 本機（簽名）**：
  1. `project.yml` 裡的 `PRODUCT_BUNDLE_IDENTIFIER`（目前是 `com.yourname.maritimeenglish`）改成您自己的，並填入 `DEVELOPMENT_TEAM`
  2. `ExportOptions.plist` 填入 `teamID`；`method` 要用 development 就填 `debugging`，要用 ad-hoc 就填 `release-testing`
  3. 執行 `security find-identity -v -p codesigning` 確認證書，再執行 `./build_ipa.sh`，產出 `build/MaritimeEnglish.ipa`

## 安裝簽名的 ipa
- Xcode › Window › Devices and Simulators › 選擇 iPhone › 將 .ipa 拖到 Installed Apps
- Apple Configurator › 選擇 iPhone › Add › Apps › Choose from my Mac › 選擇 .ipa
