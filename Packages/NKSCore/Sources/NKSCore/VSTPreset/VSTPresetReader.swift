import Foundation

public struct VSTPresetChunk {
    public let id: String
    public let offset: UInt64
    public let size: UInt64
    public let data: Data
}

public struct VSTPresetModel {
    public let classID: String // 32 hex chars
    public let chunks: [VSTPresetChunk]
}

public enum VSTPresetError: Error {
    case invalidSignature
    case invalidVersion
    case invalidChunkList
    case truncatedFile
}

public struct VSTPresetReader {
    public static func parse(data: Data) throws -> VSTPresetModel {
        let data = Data(data)
        guard data.count >= 48 else {
            throw VSTPresetError.truncatedFile
        }
        
        let signature = String(data: data[0..<4], encoding: .ascii)
        guard signature == "VST3" else {
            throw VSTPresetError.invalidSignature
        }
        
        let version = data[4..<8].withUnsafeBytes { $0.loadUnaligned(as: Int32.self) }
        guard version == 1 else {
            throw VSTPresetError.invalidVersion
        }
        
        let classIDData = data[8..<40]
        let classID = String(data: classIDData, encoding: .ascii) ?? ""
        
        let listOffset = data[40..<48].withUnsafeBytes { $0.loadUnaligned(as: Int64.self) }
        
        guard Int(listOffset) + 8 <= data.count else {
            throw VSTPresetError.invalidChunkList
        }
        
        let listSignature = String(data: data[Int(listOffset)..<Int(listOffset)+4], encoding: .ascii)
        guard listSignature == "List" else {
            throw VSTPresetError.invalidChunkList
        }
        
        let entryCount = data[Int(listOffset)+4..<Int(listOffset)+8].withUnsafeBytes { $0.loadUnaligned(as: Int32.self) }
        
        var chunks: [VSTPresetChunk] = []
        var currentOffset = Int(listOffset) + 8
        
        for _ in 0..<entryCount {
            guard currentOffset + 20 <= data.count else {
                throw VSTPresetError.invalidChunkList
            }
            
            let chunkIdData = data[currentOffset..<currentOffset+4]
            let chunkId = String(data: chunkIdData, encoding: .ascii)?.trimmingCharacters(in: .controlCharacters) ?? ""
            
            let chunkDataOffset = data[currentOffset+4..<currentOffset+12].withUnsafeBytes { $0.loadUnaligned(as: Int64.self) }
            let chunkDataSize = data[currentOffset+12..<currentOffset+20].withUnsafeBytes { $0.loadUnaligned(as: Int64.self) }
            
            guard Int(chunkDataOffset) + Int(chunkDataSize) <= data.count else {
                throw VSTPresetError.invalidChunkList
            }
            
            let chunkData = data[Int(chunkDataOffset)..<Int(chunkDataOffset)+Int(chunkDataSize)]
            
            chunks.append(VSTPresetChunk(id: chunkId, offset: UInt64(chunkDataOffset), size: UInt64(chunkDataSize), data: chunkData))
            
            currentOffset += 20
        }
        
        return VSTPresetModel(classID: classID, chunks: chunks)
    }
}
