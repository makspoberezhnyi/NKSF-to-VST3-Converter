import Foundation

public struct UIDConverter {
    public static func vst3UIDToString(uidArray: [UInt32]) -> String {
        // UID is 4 uint32s. 
        // VST3 FUID toString prints the 16 bytes as hex.
        // The spec says: convert each uint32 to big endian.
        var bytes: [UInt8] = []
        for val in uidArray {
            let be = val.bigEndian
            bytes.append(contentsOf: Swift.withUnsafeBytes(of: be) { Array($0) })
        }
        
        return bytes.map { String(format: "%02X", $0) }.joined()
    }
    
    public static func vst2DerivedUIDPrefix(magic: Int32) -> String {
        // VST3 derived ID is "565354" (VST) + 8 hex chars (the magic) + 18 chars of name.
        // We return the 14-char prefix.
        // 'magic' is a 4-character code packed into int32.
        // The 8 hex chars represent this int32.
        
        let hex = String(format: "%08X", UInt32(bitPattern: magic.bigEndian))
        return "565354" + hex
    }
}
