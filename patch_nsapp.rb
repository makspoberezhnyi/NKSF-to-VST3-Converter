content = File.read("Host/nks-host/main.cpp")
unless content.include?("NSApplicationLoad()")
  content = "#include <Cocoa/Cocoa.h>\n" + content
  old_main = "int main(int argc, char* argv[]) {"
  new_main = "int main(int argc, char* argv[]) {\n    NSApplicationLoad();"
  content.sub!(old_main, new_main)
  File.write("Host/nks-host/main.cpp", content)
end
