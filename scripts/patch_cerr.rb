content = File.read("Host/nks-host/main.cpp")
content.gsub!("std::cout <<", "std::cerr <<")
File.write("Host/nks-host/main.cpp", content)
