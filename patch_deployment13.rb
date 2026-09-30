# 1. Patch Xcode Project
pbxproj = File.read("App/NKSFConverter/NKSFConverter.xcodeproj/project.pbxproj")
pbxproj.gsub!(/MACOSX_DEPLOYMENT_TARGET = 11\.0;/, "MACOSX_DEPLOYMENT_TARGET = 13.0;")
File.write("App/NKSFConverter/NKSFConverter.xcodeproj/project.pbxproj", pbxproj)

# 2. Patch Swift Package
pkg = File.read("Packages/NKSCore/Package.swift")
pkg.sub!(".macOS(.v11)", ".macOS(.v13)")
File.write("Packages/NKSCore/Package.swift", pkg)

# 3. Patch build_release.sh
build_sh = File.read("build_release.sh")
build_sh.sub!("-DCMAKE_OSX_DEPLOYMENT_TARGET=11.0", "-DCMAKE_OSX_DEPLOYMENT_TARGET=13.0")
File.write("build_release.sh", build_sh)

