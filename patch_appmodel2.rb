content = File.read("App/NKSFConverter/NKSFConverter/AppModel.swift")
old_loop = %Q{            // Re-run fallback scans for chosen bundles
            for req in self.missingPlugins {
                if let url = req.resolvedBundleURL {
                    if let newInfo = try? self.scanner.scan(at: url.deletingLastPathComponent()).first(where: { $0.bundlePath == url }) {
                         DispatchQueue.main.async {
                             self.knownPlugins.append(newInfo)
                         }
                    }
                }
            }}
new_loop = %Q{            // Scan specifically chosen bundles
            for req in self.missingPlugins {
                if let url = req.resolvedBundleURL {
                    if let newInfo = try? self.scanner.scanFile(at: url) {
                         DispatchQueue.main.async {
                             self.knownPlugins.append(newInfo)
                         }
                         // Also force-inject the magic if the plugin didn't declare it (Arturia fallback)
                         // Wait, Matcher uses UID or magic. Arturia uses magic inside UID!
                    }
                }
            }}
content.sub!(old_loop, new_loop)
File.write("App/NKSFConverter/NKSFConverter/AppModel.swift", content)
