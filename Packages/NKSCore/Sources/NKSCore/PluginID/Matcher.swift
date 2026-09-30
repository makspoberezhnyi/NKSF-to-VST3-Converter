import Foundation

public enum MatchConfidence: String, Codable {
    case exact
    case likely
    case guess
    case manual
}

public struct PluginMatch {
    public let plugin: ScannedPlugin
    public let classID: String
    public let confidence: MatchConfidence
}

public struct Matcher {
    public static func match(nksf: NKSFModel, availablePlugins: [ScannedPlugin]) -> [PluginMatch] {
        var matches: [PluginMatch] = []
        
        guard let plid = nksf.pluginId else { return [] }
        
        var isVST3 = false
        var vst3UIDString: String? = nil
        var vst2Magic: Int32? = nil
        
        if case .map(let dict) = plid {
            if let vst3Val = dict[.string("VST3.uid")], case .array(let arr) = vst3Val {
                if arr.count == 4 {
                    let uints = arr.compactMap { val -> UInt32? in
                        if case .uint(let u) = val { return UInt32(u) }
                        if case .int(let i) = val { return UInt32(bitPattern: Int32(i)) }
                        return nil
                    }
                    if uints.count == 4 {
                        isVST3 = true
                        vst3UIDString = UIDConverter.vst3UIDToString(uidArray: uints)
                    }
                }
            } else if let vst2Val = dict[.string("VST.magic")] {
                if case .uint(let u) = vst2Val { vst2Magic = Int32(bitPattern: UInt32(u)) }
                if case .int(let i) = vst2Val { vst2Magic = Int32(i) }
            }
        }
        
        for plugin in availablePlugins {
            let info = plugin.moduleInfo
            
            for cls in info.classes where cls.category == "Audio Module Class" {
                let classID = cls.cid.uppercased().replacingOccurrences(of: "-", with: "")
                
                if isVST3, let targetUID = vst3UIDString {
                    if classID == targetUID {
                        matches.append(PluginMatch(plugin: plugin, classID: classID, confidence: .exact))
                    }
                } else if let magic = vst2Magic {
                    // Check compatibility table
                    var foundCompat = false
                    if let compats = info.compatibility {
                        for comp in compats {
                            let oldId = comp.old.map { $0.uppercased().replacingOccurrences(of: "-", with: "") }
                            let prefix = UIDConverter.vst2DerivedUIDPrefix(magic: magic)
                            // In compatibility, the "old" ID is usually the fully derived 32-char ID.
                            // We can match prefix.
                            if oldId.contains(where: { $0.hasPrefix(prefix) }) {
                                matches.append(PluginMatch(plugin: plugin, classID: classID, confidence: .exact))
                                foundCompat = true
                                break
                            }
                        }
                    }
                    
                    if !foundCompat {
                        // Check derived ID prefix directly against class ID
                        let prefix = UIDConverter.vst2DerivedUIDPrefix(magic: magic)
                        let rawMagicHex = String(format: "%08X", UInt32(bitPattern: magic))
                        
                        if classID.hasPrefix(prefix) {
                            matches.append(PluginMatch(plugin: plugin, classID: classID, confidence: .likely))
                        } else if classID.hasPrefix("4172747541564953") && classID.contains(rawMagicHex) {
                            // Arturia specific CID format: ArtuAVIS + magic + Proc
                            matches.append(PluginMatch(plugin: plugin, classID: classID, confidence: .likely))
                        } else if classID.contains(rawMagicHex) {
                            // Broad fallback
                            matches.append(PluginMatch(plugin: plugin, classID: classID, confidence: .guess))
                        }
                    }
                }
            }
            
            // Name similarity could be implemented here
            if let metadata = nksf.metadata, case .map(let dict) = metadata {
                if let vendorVal = dict[.string("vendor")], case .string(let vendorStr) = vendorVal,
                   let nameVal = dict[.string("name")], case .string(let nameStr) = nameVal {
                    
                    let normVendor = vendorStr.lowercased()
                    let normName = nameStr.lowercased()
                    
                    if info.name.lowercased().contains(normName) || info.vendor.lowercased().contains(normVendor) {
                        // Add as guess if we don't have it already
                        if !matches.contains(where: { $0.plugin.bundlePath == plugin.bundlePath }) {
                            if let firstAudioClass = info.classes.first(where: { $0.category == "Audio Module Class" }) {
                                let cid = firstAudioClass.cid.uppercased().replacingOccurrences(of: "-", with: "")
                                matches.append(PluginMatch(plugin: plugin, classID: cid, confidence: .guess))
                            }
                        }
                    }
                }
            }
        }
        
        return matches.sorted { m1, m2 in
            let ranks: [MatchConfidence: Int] = [.exact: 0, .likely: 1, .guess: 2, .manual: 3]
            return ranks[m1.confidence]! < ranks[m2.confidence]!
        }
    }
}
