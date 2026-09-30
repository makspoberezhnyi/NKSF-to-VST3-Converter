#!/bin/bash
set -e

export PATH="/opt/homebrew/bin:$PATH"

echo "======================================"
echo "    Building PresetBridge Release     "
echo "======================================"

# Clean previous builds
rm -rf ReleaseBuild
mkdir ReleaseBuild

# 1. Build C++ Host Helper
echo "[1/3] Building C++ VST3 Host Helper..."
cd Host
rm -rf build
mkdir build && cd build
cmake -G Xcode -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0 -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" .. > /dev/null
xcodebuild -project nks-host.xcodeproj -configuration Release -target nks-host build > /dev/null
cd ../..

# Copy the built helper so the Xcode project can bundle it
mkdir -p App/NKSFConverter/Helper
cp Host/build/Release/nks-host App/NKSFConverter/Helper/

# 2. Build Swift App
echo "[2/3] Building SwiftUI App..."
cd App/NKSFConverter

# Build an archive to ensure Release configuration and proper layout
xcodebuild -workspace NKSFConverter.xcworkspace \
           -scheme NKSFConverter \
           -configuration Release \
           ARCHS="arm64 x86_64" \
           ONLY_ACTIVE_ARCH=NO \
           -archivePath "../../ReleaseBuild/PresetBridge.xcarchive" \
           archive > /dev/null

# Extract the .app from the archive
cp -R "../../ReleaseBuild/PresetBridge.xcarchive/Products/Applications/NKSFConverter.app" "../../ReleaseBuild/PresetBridge.app"
cd ../..

# 3. Create DMG
echo "[3/3] Creating DMG Installer..."
cd ReleaseBuild
mkdir -p DMG_Root
cp -R PresetBridge.app DMG_Root/
ln -s /Applications DMG_Root/Applications

hdiutil create -volname "PresetBridge" -srcfolder DMG_Root -ov -format UDZO PresetBridge.dmg > /dev/null

echo "======================================"
echo "          Build Successful!           "
echo "======================================"
echo "Your DMG is located at: $(pwd)/ReleaseBuild/PresetBridge.dmg"
