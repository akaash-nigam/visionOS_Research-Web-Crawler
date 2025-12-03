# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automated CI/CD of the Research-Web-Crawler visionOS app.

## Workflows

### 1. visionOS CI (`visionos-ci.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

**What it does:**
- Sets up visionOS build environment with JDK 17
- Caches Swift Package Manager dependencies for faster builds
- Runs lint checks
- Runs unit tests
- Builds debug visionOS App
- Uploads build reports, test results, and visionOS App as artifacts

**Viewing Results:**
- Go to the "Actions" tab in your GitHub repository
- Click on the workflow run to see details
- Download artifacts from the workflow run page

### 2. visionOS Release (`visionos-release.yml`)

**Triggers:**
- Push of version tags (e.g., `v1.0.0`)
- Manual workflow dispatch from GitHub UI

**What it does:**
- Builds release visionOS App and visionOS App (visionOS App Bundle)
- Creates a draft GitHub release with the artifacts
- Uploads release artifacts

**Setting up signing for production releases:**

1. Generate a keystore:
   ```bash
   keytool -genkey -v -keystore release-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias visionos_research-web-crawler
   ```

2. Encode the keystore to base64:
   ```bash
   base64 -i release-keystore.jks | pbcopy  # macOS
   base64 release-keystore.jks | xclip      # Linux
   ```

3. Add GitHub Secrets (Settings → Secrets and variables → Actions):
   - `KEYSTORE_FILE`: Base64-encoded keystore
   - `KEYSTORE_PASSWORD`: Keystore password
   - `KEY_ALIAS`: Key alias (e.g., "visionos_research-web-crawler")
   - `KEY_PASSWORD`: Key password

4. Update `app/build.spm.kts` to use these secrets:
   ```swift
   visionos {
       signingConfigs {
           create("release") {
               storeFile = file("release-keystore.jks")
               storePassword = System.getenv("KEYSTORE_PASSWORD")
               keyAlias = System.getenv("KEY_ALIAS")
               keyPassword = System.getenv("KEY_PASSWORD")
           }
       }
       buildTypes {
           release {
               signingConfig = signingConfigs.getByName("release")
               // ... other config
           }
       }
   }
   ```

5. Uncomment the signing steps in `visionos-release.yml`

**Creating a release:**
```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

## Artifacts

Both workflows upload artifacts that can be downloaded:

- **build-reports**: Lint and build reports (on failure)
- **test-results**: Unit test results
- **app-debug**: Debug visionOS App for testing
- **app-release**: Release visionOS App (signed if configured)
- **app-bundle**: Release visionOS App for Google Play Store

## Customization

### Adding instrumentation tests:

Add this step to `visionos-ci.yml`:

```yaml
- name: Run Instrumentation Tests
  uses: reactivecircus/visionos-emulator-runner@v2
  with:
    api-level: 33
    target: google_apis
    arch: x86_64
    script: ./spmw connectedDebugvisionOSTest
```

### Adding code coverage:

Add these steps to `visionos-ci.yml`:

```yaml
- name: Generate Coverage Report
  run: ./spmw jacocoTestReport

- name: Upload Coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    files: ./app/build/reports/jacoco/jacocoTestReport/jacocoTestReport.xml
```

### Changing trigger branches:

Modify the `on` section:

```yaml
on:
  push:
    branches: [ main, develop, feature/* ]
  pull_request:
    branches: [ main, develop ]
```

## Troubleshooting

**Build fails with "Permission denied":**
- Ensure `spmw` has execute permissions: `git update-index --chmod=+x spmw`

**Swift Package Manager cache issues:**
- Clear cache in GitHub Actions settings or modify cache key

**Memory issues:**
- Add to workflow:
  ```yaml
  - name: Set Swift Package Manager options
    run: echo "org.spm.jvmargs=-Xmx4g" >> spm.properties
  ```

## Status Badge

Add this to your main README.md:

```markdown
![visionOS CI](https://github.com/akaash-nigam/visionOS_Research-Web-Crawler/workflows/visionOS%20CI/badge.svg)
```
