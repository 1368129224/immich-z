# AGENTS.md — immich-z contributor guide

> Immich iOS client implemented natively in Swift (SwiftUI),
> mirroring the official Immich app (`https://github.com/immich-app/immich`) against the public REST API.

Remote: `https://github.com/1368129224/immich-z.git`, branch `main`.

---

## Core Architecture & Native iOS Focus

- **Native iOS Implementation**: The core user experience (photos grid, timeline grouping, photo/video viewers, asset caching, album views, search, and cloud synchronization status) is implemented natively in Swift using SwiftUI under `mobile/ios/Runner/`:
  - `NativeImmichApp.swift`: Root SwiftUI app, timeline photo grid, pull-to-refresh, navigation, and auth state.
  - `NativeFeatures.swift`: Album list, search grid, full-screen asset viewer (`NativeAssetViewer`), and unified grid items (`NativeGridItem`).
  - `NativeCloudStatus.swift`: Asset hashing, persistent cache store (`NativeSyncCacheStore`), and server verification (`bulk-upload-check`).
  - `AppDelegate.swift`: Native UIWindow and SwiftUI root view bootstrapping.

---

## 官方 App 算法规范与对齐标准 (Immich Algorithm Specifications)

所有照片同步状态检测、指纹计算、时间线合并去重等算法逻辑必须严格参照官方 Immich 客户端 (`https://github.com/immich-app/immich`) 实现：

### 1. 资产三态模型 (`AssetState`)
时间线与相册中的资产分为三种明确状态：
- **`remote`（仅云端）**：已上传至服务端，本地设备不存在该文件。
  - 徽标图标：空心云朵 `cloud`。
- **`merged`（双端已同步）**：服务端与本地设备均存在该照片，双端已关联。
  - 徽标图标：带对勾的云 `checkmark.icloud`。
- **`local`（仅本地未同步）**：本地设备存在但尚未上传至服务端。
  - 徽标图标：带斜线的云 `icloud.slash`。
- **视频指示图标**：视频在左下角（`.bottomLeading`）显示 `play.fill`，避免与右下角同步徽标重叠冲突。

### 2. 资产原件资源提取 (`PHAsset.getResource()`)
提取 iOS PhotoKit 资产原始数据时，必须对齐官方 `PHAssetExtensions.swift` 逻辑：
- 严格过滤媒体资源（`isMediaResource`）：
  - 排除 `.adjustmentData`（修图/XMP 元数据伴生文件），防止修图后导致计算出的 SHA-1 与服务端原件不一致。
  - 排除 iOS 17+ 的 `.photoProxy` 代理资源。
- 校验资源类型（`isValidResourceType`）：
  - 图片有效类型：`[.photo, .alternatePhoto, .fullSizePhoto]`。
  - 视频有效类型：`[.video, .fullSizeVideo, .fullSizePairedVideo]`。
- 优先级判定：
  1. 若仅有 1 个符合条件的资源，直接使用该资源。
  2. 优先取 `isCurrent`（当前渲染版本的媒体原件）。
  3. 其次取全尺寸资源（`fullSizePhoto` 或 `fullSizeVideo`）。
  4. 兜底取首个有效媒体资源。

### 3. Checksum 哈希指纹算法 (Base64 SHA-1)
- **指纹算法**：采用 **Base64 编码的 SHA-1**（28 字符字符串），与官方服务端及客户端保持完全一致（格式如 `z8Y9...=`）。
- **流式计算与协作式取消**：
  - 通过 `PHAssetResourceManager.default().requestData` 流式读取并更新 `Insecure.SHA1()`，避免大图或视频导致内存峰值。
  - 必须使用 `withTaskCancellationHandler` 包装，在 `Task.isCancelled` 时调用 `PHAssetResourceManager.default().cancelDataRequest(requestId)` 立即中断 IO，保障滑动时不会阻塞后台线程。

### 4. 同步状态持久化缓存 (`NativeSyncCacheStore`)
- **冷启动零延迟**：
  - 本地计算过的 SHA-1 指纹必须持久化在本地缓存（`native_cloud_sync_cache.json`），**同一本地资产的指纹永不重复计算**。
  - 应用冷启动时同步加载已持久化的映射关系，相册网格即时显示同步状态，严禁在冷启动时默认重置为“未同步”（`icloud.slash`）。
