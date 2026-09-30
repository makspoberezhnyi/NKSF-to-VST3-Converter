#!/bin/bash
cd App/NKSFConverter
xcodebuild -workspace NKSFConverter.xcworkspace -scheme NKSFConverter -configuration Debug build
open ~/Library/Developer/Xcode/DerivedData/NKSFConverter-*/Build/Products/Debug/NKSFConverter.app
