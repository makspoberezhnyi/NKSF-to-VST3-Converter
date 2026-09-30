content = File.read("Packages/NKSCore/Sources/NKSCore/PluginID/Matcher.swift")
content.sub!(/let rawMagicHex = String\\(format: "%08X", UInt32\\(bitPattern: magic.bigEndian\\)\\)/, %Q{let rawMagicHex = String(format: "%08X", UInt32(bitPattern: magic))})
File.write("Packages/NKSCore/Sources/NKSCore/PluginID/Matcher.swift", content)
