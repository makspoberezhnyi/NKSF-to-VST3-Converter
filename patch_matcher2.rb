content = File.read("Packages/NKSCore/Sources/NKSCore/PluginID/Matcher.swift")

old_code = %Q{                    if !foundCompat {
                        // Check derived ID prefix directly against class ID
                        let prefix = UIDConverter.vst2DerivedUIDPrefix(magic: magic)
                        if classID.hasPrefix(prefix) {
                            matches.append(PluginMatch(plugin: plugin, classID: classID, confidence: .likely))
                        }
                    }}

new_code = %Q{                    if !foundCompat {
                        // Check derived ID prefix directly against class ID
                        let prefix = UIDConverter.vst2DerivedUIDPrefix(magic: magic)
                        let rawMagicHex = String(format: "%08X", UInt32(bitPattern: magic.bigEndian))
                        
                        if classID.hasPrefix(prefix) {
                            matches.append(PluginMatch(plugin: plugin, classID: classID, confidence: .likely))
                        } else if classID.hasPrefix("4172747541564953") && classID.contains(rawMagicHex) {
                            // Arturia specific CID format: ArtuAVIS + magic + Proc
                            matches.append(PluginMatch(plugin: plugin, classID: classID, confidence: .likely))
                        } else if classID.contains(rawMagicHex) {
                            // Broad fallback
                            matches.append(PluginMatch(plugin: plugin, classID: classID, confidence: .guess))
                        }
                    }}

content.sub!(old_code, new_code)
File.write("Packages/NKSCore/Sources/NKSCore/PluginID/Matcher.swift", content)
