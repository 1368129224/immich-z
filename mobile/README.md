# Immich Z for iOS

SwiftUI/PhotoKit iOS client for Immich. Open `ios/Runner.xcodeproj` in Xcode to develop and run the app. The bundle identifier is `com.immichz.immichz`.

## Build

```bash
xcodebuild -project ios/Runner.xcodeproj -scheme Runner \
  -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build
```

The GitHub Actions iOS workflow packages the unsigned app into an IPA. An unsigned IPA must be signed before installing on a standard device. Tests can be run with the `Runner` scheme on an iOS simulator in Xcode.
