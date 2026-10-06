# 1. Patch Xcode Project
pbxproj = File.read("App/NKSFConverter/NKSFConverter.xcodeproj/project.pbxproj")
pbxproj.gsub!(/MACOSX_DEPLOYMENT_TARGET = .*?;/, "MACOSX_DEPLOYMENT_TARGET = 11.0;")
pbxproj.gsub!(/ONLY_ACTIVE_ARCH = YES;/, "ONLY_ACTIVE_ARCH = NO;")
File.write("App/NKSFConverter/NKSFConverter.xcodeproj/project.pbxproj", pbxproj)

# 2. Patch Swift Package
pkg = File.read("Packages/NKSCore/Package.swift")
if !pkg.include?("platforms:")
    pkg.sub!("name: \"NKSCore\",", "name: \"NKSCore\",\n    platforms: [.macOS(.v11)],")
    File.write("Packages/NKSCore/Package.swift", pkg)
end

# 3. Patch build_release.sh
build_sh = File.read("build_release.sh")
build_sh.sub!("cmake -DCMAKE_BUILD_TYPE=Release .. > /dev/null", "cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_OSX_ARCHITECTURES=\"arm64;x86_64\" .. > /dev/null")
build_sh.sub!("-configuration Release \\", "-configuration Release \\\n           ARCHS=\"arm64 x86_64\" \\\n           ONLY_ACTIVE_ARCH=NO \\")
File.write("build_release.sh", build_sh)

