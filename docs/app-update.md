# Immich Z 应用内更新（LiveContainer）

- 入口：**设置 → 检查更新**。仅手动查询，不会自动静默替换正在运行的应用。
- `main` 分支在 GitHub Actions CI 构建完成后，自动在 GitHub Release `latest-build` 发布未签名的 `ImmichZ-unsigned.ipa` 和更新清单 `immichz-update.json`。
- 清单包含 `bundleIdentifier`（`com.immichz.immichz`）、渠道（`main`）、构建号 `buildNumber`、提交哈希 `commit`、版本号 `version`、IPA SHA-256 以及下载 URL。
- 客户端通过 HTTPS 读取清单，校验 Bundle ID、渠道与下载源，并比对本地 `CFBundleVersion`。当远程构建号大于当前构建号时，提供更新入口。
- **更新流程（应用内下载 + 系统共享覆盖）**：
  1. 用户点击「下载并导入 LiveContainer」；
  2. 应用内后台拉取最新 IPA，界面实时展示百分比下载进度，支持随时取消；
  3. 下载完成后，在客户端严格计算文件的 SHA-256 并与发布清单核验，校验失败则立即清除临时文件并报警，防止破损或篡改；
  4. 校验通过后，自动弹出 iOS 系统共享面板（Share Sheet）；
  5. 用户在共享列表中选择 **LiveContainer**，LiveContainer 的 Share Extension 接收后会弹出确认框，用户选择「覆盖 (Replace)」即可完成安装更新；
  6. 共享完成后，临时安装包自动清理，不占用额外存储。
- 如果用户无法连接 GitHub 或未配置代理，仍可直接在 LiveContainer 的「软件源」中刷新私有源完成更新，或点击「在浏览器中手动下载 IPA」手动导入。
