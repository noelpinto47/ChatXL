#!/bin/bash
# ChatXL - Play Store Release Build Script
# Run this after completing key.properties setup

set -e  # Exit on error

echo "🚀 ChatXL Release Build Script"
echo "================================"

# Step 1: Clean previous builds
echo "📦 Step 1: Cleaning previous builds..."
flutter clean

# Step 2: Get dependencies
echo "📥 Step 2: Getting dependencies..."
flutter pub get

# Step 3: Run analysis
echo "🔍 Step 3: Running Flutter analyze..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "❌ Analysis found issues. Please fix them before building."
    exit 1
fi

# Step 4: Check for keystore
echo "🔑 Step 4: Checking keystore configuration..."
if [ ! -f "android/key.properties" ]; then
    echo "❌ ERROR: android/key.properties not found!"
    echo "Please create this file with your keystore information."
    echo "See PLAY_STORE_RELEASE_CHECKLIST.md for instructions."
    exit 1
fi

# Step 5: Build App Bundle
echo "🏗️  Step 5: Building release App Bundle..."
flutter build appbundle --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! Release build completed."
    echo "================================"
    echo "📱 App Bundle location:"
    echo "   build/app/outputs/bundle/release/app-release.aab"
    echo ""
    echo "📤 Next steps:"
    echo "   1. Upload app-release.aab to Play Console"
    echo "   2. Complete store listing"
    echo "   3. Submit for review"
    echo ""
    echo "📋 See PLAY_STORE_RELEASE_CHECKLIST.md for details"
else
    echo "❌ Build failed. Please check the errors above."
    exit 1
fi
