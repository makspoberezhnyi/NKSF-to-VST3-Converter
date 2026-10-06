content = File.read("Host/nks-host/main.cpp")
content.gsub!("#include <Cocoa/Cocoa.h>\\n", "")
content.gsub!("NSApplicationLoad();", "")
File.write("Host/nks-host/main.cpp", content)
