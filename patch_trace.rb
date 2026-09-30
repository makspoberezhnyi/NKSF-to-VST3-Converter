content = File.read("App/NKSFConverter/NKSFConverter/AppModel.swift")
content.gsub!('self.log("Scanning /Library/Audio/Plug-Ins/VST3 for installed plugins...")', 
              "self.log(\"Scanning /Library/Audio/Plug-Ins/VST3 for installed plugins...\")\n            self.log(\"Starting scanner.scan...\")")
File.write("App/NKSFConverter/NKSFConverter/AppModel.swift", content)
