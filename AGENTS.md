# AGENTS.md — immich-z contributor guide

> Immich iOS + Android client in Flutter, mirroring the official Immich app
> (`https://github.com/immich-app/immich`) against the public REST API.

## Repo layout

```text
immich-z/
├── mobile/                        # Flutter app (all Dart work happens here)
│   ├── lib/main.dart
│   ├── lib/src/
│   │   ├── api/generated/         # GENERATED — client.dart + models.dart (do not hand-edit)
│   │   ├── providers/             # Riverpod: session_provider, theme_provider, repository_providers
│   │   ├── repositories/          # asset_repository, search_repository (Repository pattern)
│   │   ├── routing/               # go_router: app_router.dart, app_shell.dart
│   │   ├── screens/               # album, auth, favorites, library, map, memories,
│   │   │                          # people, search, settings, shared, tags, timeline,
│   │   │                          # upload, viewer
│   │   ├── services/              # secure_storage, server discovery, upload_service,
│   │   │                          # device_media_service, background_service, notification_service
│   │   ├── utils/format.dart      # date/bytes/duration helpers + showMessage()
│   │   └── widgets/
│   ├── android/ ios/ assets/ test/
│   ├── pubspec.yaml
│   └── analysis_options.yaml
├── openapi/immich-openapi-specs.json  # API source of truth
├── tools/generate_api.py          # regenerates mobile/lib/src/api/generated/
├── scripts/update_immichz_ipa.sh  # pull latest green IPA from Actions (see § Post-push rule)
└── .github/workflows/
    ├── build-android.yml          # APK/AAB (unsigned always; signed gated)
    └── build-ios.yml              # IPA unsigned via xcodebuild (signed gated)
```

Remote: `https://github.com/1368129224/immich-z.git`, branch `main`.

## Environment / toolchain (local dev machine)

```bash
export PATH="/tmp/toolchain/flutter/bin:$PATH"
export JAVA_HOME=/tmp/toolchain/jdk
export PATH="$JAVA_HOME/bin:$PATH"
flutter --version   # Flutter 3.35.1 • Dart 3.9.0 expected
```

- Flutter binary: `/tmp/toolchain/flutter/bin/flutter`
- JDK 17: `/tmp/toolchain/jdk/bin/java`
- Android SDK (CI): `/usr/lib/android-sdk`, NDK `27.0.12077973`
- Always run flutter commands from `mobile/`:
  `cd /mnt/ssd/code/immich-z/mobile`

## Common commands

```bash
cd mobile
flutter pub get
flutter analyze --no-fatal-infos   # CI gate: warnings FAIL, infos allowed → must exit 0 with no warning/error lines
flutter test
# Regenerate API client after spec or generator changes:
python3 ../tools/generate_api.py ../openapi/immich-openapi-specs.json lib/src/api/generated
```

Local `flutter build apk --debug` is known-broken on this box
(`LicenceNotAcceptedException: ndk;27.0.12077973` + no `JAVA_HOME` by default);
treat CI as the source of truth for builds.

## Architecture conventions

- State: `flutter_riverpod` + `hooks_riverpod`. Navigation: `go_router`.
- Repository pattern: screens → providers → repositories → `ImmichApiClient`.
- Canonical `ServerConfig` + `SecureStore` live in
  `mobile/lib/src/services/secure_storage.dart` (keychain with
  SharedPreferences fallback — unsigned iOS has no Keychain entitlement).
- `session_provider.dart` owns login/logout/restore; `requireClientProvider`
  for authenticated screens.
- Backup flow: `UploadQueueController.refresh(albumIds)` then
  `start(ref.read(requireClientProvider))` — never `start(albumIds)`.
- `photo_manager` 3.x: `getPermissionState` requires `requestOption`.
  Bulk upload dedup check: `action == AssetUploadAction.reject`.
- Search: `searchRandom(body: RandomSearchDto(size:))`;
  archive = `updateAssets` with `visibility: AssetVisibility.archive/timeline`.
- Nullable DTOs: server may omit fields — use `DateTime.tryParse(b.timeBucket ?? '')`,
  `l.ownerId ?? '—'` (no `l.owner`), filter map markers with
  `lat/lon != null` before `LatLng(lat!, lon!)`.

## API generator (`tools/generate_api.py`)

- Source: `openapi/immich-openapi-specs.json`; emits `models.dart` + `client.dart`.
- `SELECTED_OPS` allowlist (+ hand-added `updateAssets` / `AssetBulkUpdateDto`).
- Hard-learned rules for generated `_request` / mappers:
  - NEVER `(queryParameters ?? const {})..removeWhere(...)` — mutating a const
    map throws `UnsupportedError` on **every** call. Copy first:
    `Map<String, dynamic>.from(queryParameters ?? const {})`.
  - `List<String>` mapping must be null-safe:
    `where((e) => e != null).map((e) => e.toString()).toList()`
    (`e?.toString()` yields `List<String?>` → compile error).
  - No `catchError((_) => null)` for non-nullable futures; use explicit
    `try { x = await …; } catch (_) { x = null; }`.
- After changing the generator or spec, regenerate + `flutter analyze`.

## CI/CD (must stay green)

- `flutter analyze --no-fatal-infos` runs in both workflows — **zero warnings**.
  `analysis_options.yaml` excludes `lib/src/api/generated/**`.
- Flutter pinned `3.35.1` via `subosito/flutter-action@v2`; Android jobs need
  `actions/setup-java@v4` (Temurin 17).
- Android unsigned job always runs; signed job gated by
  `if: ${{ vars.ENABLE_ANDROID_SIGNING == 'true' }}`.
  iOS signed job gated by `if: ${{ vars.ENABLE_IOS_SIGNING == 'true' }}`.
  - NEVER gate with `secrets.X != ''` in `if:` — GitHub rejects the workflow file instantly.
- Unsigned iOS does NOT use `flutter build ipa` (it skips IPA without a team).
  Flow: `flutter build ios --config-only --no-codesign` → `pod install` →
  `xcodebuild … CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build` →
  `Payload/` + `/usr/bin/zip --symlinks` → `ImmichZ-unsigned.ipa`
  (artifact `immich-z-ios-ipa-unsigned`). Not installable on stock iOS —
  per-commit compile check + sideload/re-sign source only.

## ⛔ Post-push rule (mandatory)

**Every `git push` to `main` MUST be followed by: wait for Actions → pull the IPA.**

1. After pushing, watch both workflows to completion:
   ```bash
   gh run list -R 1368129224/immich-z --limit 2
   gh run watch -R 1368129224/immich-z <run-id>   # or poll `gh run list` until completed
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

## Debugging notes

- `gh run view <id> --log-failed` often returns `log not found`; use the
  REST API log endpoints instead (see above).
- Login-no-reaction checklist (all fixed once, watch for regressions):
  `_request` const-map crash, `SecureStore` keychain→prefs fallback,
  `restore()` must never throw before clearing `isLoading`,
  Android `INTERNET` permission, iOS `NSAppTransportSecurity` +
  photo/camera/location usage descriptions.

## Git conventions

- Conventional commits: `feat:`, `fix:`, `fix(ci):`, `fix(login):`, `fix(api):`.
- Keep pushes to `main` small and green; each push triggers the post-push rule above.
