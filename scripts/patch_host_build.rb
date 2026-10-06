build_sh = File.read("build_release.sh")
build_sh.sub!("cd Host\nmkdir -p build && cd build", "cd Host\nrm -rf build\nmkdir build && cd build")
File.write("build_release.sh", build_sh)
