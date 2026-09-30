content = File.read("Packages/NKSCore/Sources/NKSCore/Scanner/Scanner.swift")
if !content.include?("public func scanFile(at fileURL: URL)")
  new_func = %Q{    public func scanFile(at fileURL: URL) throws -> ScannedPlugin? {
        guard fileURL.pathExtension.lowercased() == "vst3" else { return nil }
        if let info = parseModuleInfo(in: fileURL) {
            return ScannedPlugin(bundlePath: fileURL, moduleInfo: info)
        } else if let hostHelperURL = hostHelperURL {
            if let fallbackInfo = scanWithHost(bundleURL: fileURL, hostHelperURL: hostHelperURL) {
                return ScannedPlugin(bundlePath: fileURL, moduleInfo: fallbackInfo)
            }
        }
        return nil
    }

    public func scan(at directoryURL: URL)}
  content.sub!("public func scan(at directoryURL: URL)", new_func)
  File.write("Packages/NKSCore/Sources/NKSCore/Scanner/Scanner.swift", content)
end
