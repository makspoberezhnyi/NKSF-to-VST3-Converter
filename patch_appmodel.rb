content = File.read("App/NKSFConverter/NKSFConverter/AppModel.swift")
content.sub!(/if let helper = bundle.url\(forResource: "nks-host", withExtension: nil\) \{.*?\}/m, %Q{if let helper = bundle.url(forAuxiliaryExecutable: "nks-host") {
            self.hostHelperURL = helper
        } else if let exec = bundle.executableURL?.deletingLastPathComponent().appendingPathComponent("nks-host"), FileManager.default.fileExists(atPath: exec.path) {
            self.hostHelperURL = exec
        }})
File.write("App/NKSFConverter/NKSFConverter/AppModel.swift", content)
