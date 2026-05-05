# Louisiana Delta Community College Student Resources Web Application

A Flutter web application for Louisiana Delta Community College student resources, including the class schedule and employee directory.

Production Link: [https://web01.ladelta.edu](https://web01.ladelta.edu)

## Fully responsive layouts

### Desktop
![image](https://user-images.githubusercontent.com/8235002/205153775-b10c6614-1afa-429f-9342-ed9bce386a3a.png)

### Mobile
![image](https://user-images.githubusercontent.com/8235002/205154037-2ce336b4-ef66-49bc-a54b-5da64b30b676.png)

### Course Details Modal
![image](https://user-images.githubusercontent.com/8235002/205154326-679e4c9d-d1a6-4840-82d9-c6369fe3c026.png)


## Requirements

- Flutter SDK
- Chrome or Edge for local web testing
- IIS with Static Content enabled for Windows hosting 
- IIS URL Rewrite module for SPA/deep-link routing support

## Development

Run locally in Chrome:

```bash
flutter run -d chrome
```

## Build for web

Standard optimized web build:

```bash
flutter build web --release
```

Output is written to:

```text
build/web
```

Flutter web release builds are minified by default. On current Flutter versions, `--obfuscate` is not supported for web builds. 

If you want to test WebAssembly support:

```bash
flutter build web --release --wasm
```

Only use the Wasm build after validating it in your target browsers. Flutter’s standard web build uses CanvasKit by default unless Wasm mode is enabled. 

## Deploy to IIS

For a root-site deployment on IIS:

1. Build the app:
   ```bash
   flutter build web --release
   ```

2. Copy the contents of `build/web/` into the IIS site root, typically:
   ```text
   C:\inetpub\wwwroot\
   ```
   or into the application folder for the site, such as:
   ```text
   C:\inetpub\wwwroot\studentresources\
   ```
   

3. Ensure IIS has **Static Content** enabled. Flutter web is a static site composed of HTML, JavaScript, fonts, images, and manifest files. 

4. Configure SPA route rewriting with a `web.config` file so direct navigation to routes like `/schedule/fall/2026` or `/directory/monroe` resolves to `index.html` instead of returning 404. 

Example `web.config`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <rule name="Flutter SPA Routes" stopProcessing="true">
          <match url=".*" />
          <conditions logicalGrouping="MatchAll">
            <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
            <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
          </conditions>
          <action type="Rewrite" url="/index.html" />
        </rule>
      </rules>
    </rewrite>
    <staticContent>
      <mimeMap fileExtension=".wasm" mimeType="application/wasm" />
      <mimeMap fileExtension=".json" mimeType="application/json" />
      <mimeMap fileExtension=".webp" mimeType="image/webp" />
      <mimeMap fileExtension=".riv" mimeType="application/octet-stream" />
    </staticContent>
  </system.webServer>
</configuration>
```

## Deploy under a subfolder

If the app is hosted under a virtual directory or subpath instead of the web root, build with the correct base href. The base path must start and end with `/`. 

Example:

```bash
flutter build web --release --base-href /studentresources/
```

Then deploy the contents of `build/web/` to:

```text
C:\inetpub\wwwroot\studentresources\
```

If the base href is wrong, static assets and route loads can fail with 404 errors. 

## IIS notes

- Enable HTTPS in IIS for production. Many modern browser features work best, or only work fully, on secure origins.
- If deep links fail on refresh, check the URL Rewrite module and confirm `web.config` is present in the deployed site root.
- If assets fail to load from a subfolder deployment, verify the `--base-href` value used during build. 
- If you test a Wasm build, ensure IIS serves `.wasm` with `application/wasm`.
- The app currently includes an older custom/service-worker-related web bootstrap path in `web/index.html`; Flutter’s default service worker approach is deprecated and being phased out in newer Flutter versions.

## Versioning and tags

This repository uses Git tags for release/version markers. To list tags locally:

```bash
git tag
```

To inspect a specific tagged release:

```bash
git checkout <tag-name>
```

Annotated tags are useful for marking deployable versions and pairing them with GitHub Releases. 

## Useful commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
flutter build web --release
flutter build web --release --base-href /studentresources/
flutter build web --release --wasm
git tag
```

## Notable Libraries Used:
[Flutter Modular](https://pub.dev/packages/flutter_modular)

<a href="https://pub.dev/packages/flutter_modular"><img src="https://external-images.pub.dev/6IlIDWjwYn4rocO5eS2izvhRY2K3u2xnc7hWWkyujk0%3D/1777939200000/https%3A%2F%2Fraw.githubusercontent.com%2FFlutterando%2Fmodular%2Fmaster%2Fflutter_modular.png" width="265" ></a>

[Responsive Framework](https://github.com/Codelessly/ResponsiveFramework)

[![Responsive Framework Logo](https://raw.githubusercontent.com/Codelessly/ResponsiveFramework/master/packages/Built%20with%20Responsive%20Badge.png "Built with Responsive Framework")](https://github.com/Codelessly/ResponsiveFramework)

