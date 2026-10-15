# Immich Z 应用内更新（LiveContainer）

- 入口：**设置 → 检查更新**。仅手动查询；不会后台下载或自动替换正在运行的应用。
- `main` 构建在 GitHub Release `latest-build` 发布 `ImmichZ-unsigned.ipa` 和 `immichz-update.json`。清单包含 Bundle ID、渠道、构建号、提交哈希、版本、IPA SHA-256 和下载 URL。
- 客户端通过 HTTPS 读取清单，校验 `com.immichz.immichz`、`main`、固定的 GitHub IPA 地址，并比较 `CFBundleVersion`。`CFBundleShortVersionString` 中的 `+hash` 不用于版本排序。
- 用户确认后打开 `livecontainer://install?url=<GitHub Release IPA URL>`。**由 LiveContainer 下载、询问替换并处理导入**；Immich Z 不会也不能通过 iOS 系统静默安装 IPA。
- 如果 LiveContainer 不可用，页面提供手动下载地址，可通过“文件”App 共享到 LiveContainer。不能将 Immich Z 私有沙盒中的 `file:` 路径直接交给另一个 App。
- CI 生成的 SHA-256 供排查与日后校验；当前直连模式由 LiveContainer 下载，Immich Z **不声称已核验下载文件的哈希**。
- `latest-build` 是可变 Release。CI 只允许 `main` 覆盖它；更新提示和导入之间如有新构建发布，最终下载的可能是更新后的构建。iOS 15+ 原生签名安装不在此流程支持范围内。
- 本机的 LiveContainer 软件源仍依靠主机执行 `./scripts/update_immichz_ipa.sh main` 更新；它与应用内 GitHub Release 直连是两个独立入口。
