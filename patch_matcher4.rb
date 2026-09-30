content = File.read("Packages/NKSCore/Sources/NKSCore/PluginID/Matcher.swift")
content.gsub!('let rawMagicHex = String(format: "%08X", UInt32(bitPattern: magic.bigEndian))', 'let rawMagicHex = String(format: "%08X", UInt32(bitPattern: magic))')
File.write("Packages/NKSCore/Sources/NKSCore/PluginID/Matcher.swift", content)
