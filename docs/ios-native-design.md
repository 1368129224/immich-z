# ImmichZ 原生 iOS 完整设计方案

> 状态：设计基线（非已实现功能声明）
> 编写基准：2026-09-30；官方稳定版 **Immich v3.2.4**（[Release](https://github.com/immich-app/immich/releases/tag/v3.2.4)，发布于 2026-09-28）；官方源码标签 [v3.2.4 / db355f79](https://github.com/immich-app/immich/tree/db355f79d910bbfc6378117ed10868493c97b922)。
> **原生 iOS API 权威来源：官方稳定版标签附带的 [OpenAPI v3.2.4](https://github.com/immich-app/immich/blob/v3.2.4/open-api/immich-openapi-specs.json)**（该文件 `info.version = 3.2.4`）；开发新功能前重新检查官方最新稳定版并锁定对应标签/commit。仓库当前 `openapi/immich-openapi-specs.json` 为 3.2.0 旧快照，**不得作为新原生 iOS 功能的权威契约**。
> 目标平台：原生 Swift/SwiftUI iOS；Android 继续维护现有 Flutter 构建，暂停其功能开发。

## 1. 决策与范围

1. 验收基准为撰写时官方**最新稳定版 v3.2.4**的移动客户端可用功能，不涵盖仅 Web 提供的管理员控制台；后续迭代开始时重新查询官方最新稳定版，以该版本标签下的官方 OpenAPI 和移动端源码作为一对基准。版本升级先评估差异，再调整里程碑与验收矩阵，不将未经验证的 `main` 分支接口混入稳定版。
2. 四个底部导航：**Photos / Search / Albums / Library**，顺序与 [官方 tab shell](https://github.com/immich-app/immich/blob/v3.2.4/mobile/lib/pages/common/tab_shell.page.dart) 一致。设置、账号、备份、分享等由各页入口或个人菜单进入，不额外占一个底栏。
3. Photos 与相册内部以照片网格展示，旧→新排列、**最新内容在底部**，向上浏览并按需加载更早资产；连续双指缩放网格但设可用尺寸上下界，放大到阈值可过渡单张浏览。不是数学意义上无界缩放。
4. Photos **合并服务器与设备本地未上传照片**；拒绝相册权限时仍可只浏览服务器。相册列表与官方服务器相册为主，同时展示设备相册；**规范化同名**本地与服务器相册自动呈现为一个组合相册，并标识两种来源。组合只影响展示，不自动上传、分享或删除另一来源。
5. Library 依官方移动版栏目设计，指收藏/归档/分享/回收站及集合、快捷入口，**不是**服务器的外部 library 管理控制台。详见第 3.4 节。
6. iOS 迁移期间保留显式 Flutter 完整应用回退；在原生能力与升级兼容验收完成后，才独立移除 Flutter iOS 依赖。Android 不随 iOS 重构。

### 1.1 官方基线与变更控制

API 以官方仓库 **同一稳定版标签的 `open-api/immich-openapi-specs.json`** 为准：本期为 [v3.2.4 原始规格](https://raw.githubusercontent.com/immich-app/immich/v3.2.4/open-api/immich-openapi-specs.json)，通过固定 tag/commit、记录 SHA256 和自动化差异检查将其引入 iOS 专用契约/客户端生成流程。新版本升级时先审查破坏性变更、重新生成 Swift 模型与请求、运行契约测试，然后再按服务端 `/server/version` 和 `/server/features` 门控；不得直接采用当前本地 3.2.0 快照或复制 Flutter 请求作为规范。现有本地规格和 Dart 生成器继续服务现行 Flutter/Android，替换它们前需单独评估 Android 兼容性。

以官方 v3.2.4 标签中的 [Photos](https://github.com/immich-app/immich/blob/v3.2.4/mobile/lib/presentation/pages/dev/main_timeline.page.dart)、[Search](https://github.com/immich-app/immich/blob/v3.2.4/mobile/lib/presentation/pages/search/search.page.dart)、[Albums](https://github.com/immich-app/immich/blob/v3.2.4/mobile/lib/presentation/pages/album.page.dart)、[Library](https://github.com/immich-app/immich/blob/v3.2.4/mobile/lib/presentation/pages/library.page.dart)、[路由](https://github.com/immich-app/immich/blob/v3.2.4/mobile/lib/routing/router.dart) 和官方 [mobile backup 文档](https://immich.app/docs/features/mobile-backup/) 建功能矩阵。官网和 `main` 可先于稳定版变化；发现冲突时，以稳定标签的移动端行为及匹配服务端 API 为准。每个功能记录：官方入口/行为、API/OS 能力、原生状态、最低服务器版本、自动化测试与手工验收证据；版本升级时逐项重新比对，不能仅以 API 路由存在判断 UI 已覆盖。

## 2. 体验与信息架构

```
登录/服务发现/会话恢复
└─ TabView
   ├─ Photos：混合时间线、回忆、选择/批量操作、查看器
   ├─ Search：搜索框、建议、探索分类、筛选、结果
   ├─ Albums：服务器相册 + 本地相册 + 同名组合相册 → 相册时间线
   └─ Library：快捷入口 + 集合 + 快速访问
共享导航：查看器、资产详情/编辑、分享、地图、人物、备份、设置/账号
```

统一视觉：尊重 iOS Safe Area、动态字体、深色模式、VoiceOver、降低动态效果；原生 `TabView` + 每 tab 独立 `NavigationStack` 保存滚动及搜索状态。空状态区分“确实没有资产”“未授予照片权限”“离线但有缓存”“服务端未启用能力”“加载失败”，提供对应操作。查看器同时可从所有网格打开，并能返回原网格的相同资产位置。

### 2.1 Photos：混合照片时间线

- 与 iOS Photos 接近的边到边缩略图网格、日期分组、按本地拍摄时间展示日期标题和视频/Live Photo/本地未上传/离线徽标；允许纯图网格及设备动态字体下的可访问操作栏。可选年/月概览是后续增强，**不以固定档位代替连续缩放**。
- 顺序：按拍摄时刻的绝对时间升序；同一时刻按来源及稳定资产 ID 确定性排序。展示日期使用资产自身的本地拍摄日期/时区，若缺失回退文件创建时间、上传创建时间；对缺失时间提供明确分组。服务器时间桶顺序和客户端排序必须一致地测试跨时区、夏令时与同日资产；不得假设字符串字典序等于时间顺序。
- 首次进入定位最新一屏，但仅在**首次**或显式“跳到最新”时滚动到底；刷新、返回、追加旧页、尺寸变化均保持可见 asset ID 和相对像素锚点。新资产到来时若用户不在底部，显示“有新照片”提示而非抢滚动。
- 向上接近阈值时请求更早桶/页；去重、游标与 bucket 边界防循环，加载锁防并发；错误只影响当前页，可单独重试。首屏、无内容与加载旧页分开处理。若后台同步更改桶计数/日期，按稳定 ID 增量更新而非重建整个列表。
- 捏合期间使用浮点连续单元格宽度与手势焦点下 asset 锚定；网格宽度例如约 **72–320 pt**（可由可访问性与设备尺寸调整），列数随布局连续重排；上下限与单张过渡经真机手感测试校准。缩放过程中不启动海量请求或失去焦点，缩小用低分辨率预览，放大逐步请求更高质量图像。
- 选择/批量操作、收藏、归档、删除/恢复、下载、分享/共享链接、加相册、标签、隐藏/锁定（若官方和服务端支持）、堆叠/Live Photo、编辑及元数据等由能力矩阵启用；**本地未上传资产不可假装有服务器 ID**。本地删除与服务器删除分别二次确认并遵守系统权限。

### 2.2 Search：官方移动版语义

- 搜索首页：搜索框、近期/建议、探索分类（如人物、地点、相册或官方启用的类别）、筛选入口；统一结果网格与查看器。搜索输入节流、取消过期请求；搜索词及过滤器更改重置游标，避免混页。
- 支持服务器的智能/语义搜索和元数据/文件名搜索；智能搜索不可用时有明确降级提示而非误称完整语义检索。筛选能力按官方 v3.2.4 + 服务器能力核实，包括人物、地点、日期、媒体类型、收藏/归档、标签、相机信息等；字段不支持时隐藏/禁用并说明。
- 搜索结果分页、稳定排序、条件标签和清空操作。纯本地未上传资产的搜索通过本地 PhotoKit 元数据索引提供**明确标注的有限搜索**（日期、类型、本地相册/可用文件名）；不能声称本地资产具备服务器 ML 语义、人脸、OCR 搜索能力。两路结果去重合并且显示来源；权限变化立即更新结果。
- 可追踪状态：加载、0 结果、服务端搜索不可用、网络错误、有限照片权限；避免服务端慢请求覆盖新的筛选结果。

### 2.3 Albums：同名组合相册

- 服务器相册支持浏览、搜索/排序、新建、重命名、封面、描述、增删成员、共享权限和协作者（以实际官方移动端支持为准）；本地相册从 PhotoKit 读取，组合相册保持原有两侧成员关系。
- 同名匹配：仅在**同一登录账号 + 当前设备**内做名称规范化（Unicode NFC、去首尾空白、大小写不敏感并按当前 locale 处理）；名称不做激进标点移除。同侧若存在多个同名相册，**不自动配对**，显示独立项和歧义提示；一对一时提供组合卡，显示服务器/本地数量及来源。名称变更或权限变化时重算映射，保留查看位置；允许用户从组合卡手动拆分并记住偏好。
- 相册详情与 Photos 共用时间线组件和锚定/缩放规则，但过滤条件限定该相册两侧的**真实成员集合**，不把设备全部未上传照片混入每个服务器相册。底部最新，上滑旧图；只载入可见缩略图与相邻页，不一次取完相册成员。
- 操作约束：将照片“加入组合相册”必须显示目标（仅服务器/仅本地/两者并要求上传），默认只操作用户当前选中的来源；共享服务器相册不会自动共享本地照片。移除、重命名、删除需分来源确认；禁止通过同名规则隐式上传或删除。服务器相册排序若有手动排序，详情中提供切换“拍摄时间/相册原排序”，默认本需求的拍摄时间升序。

### 2.4 Library：与官方结构一致

官方 v3.2.4 Library 源码的基本结构：顶部快捷 **Favorites、Archive、Shared Links、Trash**（Trash 依服务器能力）；集合卡片 **People、Places、On This Device、Memories**；快速访问包括 **Folders、Locked Folder、Partners**。按账号权限、服务器功能开关和设备照片授权动态显示；People/Places/Memory 若无数据有明确空状态。On This Device 提供本地相册浏览、授权管理和上传入口；Folders 为服务端文件夹视角，不能与本地相册等同。共享相册入口在 Albums，分享链接与伙伴分享按官方结构进入 Library。标签、地图、回收站批量恢复/清空、人物合并等进入对应详情或菜单，避免把所有功能平铺成第五个 tab。参考：[官方 Library v3.2.4](https://github.com/immich-app/immich/blob/v3.2.4/mobile/lib/presentation/pages/library.page.dart)。

## 3. 跨页面完整功能清单（实施时逐条建验收项）

| 领域 | 移动端目标能力 | 原生设计要点 |
|---|---|---|
| 连接/账号 | 服务器发现、地址校验、密码登录、API key、OAuth/SSO（服务器启用时）、恢复/退出、会话锁或 PIN（官方支持时）、账号资料 | 区分 Bearer 与 `x-api-key`；短期凭据存 Keychain；无凭据时不恢复旧会话；拒绝不安全重定向泄露认证头 |
| 资产查看 | 图片、视频流/播放、Live Photo、堆叠、信息/EXIF、位置、全屏手势、下载/导出、原图、分享 | `AVPlayer`、PhotoKit、异步加载/缓存、原图渐进加载、认证媒体请求和 Range/视频会话；保护内存 |
| 整理编辑 | 收藏、归档、回收站、删除/恢复、相册、人物、标签、堆叠、日期/位置/描述、裁切/旋转/翻转等官方移动编辑能力 | 区分本地可写、服务器可写和共享只读；不可凭空承诺滤镜等官方未提供工具 |
| 搜索发现 | 智能/元数据搜索、分类探索、过滤/分页、人物地点和地图 | 基于服务端能力门控；本地未上传资产只有有限本地索引 |
| 分享协作 | 系统分享、分享链接、共享相册、伙伴共享、相册活动/评论（若官方移动端提供） | 支持协作者权限、链接有效期/密码、冲突与撤销；本地资产必须先明确上传才能远端分享 |
| 备份同步 | 手动/自动备份、相册选取/排除、Wi‑Fi/蜂窝策略、重复检查、进度/重试、iCloud-only 原件、后台任务、设备相册同步 | 使用持久化上传队列、系统后台传输和幂等标识；iOS 后台时机不保证；断网/进程退出后可恢复 |
| 存储管理 | Free Up Space、备份状态、离线缓存、缓存清理 | 删除本地资产前核验服务器已完整备份，提示 iCloud Photos 同步删除风险，先展示预览与数量 |
| 系统/设置 | 通知、语言/主题、时间线/播放/网络偏好、版本/容量、隐私权限、诊断 | `UNUserNotificationCenter`、系统权限说明、诊断隐去凭据；设置受官方版本与服务器能力约束 |

**范围核对原则：**“所有功能”以官方 v3.2.4 **移动端可到达的功能**为准，不要求复制 Web 管理后台、服务端 AI 推理、外部图库管理界面。对于官方只有服务器接口而移动端无入口的功能，先不列为 parity 阻断项；每一项用上述官方标签源码与目标 server 的能力矩阵确认具体交互细节。

## 4. 原生系统架构

```
SwiftUI Feature Views + ViewModels (@MainActor)
        ↓ user intent / observable state
Domain：AssetIdentity、AlbumIdentity、TimelineQuery、Capability、UploadJob
        ↓ protocols / async-await
Repositories：Timeline / Search / Album / Library / Auth / Backup
        ↓
Immich API Client ─ URLSession / 版本&能力协商 / DTO / 鉴权 / 分页
LocalMediaStore ─ PhotoKit / 权限观察 / 本地相册 / iCloud 下载
Persistence ─ Keychain / SQLite 或 Core Data / 文件缓存
Background ─ URLSession background + BGTaskScheduler + OS callbacks
```

- 使用模块化目录（例如 `mobile/ios/Runner/Features/{Photos,Search,Albums,Library,Viewer,Backup,Settings}`、`Core/{API,Models,Persistence,Media,Auth}`）；在 Runner 迁移稳定后可拆成 Swift Packages。所有 UI 状态在主 actor，网络/解码/缩略图处理不阻塞主线程。
- 单一 `APIClient`：以**官方最新稳定版对应标签**的 OpenAPI 为基础生成/手写**受测试约束**的 Swift DTO，禁止散布裸 JSON 下标与强制解包；保留可空值、未知枚举、向后兼容。启动检查 `/server/version` 与 `/server/features`，明确不兼容提示；先对照官方 v3.2.4 与仓库 3.2.0 旧快照建立 API diff，再以官方契约实现与测试新原生功能，不得混用不匹配 DTO。
- URL 构造固定在已验证的服务器 `/api` 根；认证：session bearer 用 `Authorization: Bearer …`，API key 用 `x-api-key`；对缩略图、视频、下载同样认证。禁止打印 token、响应中的私有路径；只对可信同源重定向附认证头；超时、取消、限流、401 刷新/退出及失败重试统一处理，非幂等请求不可盲目重复。
- 本地身份：`AssetKey.server(serverURL, userID, assetID)` 与 `AssetKey.device(deviceID, localIdentifier)` 分离；持久化经核实的上传对应关系，优先使用明确的本地标识/上传结果关联，其次可靠 checksum + 文件长度/时间等辅助校验；相同 checksum 但不同内容或不同账号不得直接合并。PhotoKit ID 可能因删除、重装、权限变化失效；检查可访问性并重建映射。组合列表只显示唯一逻辑资产，同时保留两个来源及上传状态。
- 本地数据库存相册映射、上传任务/断点、同步游标、asset 对应关系、用户拆分偏好；图像磁盘缓存按 server/user/asset/尺寸/版本隔离，登出清理私密缓存。统一有上限的内存/磁盘 LRU 和请求并发；认证失败即时停止请求，避免旧账户闪现。
- 会话迁移兼容现有 Flutter `immich.server_config` 的 Keychain 不同 service 与 SharedPreferences `flutter.` 前缀；先读旧值、校验服务器身份、以受保护的新 schema 写入并验证，再清除旧敏感副本；退出时两种实现清理同步，回退 Flutter 时触发显式会话刷新。Unsigned IPA 的 Keychain 行为及正式签名包分别测试。

### 4.1 时间线数据与性能

服务器 `/timeline/buckets` + `/timeline/bucket` 供首页桶索引及按需展开；相册详情使用 `/search/metadata` 的 `albumIds` 过滤和 cursor 分页，不假定相册详情响应包含全部成员。搜索同理。加入 `PhotoKit` 本地分页/枚举并按统一时间键合并。对 10 万+ 资产：只缓存窗口内 DTO 与已解码缩略图，虚拟化布局/按需加载；预取临近屏幕缩略图，取消离屏请求；节流网格缩放重布局。测量首次可见时间、加载旧页耗时、内存峰值、缩放帧率、请求数；目标在设备/数据集固定后量化（例如 60 fps 优先、无持续内存增长），不能仅凭模拟器宣称达标。服务器排序与本地排序对同一日期分桶需核对一致性。

### 4.2 备份与隐私

PhotoKit 请求 `.readWrite`，支持 limited library 增补、拒绝/撤销和 iCloud-only 资源异步下载；列表可在未授权时只显示服务器。上传队列在进程退出后恢复，持久化每个源 ID、账号、上传阶段、重试时间与错误；请求 `/assets/bulk-upload-check` 时仅依规范的拒绝/已存在语义判断跳过。采用 `URLSession` 后台上传、BGTaskScheduler 和系统允许的通知回调，但明确 **iOS 不保证固定间隔或持续后台上传**。备份照片删除必须与本地 Photos 权限、服务器可读验证及用户二次确认绑定；iCloud Photos 删除同步到其他设备的风险需显眼说明。

## 5. 当前实现差距与迁移计划

| 阶段 | 交付及出场条件 |
|---|---|
| 0 基线/验证 | 核实官方最新稳定版并冻结对应功能矩阵和官方 OpenAPI 标签/哈希；建立与仓库旧快照的 API 差异；搭建 Swift 单元/UI 测试、macOS CI 原生编译/测试；明确回退入口及会话清理；不把 Flutter test 当 Swift 验证。 |
| 1 核心层 | 统一 API/鉴权/安全存储、PhotoKit 权限与本地 ID、持久缓存和版本能力协商；测试迁移/登出/401/旧数据。 |
| 2 Photos | 合并本地+服务器时间线、可见锚定、缩放、分页、查看器和主要资产操作；大图库/离线/跨时区真机验收。 |
| 3 Search + Albums | 官方筛选与有限本地搜索；相册同名合并/拆分、源隔离 CRUD、同款时间线；共享相册权限覆盖。 |
| 4 Library + 扩展 | 官方 Library 集合及快捷入口、人物/地点/地图/回忆、共享/伙伴、锁定文件夹/文件夹、设置。 |
| 5 备份与收尾 | 后台上传、设备相册同步、Free Up Space、推送/分享入口、性能/无障碍/多账号；功能矩阵全绿后移除 iOS Flutter 依赖，Android Flutter 流程保持。 |

**现状事实：** `mobile/ios/Runner/NativeImmichApp.swift` 目前只是原生登录 + 只读服务器 Photos 预览（有有限的分页/缩放/查看）；`AppDelegate.swift` 保留 Flutter “完整应用”回退。Flutter 页面/服务分布在 `mobile/lib/src/screens/` 与 `mobile/lib/src/services/`，可供迁移清单参考，**不是**官方 API 契约。当前 iOS CI 可构建 unsigned IPA，`RunnerTests` 尚无功能验收覆盖；`openapi/immich-openapi-specs.json` 是 3.2.0 **历史快照**，而原生 iOS 必须使用官方稳定版规格（本期 v3.2.4）；开发前需做版本 diff 且不能无评估地改变 Android 生成链。

## 6. 测试和发布验收

1. **契约/单元：** 各 DTO 可空数组、未知枚举与时区日期；每条请求认证、错误映射与 cursor 防循环；缩略图 URL 不泄漏凭据；相册重名歧义、来源隔离、合并/拆分及去重冲突。
2. **集成：** 使用与官方 v3.2.4 匹配的测试服务器，覆盖新老用户、不同能力开关、OAuth/API key、共享只读、10 万+ 资产、跨设备同时更新；分页重排不丢/重资产。
3. **真机 UI：** 最新定位底部；上拉加载旧页时不跳；从网格中间双指连续缩放保持焦点；不同尺寸与横竖屏、VoiceOver、低内存、弱网/断网、照片有限权限、iCloud-only、权限被撤销、本地未上传与同名相册各自正确呈现。
4. **后台与隐私：** 杀进程/重启、系统取消后台任务、账号切换、退出后缓存/凭据清理、Free Up Space 二次确认、iCloud 删除提示；不得在服务器确认前删设备照片。
5. **CI/发布：** 每个原生阶段做 macOS 编译 + XCTest/Swift 测试、Flutter Android analyze/test/build 不回退；运行时 Smoke Test。按 `AGENTS.md` 每次 push 前递增 `mobile/pubspec.yaml` build number，push 后等待 iOS/Android CI，iOS 成功再下载 IPA。unsigned IPA 仅用于编译/侧载重签验证，不代表可直接安装到普通 iPhone。

### 6.1 验收定义

每项功能要满足：UI 可到达、可用状态/失败状态/权限状态完整、与目标服务器 API 契约一致、无隐式跨来源破坏性操作、相应自动化测试及真机回归通过。四个 tab 的核心用例通过，官方 v3.2.4 移动端功能矩阵无未解释缺口，才能宣布 iOS 全原生替代；单次 CI 编译成功不等于目标达成。

## 7. 后续待验证的边界（不阻塞设计文档）

- 目标服务器是否与实施时最新官方稳定版配套，哪些功能开关可用（智能搜索、锁定文件夹、分享、回收站等）；需对实际环境做版本和 capabilities 探测。
- 自动同名合并在多本地/多服务器同名情形不自动配对的规则已在本设计给出；需用真实图库确认用户对名称规范化、配对和拆分入口的体验。
- 网格尺寸阈值、单张过渡手势、默认列宽及性能目标需要 iPhone/iPad 设备试用后细化；“无限缩放”是连续交互诉求而不是无限物理尺寸。
- iOS 正式签名、分发方式及备份后台 entitlement/通知配置需要发布前决策；unsigned CI IPA 不可直接装普通设备。
