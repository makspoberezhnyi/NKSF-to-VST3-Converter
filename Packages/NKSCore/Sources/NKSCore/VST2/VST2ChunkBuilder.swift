import Foundation

public struct VST2ChunkBuilder {
    
    public static func buildVstW() -> Data {
        var data = Data()
        data.append(contentsOf: "VstW".utf8)
        data.append(contentsOf: Swift.withUnsafeBytes(of: Int32(8).bigEndian, { Array($0) }))
        data.append(contentsOf: Swift.withUnsafeBytes(of: Int32(1).bigEndian, { Array($0) }))
        data.append(contentsOf: Swift.withUnsafeBytes(of: Int32(0).bigEndian, { Array($0) }))
        return data
    }
    
    public static func buildFPCh(fxID: Int32, fxVersion: Int32 = 1, name: String, chunkData: Data) -> Data {
        var data = Data()
        
        // chunkMagic "FPCh" or "FBCh"
        data.append(contentsOf: "FPCh".utf8)
        
        // byteSize (size of chunk header + data minus 8 bytes)
        // Usually 152 + data.count - 8 = 144 + data.count
        let byteSize = Int32(144 + chunkData.count)
        data.append(contentsOf: Swift.withUnsafeBytes(of: byteSize.bigEndian, { Array($0) }))
        
        // fxMagic "FxCk" (opaque chunk)
        data.append(contentsOf: "FxCk".utf8)
        
        // version (1)
        data.append(contentsOf: Swift.withUnsafeBytes(of: Int32(1).bigEndian, { Array($0) }))
        
        // fxID
        data.append(contentsOf: Swift.withUnsafeBytes(of: fxID.bigEndian, { Array($0) }))
        
        // fxVersion
        data.append(contentsOf: Swift.withUnsafeBytes(of: fxVersion.bigEndian, { Array($0) }))
        
        // numPrograms
        data.append(contentsOf: Swift.withUnsafeBytes(of: Int32(1).bigEndian, { Array($0) }))
        
        // prgName (28 bytes)
        var nameData = name.data(using: .ascii) ?? Data()
        if nameData.count > 28 {
            nameData = nameData.prefix(28)
        } else if nameData.count < 28 {
            nameData.append(Data(repeating: 0, count: 28 - nameData.count))
        }
        data.append(nameData)
        
        // chunkSize
        data.append(contentsOf: Swift.withUnsafeBytes(of: Int32(chunkData.count).bigEndian, { Array($0) }))
        data.append(chunkData)
        
        return data
    }

    public static func build(magic: Int, isFXB: Bool, pluginData: Data) -> Data {
        let vstw = buildVstW()
        let magic32 = Int32(magic)
        let payload: Data
        if isFXB {
            payload = buildFPCh(fxID: magic32, name: "Preset", chunkData: pluginData)
        } else {
            payload = buildFPCh(fxID: magic32, name: "Preset", chunkData: pluginData)
        }
        return vstw + payload
    }
}
