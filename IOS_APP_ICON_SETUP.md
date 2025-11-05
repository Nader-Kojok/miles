# 📱 iOS App Icon Setup Guide - Miles

## Overview
iOS requires multiple icon sizes for different devices and contexts. Your `logo_app.png` needs to be converted into various sizes and placed in the correct location.

## Required Icon Sizes

iOS requires these specific sizes:

| Size | Filename | Purpose |
|------|----------|---------|
| 20x20 @1x | Icon-App-20x20@1x.png | iPad Notifications |
| 20x20 @2x | Icon-App-20x20@2x.png | iPhone Notifications |
| 20x20 @3x | Icon-App-20x20@3x.png | iPhone Notifications |
| 29x29 @1x | Icon-App-29x29@1x.png | iPad Settings |
| 29x29 @2x | Icon-App-29x29@2x.png | iPhone Settings |
| 29x29 @3x | Icon-App-29x29@3x.png | iPhone Settings |
| 40x40 @1x | Icon-App-40x40@1x.png | iPad Spotlight |
| 40x40 @2x | Icon-App-40x40@2x.png | iPhone Spotlight |
| 40x40 @3x | Icon-App-40x40@3x.png | iPhone Spotlight |
| 60x60 @2x | Icon-App-60x60@2x.png | iPhone App (120x120) |
| 60x60 @3x | Icon-App-60x60@3x.png | iPhone App (180x180) |
| 76x76 @1x | Icon-App-76x76@1x.png | iPad App |
| 76x76 @2x | Icon-App-76x76@2x.png | iPad App (152x152) |
| 83.5x83.5 @2x | Icon-App-83.5x83.5@2x.png | iPad Pro (167x167) |
| 1024x1024 @1x | Icon-App-1024x1024@1x.png | App Store |

## 🚀 Quick Setup Methods

### Method 1: Using Online Tool (Easiest) ⭐

1. **Go to AppIcon.co**
   - Visit: https://www.appicon.co/
   
2. **Upload your logo**
   - Upload `assets/logo_app.png`
   - Make sure it's at least 1024x1024 pixels
   
3. **Download the generated icons**
   - Click "Generate" 
   - Download the iOS icons package
   
4. **Replace the icons**
   - Extract the downloaded files
   - Copy all the PNG files to: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
   - Replace the existing icon files

### Method 2: Using ImageMagick (Command Line)

If you have ImageMagick installed, run these commands from your project root:

```bash
cd ios/Runner/Assets.xcassets/AppIcon.appiconset/

# Source image (make sure it's 1024x1024 or larger)
SOURCE="../../../assets/logo_app.png"

# Generate all required sizes
magick $SOURCE -resize 20x20 Icon-App-20x20@1x.png
magick $SOURCE -resize 40x40 Icon-App-20x20@2x.png
magick $SOURCE -resize 60x60 Icon-App-20x20@3x.png
magick $SOURCE -resize 29x29 Icon-App-29x29@1x.png
magick $SOURCE -resize 58x58 Icon-App-29x29@2x.png
magick $SOURCE -resize 87x87 Icon-App-29x29@3x.png
magick $SOURCE -resize 40x40 Icon-App-40x40@1x.png
magick $SOURCE -resize 80x80 Icon-App-40x40@2x.png
magick $SOURCE -resize 120x120 Icon-App-40x40@3x.png
magick $SOURCE -resize 120x120 Icon-App-60x60@2x.png
magick $SOURCE -resize 180x180 Icon-App-60x60@3x.png
magick $SOURCE -resize 76x76 Icon-App-76x76@1x.png
magick $SOURCE -resize 152x152 Icon-App-76x76@2x.png
magick $SOURCE -resize 167x167 Icon-App-83.5x83.5@2x.png
magick $SOURCE -resize 1024x1024 Icon-App-1024x1024@1x.png
```

### Method 3: Using Xcode (Manual)

1. **Open Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Navigate to Assets**
   - In the left sidebar, click on `Runner` → `Assets.xcassets` → `AppIcon`

3. **Drag and drop**
   - Drag your `logo_app.png` (must be 1024x1024) into the "App Store iOS 1024pt" slot
   - Xcode can auto-generate other sizes (in newer versions)

### Method 4: Using flutter_launcher_icons Package (Automated) 🎯

This is the **recommended Flutter way**:

1. **Add to pubspec.yaml**:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  ios: true
  android: false  # We'll handle Android separately
  image_path: "assets/logo_app.png"
  remove_alpha_ios: true  # iOS doesn't support transparency
```

2. **Run the generator**:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

3. **Clean and rebuild**:
```bash
cd ios
pod install
cd ..
flutter clean
flutter build ios
```

## ⚠️ Important Requirements

### Image Requirements:
- **Size**: Minimum 1024x1024 pixels (recommended)
- **Format**: PNG (no transparency for iOS)
- **Color Space**: RGB
- **No rounded corners**: iOS adds them automatically
- **No transparency**: iOS doesn't support alpha channels in app icons

### Design Tips:
- Keep important content in the center
- Avoid text smaller than 6pt
- Test on different backgrounds (light/dark mode)
- Make sure the icon is recognizable at small sizes

## 🧪 Testing

After updating the icons:

1. **Clean build**:
```bash
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

2. **Run on simulator**:
```bash
flutter run
```

3. **Check the home screen** to see your new icon

## 📁 File Location

Your icons should be placed here:
```
ios/
└── Runner/
    └── Assets.xcassets/
        └── AppIcon.appiconset/
            ├── Contents.json
            ├── Icon-App-20x20@1x.png
            ├── Icon-App-20x20@2x.png
            ├── Icon-App-20x20@3x.png
            ├── Icon-App-29x29@1x.png
            ├── Icon-App-29x29@2x.png
            ├── Icon-App-29x29@3x.png
            ├── Icon-App-40x40@1x.png
            ├── Icon-App-40x40@2x.png
            ├── Icon-App-40x40@3x.png
            ├── Icon-App-60x60@2x.png
            ├── Icon-App-60x60@3x.png
            ├── Icon-App-76x76@1x.png
            ├── Icon-App-76x76@2x.png
            ├── Icon-App-83.5x83.5@2x.png
            └── Icon-App-1024x1024@1x.png
```

## 🔧 Troubleshooting

### Icon not showing up?
- Clean build folder: `flutter clean`
- Delete app from simulator/device
- Rebuild and reinstall

### Icon looks blurry?
- Ensure source image is high resolution (1024x1024+)
- Check that you're using PNG format
- Verify no compression artifacts

### Build errors?
- Check that all required sizes are present
- Verify `Contents.json` is correct
- Ensure no transparency in images

## 📚 References

- [Apple Human Interface Guidelines - App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Flutter Launcher Icons Package](https://pub.dev/packages/flutter_launcher_icons)
- [AppIcon.co - Icon Generator](https://www.appicon.co/)
