# 1. Update AppModel.swift to support Auto-Scan toggle and Prefix names
content = File.read("App/NKSFConverter/NKSFConverter/AppModel.swift")

# Add autoScan property
old_props = "    @Published var logText = \"\"\n    @Published var isProcessing = false\n    \n    @Published var missingPlugins = [MissingPluginRequirement]()\n    @Published var showMissingPlugins = false"
new_props = "    @Published var logText = \"\"\n    @Published var isProcessing = false\n    @Published var autoScanSystem = true\n    \n    @Published var missingPlugins = [MissingPluginRequirement]()\n    @Published var showMissingPlugins = false"
content.sub!(old_props, new_props)

# Skip scanning if autoScan is false
old_scan = "    func processDroppedFolders(urls: [URL]) {\n        self.isProcessing = true\n        self.knownPlugins = self.scanner.scanInstalledPlugins()\n        self.pendingJobs.removeAll()\n        self.missingPlugins.removeAll()"
new_scan = "    func processDroppedFolders(urls: [URL]) {\n        self.isProcessing = true\n        if autoScanSystem {\n            self.log(\"Auto-scanning system VST3 folder...\")\n            self.knownPlugins = self.scanner.scanInstalledPlugins()\n        } else {\n            self.log(\"Skipping system scan (auto-scan disabled).\")\n        }\n        self.pendingJobs.removeAll()\n        self.missingPlugins.removeAll()"
content.sub!(old_scan, new_scan)

# Prepend Plugin Name to Output File
old_out = "                    let finalOutURL = pluginDir.appendingPathComponent(job.nksfURL.lastPathComponent).deletingPathExtension().appendingPathExtension(\"vstpreset\")"
new_out = "                    let originalName = job.nksfURL.lastPathComponent\n                    let baseName = (originalName as NSString).deletingPathExtension\n                    let strictName = \"\\(actualPluginName) - \\(baseName).vstpreset\"\n                    let finalOutURL = pluginDir.appendingPathComponent(strictName)"
content.sub!(old_out, new_out)

File.write("App/NKSFConverter/NKSFConverter/AppModel.swift", content)

# 2. Update ContentView.swift to add the Toggle
cv = File.read("App/NKSFConverter/NKSFConverter/ContentView.swift")
old_cv = "            Text(\"NKSF to VST3 Converter\")\n                .font(.largeTitle)\n                .padding(.top)\n            \n            ZStack {"
new_cv = "            Text(\"NKSF to VST3 Converter\")\n                .font(.largeTitle)\n                .padding(.top)\n            \n            Toggle(\"Auto-Scan System VST3 Folder\", isOn: $model.autoScanSystem)\n                .padding(.horizontal)\n            \n            ZStack {"
cv.sub!(old_cv, new_cv)
File.write("App/NKSFConverter/NKSFConverter/ContentView.swift", cv)

