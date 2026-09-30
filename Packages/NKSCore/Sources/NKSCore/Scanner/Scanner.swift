import Foundation

public struct ScannedPlugin {
    public let bundlePath: URL
    public let moduleInfo: ModuleInfo
    
    public init(bundlePath: URL, moduleInfo: ModuleInfo) {
        self.bundlePath = bundlePath
        self.moduleInfo = moduleInfo
    }
}

public class Scanner {
    private let hostHelperURL: URL?
    
    public init(hostHelperURL: URL? = nil) {
        self.hostHelperURL = hostHelperURL
    }
    
        public func scanFile(at fileURL: URL) throws -> ScannedPlugin? {
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

    public func scan(at directoryURL: URL) throws -> [ScannedPlugin] {
        var plugins = [ScannedPlugin]()
        let fm = FileManager.default
        
        guard let enumerator = fm.enumerator(at: directoryURL, includingPropertiesForKeys: [.isDirectoryKey]) else {
            return plugins
        }
        
        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension.lowercased() == "vst3" {
                if let info = parseModuleInfo(in: fileURL) {
                    plugins.append(ScannedPlugin(bundlePath: fileURL, moduleInfo: info))
                } else if let hostHelperURL = hostHelperURL {
                    if let fallbackInfo = scanWithHost(bundleURL: fileURL, hostHelperURL: hostHelperURL) {
                        plugins.append(ScannedPlugin(bundlePath: fileURL, moduleInfo: fallbackInfo))
                    }
                }
                enumerator.skipDescendants()
            }
        }
        return plugins
    }
    
    private func parseModuleInfo(in bundleURL: URL) -> ModuleInfo? {
        let infoURL = bundleURL.appendingPathComponent("Contents/Resources/moduleinfo.json")
        guard let data = try? Data(contentsOf: infoURL) else { return nil }
        
        guard let rawString = String(data: data, encoding: .utf8) else { return nil }
        
        let noComments = rawString.replacingOccurrences(of: "(?s)/\\*.*?\\*/", with: "", options: .regularExpression)
        let noTrailing = noComments.replacingOccurrences(of: ",\\s*([}\\]])", with: "$1", options: .regularExpression)
        
        guard let cleanData = noTrailing.data(using: .utf8) else { return nil }
        
        do {
            let decoder = JSONDecoder()
            let info = try decoder.decode(ModuleInfo.self, from: cleanData)
            return info
        } catch {
            return nil
        }
    }
    
    private func scanWithHost(bundleURL: URL, hostHelperURL: URL) -> ModuleInfo? {
        let process = Process()
        process.executableURL = hostHelperURL
        process.arguments = ["scan", bundleURL.path]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            if process.terminationStatus == 0, let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                var classes = [PluginClass]()
                for cls in jsonArray {
                    if let cid = cls["CID"] as? String,
                       let name = cls["Name"] as? String,
                       let category = cls["Category"] as? String {
                        classes.append(PluginClass(cid: cid, category: category, name: name))
                    }
                }
                
                return ModuleInfo(
                    name: bundleURL.deletingPathExtension().lastPathComponent,
                    version: "1.0",
                    vendor: "Unknown",
                    classes: classes
                )
            }
        } catch {
            print("Fallback scan failed for \(bundleURL.lastPathComponent): \(error)")
        }
        return nil
    }
}
