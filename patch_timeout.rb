# 1. AppModel.swift
content = File.read("App/NKSFConverter/NKSFConverter/AppModel.swift")
old_process = "    func processDroppedFolders(urls: [URL]) {\n        self.isProcessing = true\n        if autoScanSystem {\n            self.log(\"Auto-scanning system VST3 folder...\")\n            self.knownPlugins = self.scanner.scanInstalledPlugins()\n        } else {\n            self.log(\"Skipping system scan (auto-scan disabled).\")\n        }\n        self.pendingJobs.removeAll()\n        self.missingPlugins.removeAll()\n        \n        DispatchQueue.global(qos: .userInitiated).async {"
new_process = "    func processDroppedFolders(urls: [URL]) {\n        self.isProcessing = true\n        self.pendingJobs.removeAll()\n        self.missingPlugins.removeAll()\n        \n        DispatchQueue.global(qos: .userInitiated).async {\n            if self.autoScanSystem {\n                DispatchQueue.main.async { self.log(\"Auto-scanning system VST3 folder...\") }\n                self.knownPlugins = self.scanner.scanInstalledPlugins()\n            } else {\n                DispatchQueue.main.async { self.log(\"Skipping system scan (auto-scan disabled).\") }\n            }"
content.sub!(old_process, new_process)
File.write("App/NKSFConverter/NKSFConverter/AppModel.swift", content)

# 2. Converter.swift
converter = File.read("Packages/NKSCore/Sources/NKSCore/Converter/Converter.swift")
old_conv = "        let pipe = Pipe()\n        process.standardOutput = pipe\n        \n        try process.run()\n        process.waitUntilExit()\n        \n        guard process.terminationStatus == 0 else {"
new_conv = "        let pipe = Pipe()\n        process.standardOutput = pipe\n        \n        try process.run()\n        \n        var timeout = 10.0\n        while process.isRunning && timeout > 0 {\n            Thread.sleep(forTimeInterval: 0.1)\n            timeout -= 0.1\n        }\n        \n        if process.isRunning {\n            process.terminate()\n            throw NSError(domain: \"Converter\", code: -1, userInfo: [NSLocalizedDescriptionKey: \"Conversion timed out after 10 seconds. Plugin might be showing a dialog.\"])\n        }\n        \n        guard process.terminationStatus == 0 else {"
converter.sub!(old_conv, new_conv)
File.write("Packages/NKSCore/Sources/NKSCore/Converter/Converter.swift", converter)

# 3. Scanner.swift
scanner = File.read("Packages/NKSCore/Sources/NKSCore/Scanner/Scanner.swift")
old_scan = "        try process.run()\n        \n        let data = pipe.fileHandleForReading.readDataToEndOfFile()\n        process.waitUntilExit()\n        \n        guard process.terminationStatus == 0 else {"
new_scan = "        try process.run()\n        \n        var timeout = 5.0\n        while process.isRunning && timeout > 0 {\n            Thread.sleep(forTimeInterval: 0.1)\n            timeout -= 0.1\n        }\n        \n        if process.isRunning {\n            process.terminate()\n            throw NSError(domain: \"Scanner\", code: -1, userInfo: [NSLocalizedDescriptionKey: \"Scanner timed out after 5 seconds.\"])\n        }\n        \n        let data = pipe.fileHandleForReading.readDataToEndOfFile()\n        \n        guard process.terminationStatus == 0 else {"
scanner.sub!(old_scan, new_scan)
File.write("Packages/NKSCore/Sources/NKSCore/Scanner/Scanner.swift", scanner)
