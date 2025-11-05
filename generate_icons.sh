#!/bin/bash

# Generate App Icons for Miles
# This script generates iOS and Android app icons from logo_app.png

echo "🎨 Generating app icons for Miles..."
echo ""

# Step 1: Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Step 2: Generate icons
echo ""
echo "🚀 Generating icons..."
flutter pub run flutter_launcher_icons

# Step 3: Clean build
echo ""
echo "🧹 Cleaning build..."
flutter clean

# Step 4: iOS specific cleanup
echo ""
echo "🍎 Cleaning iOS build..."
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

echo ""
echo "✅ Done! Your app icons have been generated."
echo ""
echo "Next steps:"
echo "1. Run: flutter run"
echo "2. Check your app icon on the home screen"
echo ""
