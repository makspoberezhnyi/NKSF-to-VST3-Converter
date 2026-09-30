content = File.read("Host/nks-host/HostContext.h")
content.gsub!("#pragma once", "#pragma once\n#include \"pluginterfaces/base/ustring.h\"")
content.gsub!("String str(\"NKSFTOVST3\");", "UString str(\"NKSFTOVST3\");")
File.write("Host/nks-host/HostContext.h", content)
