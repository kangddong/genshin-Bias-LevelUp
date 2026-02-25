# GitHub CI 성공 후 TestFlight 자동 배포 가이드

이 문서는 `CI가 성공하면` 자동으로 아래 순서가 실행되도록 만드는 가이드입니다.

1. `archive`
2. `IPA export`
3. `TestFlight upload`

기준 프로젝트 값:
- Scheme: `MyBiasLevelUp`
- Project: `MyBiasLevelUp.xcodeproj`
- Bundle ID: `com.mybiaslevelup.app`
- Team ID: `FL4QTRRKMD`

## 0) 먼저 꼭 필요한 선행 조건

1. App Store Connect에 앱이 이미 생성되어 있어야 합니다.
- 지금은 최초 등록을 수동으로 완료했다고 했으니 이 조건은 충족된 상태입니다.

2. GitHub Secrets를 저장합니다.
- `ASC_KEY_ID`: App Store Connect API Key ID
- `ASC_ISSUER_ID`: App Store Connect API Issuer ID
- `ASC_KEY_P8_BASE64`: `.p8` 파일 내용을 base64로 인코딩한 값

`.p8`를 base64로 만드는 로컬 명령:

```bash
base64 -i AuthKey_XXXXXX.p8 | pbcopy
```

3. API Key 권한 확인
- App Store Connect API Key 권한은 최소 `App Manager` 이상 권장
- 인증서/프로비저닝 자동 생성까지 CI에서 처리하려면 권한이 부족하면 실패할 수 있습니다.

## 1) 워크플로우 파일 생성

파일 경로: `.github/workflows/testflight-release.yml`

```yaml
name: TestFlight Release

on:
  workflow_run:
    workflows: ["iOS CI"]
    types: [completed]

jobs:
  release:
    # CI가 성공했고, main 브랜치에서 실행된 경우만 배포
    if: ${{ github.event.workflow_run.conclusion == 'success' && github.event.workflow_run.head_branch == 'main' }}
    runs-on: macos-15

    steps:
      - name: Checkout same commit from CI run
        uses: actions/checkout@v4
        with:
          ref: ${{ github.event.workflow_run.head_sha }}

      - name: Select Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '16.2'

      - name: Show Xcode version
        run: xcodebuild -version

      - name: Create ASC API key file
        env:
          ASC_KEY_ID: ${{ secrets.ASC_KEY_ID }}
          ASC_KEY_P8_BASE64: ${{ secrets.ASC_KEY_P8_BASE64 }}
        run: |
          mkdir -p .ci_keys
          # macOS runner(base64 BSD) 기준 디코드 옵션은 -D
          echo "$ASC_KEY_P8_BASE64" | base64 -D > ".ci_keys/AuthKey_${ASC_KEY_ID}.p8"
          ls -la .ci_keys

      - name: Create ExportOptions.plist (IPA export)
        run: |
          cat > ExportOptions.plist <<'PLIST'
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
            <key>method</key>
            <string>app-store-connect</string>
            <key>signingStyle</key>
            <string>automatic</string>
            <key>teamID</key>
            <string>FL4QTRRKMD</string>
            <key>stripSwiftSymbols</key>
            <true/>
            <key>uploadSymbols</key>
            <true/>
          </dict>
          </plist>
          PLIST

      - name: Archive
        env:
          ASC_KEY_ID: ${{ secrets.ASC_KEY_ID }}
          ASC_ISSUER_ID: ${{ secrets.ASC_ISSUER_ID }}
        run: |
          xcodebuild \
            -project MyBiasLevelUp.xcodeproj \
            -scheme MyBiasLevelUp \
            -configuration Release \
            -destination 'generic/platform=iOS' \
            -archivePath build/MyBiasLevelUp.xcarchive \
            -allowProvisioningUpdates \
            -authenticationKeyPath ".ci_keys/AuthKey_${ASC_KEY_ID}.p8" \
            -authenticationKeyID "$ASC_KEY_ID" \
            -authenticationKeyIssuerID "$ASC_ISSUER_ID" \
            archive

      - name: Export IPA
        env:
          ASC_KEY_ID: ${{ secrets.ASC_KEY_ID }}
          ASC_ISSUER_ID: ${{ secrets.ASC_ISSUER_ID }}
        run: |
          xcodebuild \
            -exportArchive \
            -archivePath build/MyBiasLevelUp.xcarchive \
            -exportPath build/export \
            -exportOptionsPlist ExportOptions.plist \
            -allowProvisioningUpdates \
            -authenticationKeyPath ".ci_keys/AuthKey_${ASC_KEY_ID}.p8" \
            -authenticationKeyID "$ASC_KEY_ID" \
            -authenticationKeyIssuerID "$ASC_ISSUER_ID"

          ls -la build/export

      - name: Upload to TestFlight
        env:
          ASC_KEY_ID: ${{ secrets.ASC_KEY_ID }}
          ASC_ISSUER_ID: ${{ secrets.ASC_ISSUER_ID }}
        run: |
          xcrun altool \
            --upload-app \
            --type ios \
            --file build/export/MyBiasLevelUp.ipa \
            --apiKey "$ASC_KEY_ID" \
            --apiIssuer "$ASC_ISSUER_ID" \
            --verbose

      - name: Upload artifacts (debug)
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: ios-release-artifacts
          path: |
            build/export/*.ipa
            build/MyBiasLevelUp.xcarchive
            ExportOptions.plist
```

## 2) 핵심 명령어만 따로 보기

로컬/CI 공통으로 핵심은 아래 3개입니다.

1. Archive
```bash
xcodebuild \
  -project MyBiasLevelUp.xcodeproj \
  -scheme MyBiasLevelUp \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/MyBiasLevelUp.xcarchive \
  -allowProvisioningUpdates \
  archive
```

2. IPA Export
```bash
xcodebuild \
  -exportArchive \
  -archivePath build/MyBiasLevelUp.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist
```

3. TestFlight Upload
```bash
xcrun altool \
  --upload-app \
  --type ios \
  --file build/export/MyBiasLevelUp.ipa \
  --apiKey "$ASC_KEY_ID" \
  --apiIssuer "$ASC_ISSUER_ID" \
  --verbose
```

## 3) 자주 실패하는 포인트

1. `No Accounts` 또는 signing 실패
- API Key 권한/값 오타 확인
- `-authenticationKeyPath/-authenticationKeyID/-authenticationKeyIssuerID` 전달 여부 확인

2. `missingApp(bundleId...)`
- App Store Connect에 해당 Bundle ID 앱이 실제로 생성되어 있어야 함

3. `No signing certificate` / `No provisioning profile`
- 자동 서명이 실패한 경우. API Key 권한 부족 가능성 큼
- 필요한 경우 수동 인증서(.p12) + 프로비저닝(.mobileprovision) 방식으로 전환

4. CI와 다른 커밋으로 배포됨
- `actions/checkout`에 `ref: ${{ github.event.workflow_run.head_sha }}`가 반드시 있어야 함

## 4) 프로젝트 설정 체크 포인트

`xcodegen generate`를 쓰는 프로젝트라면, `project.yml`에도 팀 설정을 넣어두는 것을 권장합니다.

예시:

```yaml
targets:
  MyBiasLevelUp:
    settings:
      base:
        DEVELOPMENT_TEAM: FL4QTRRKMD
        CODE_SIGN_STYLE: Automatic
```

이 설정이 없으면, 생성 시점에 팀 설정이 빠져 CI signing이 다시 깨질 수 있습니다.