- **服务端核验 (`/assets/bulk-upload-check`)**：
  - 批量上报 `[{"id": localId, "checksum": base64_sha1}]`。
  - 若服务端返回 `action == "reject"`，代表服务端已存在该原件，其返回的 `assetId` 即为对应的服务端资产 UUID。
  - 维护双向映射：`matchedServerIDs` (`localId -> serverId`) 与 `reverseMatches` (`serverId -> localId`)。
- **缓存生命周期**：
  - 下拉刷新或重新载入时间线时，**严禁清空同步缓存**。
  - 仅在用户主动点击退出登录（Logout）时才调用 `clearCache()` 清除持久化缓存与本地登录态。

### 5. 时间线合并与去重机制 (`rebuildDayGroups`)
- 时间线网格采用合并模型（Merged Timeline）：
  - 将服务端资产与本地设备资产合并显示为一个无重复的时间线。
  - 对于已同步的资产，合并为**单个** `NativeGridItem(server: serverAsset, local: localAsset)`，同时保留本地原件与云端元数据引用，状态标记为 `.merged`。
  - 已匹配本地原件的服务端资产不再重复作为单独的 `.remote` 条目展示，彻底消除界面中出现两张重复照片的问题。

---

## Environment / toolchain

Native builds require macOS with Xcode. From the repository root:

```bash
xcodebuild -project mobile/ios/Runner.xcodeproj -scheme Runner \
  -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build
xcodebuild -project mobile/ios/Runner.xcodeproj -scheme Runner \
  -destination 'platform=iOS Simulator,name=iPhone 16' test
```

The current Linux host cannot compile or run iOS tests; CI provides the device build check.

---

## CI/CD (must stay green)

- The iOS workflow builds the standalone Xcode project without Flutter or CocoaPods.
- Unsigned iOS flow: `xcodebuild -project mobile/ios/Runner.xcodeproj … CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build` →
  `Payload/` + `/usr/bin/zip --symlinks` → `ImmichZ-unsigned.ipa`
  (artifact `immich-z-ios-ipa-unsigned`).

---

## ⛔ Post-push rule (mandatory)

**Every `git push` to `main` MUST be followed by: wait for Actions → pull the IPA.**

1. After pushing, watch the iOS workflow to completion:
   ```bash
   gh run list -R 1368129224/immich-z --limit 2
   gh run watch -R 1368129224/immich-z <run-id>   # watch build-ios.yml run until completed
   ```
2. Only when the iOS run (`build-ios.yml`) is `completed / success`, run:
   ```bash
   ./scripts/update_immichz_ipa.sh
   ```
   The script picks the newest successful `main` run, downloads artifact
   `immich-z-ios-ipa-unsigned`, validates `Payload/*.app/Info.plist` inside the
   zip, atomically moves it to `/mnt/ssd/temp/ipa/ImmichZ-unsigned.ipa`, and
   refreshes the LiveContainer source via `update-source.py`.
3. If the run fails: inspect with
   `curl … /repos/1368129224/immich-z/actions/runs/<id>/jobs` +
   `…/actions/jobs/<job-id>/logs` (the `gh run view --log-failed` output may be
   empty), fix, push again, and repeat this rule.
4. Never report a push as "done" while CI is still running — the task is only
   done after the IPA is pulled (or a CI failure is surfaced to the user).

---

## Versioning rule (mandatory)

- Before every push, increment `CURRENT_PROJECT_VERSION` by exactly 1 in all three
  Runner configurations in `mobile/ios/Runner.xcodeproj/project.pbxproj`.
  Never reuse a build number; increment again before a follow-up push after CI failure.
- Keep `MARKETING_VERSION` consistent across Runner configurations (currently `0.0.2`).
  `Runner/Info.plist` reads both values from Xcode build settings.

## Git conventions

- Conventional commits: `feat:`, `fix:`, `fix(ci):`, `fix(ios):`, `docs:`.
- Keep pushes to `main` small and green; each push triggers the post-push rule above.
