build_sh = File.read("build_release.sh")
build_sh.sub!("cmake -DCMAKE_BUILD_TYPE=Release", "cmake -G Xcode -DCMAKE_BUILD_TYPE=Release")
File.write("build_release.sh", build_sh)
