content = File.read("Host/CMakeLists.txt")
content.gsub!("\"-framework CoreServices\"", "\"-framework CoreServices\" \"-framework Cocoa\"")
File.write("Host/CMakeLists.txt", content)
