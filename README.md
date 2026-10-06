# NKSF to VST3 Converter (PresetBridge)

This project contains a utility to convert NKSF presets to VST3 formats. It consists of a C++ VST3 Host Helper and a macOS SwiftUI frontend application called **PresetBridge**.

## Building the Release

To build the release application and generate a DMG installer, you can use the provided build script:

```bash
./build_release.sh
```

### Prerequisites
- macOS
- Xcode & Xcode Command Line Tools
- Homebrew (with `cmake` installed)

### Build Steps Explained
The `build_release.sh` script automates the following steps:
1. **C++ VST3 Host Helper**: Builds the underlying C++ helper using CMake and Xcode.
2. **SwiftUI App**: Builds the frontend macOS application via Xcode, embedding the C++ helper.
3. **DMG Installer**: Packages the final `PresetBridge.app` into a mountable `.dmg` image for distribution.
