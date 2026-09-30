content = File.read("App/NKSFConverter/NKSFConverter/AppModel.swift")

# Remove from init
content.sub!(/        scanInstalledPlugins\(\)\n    \}/, "    }")

# Add startScanningIfNeeded
new_func = %Q{    private var hasScanned = false
    func startScanningIfNeeded() {
        guard !hasScanned else { return }
        hasScanned = true
        scanInstalledPlugins()
    }

    func scanInstalledPlugins()}
content.sub!("    func scanInstalledPlugins()", new_func)

File.write("App/NKSFConverter/NKSFConverter/AppModel.swift", content)
