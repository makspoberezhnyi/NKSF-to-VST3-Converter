import Foundation

public struct RIFFChunk {
    public let id: String
    public let data: Data
    
    public init(id: String, data: Data) {
        self.id = id
        self.data = data
    }
}

public enum RIFFError: Error, Equatable {
    case invalidSignature
    case invalidSize
    case truncatedFile
    case invalidFormType(String)
}

public struct RIFFParser {
    public static func parse(data: Data, expectedFormType: String? = nil) throws -> [RIFFChunk] {
        let data = Data(data) // normalize index
        guard data.count >= 12 else {
            throw RIFFError.truncatedFile
        }
        
        let signature = String(data: data[0..<4], encoding: .ascii)
        guard signature == "RIFF" else {
            throw RIFFError.invalidSignature
        }
        
        let size = data[4..<8].withUnsafeBytes { $0.loadUnaligned(as: UInt32.self) }
        guard data.count >= Int(size) + 8 else {
            throw RIFFError.truncatedFile
        }
        
        let formType = String(data: data[8..<12], encoding: .ascii)
        if let expected = expectedFormType, formType != expected {
            throw RIFFError.invalidFormType(formType ?? "nil")
        }
        
        var chunks: [RIFFChunk] = []
        var offset = 12
        let endOffset = Int(size) + 8
        
        while offset + 8 <= endOffset {
            let chunkIdData = data[offset..<offset+4]
            let chunkId = String(data: chunkIdData, encoding: .ascii) ?? ""
            let chunkSize = Int(data[offset+4..<offset+8].withUnsafeBytes { $0.loadUnaligned(as: UInt32.self) })
            
            offset += 8
            if offset + chunkSize > endOffset {
                throw RIFFError.truncatedFile
            }
            
            let chunkData = data[offset..<offset+chunkSize]
            chunks.append(RIFFChunk(id: chunkId, data: chunkData))
            
            offset += chunkSize
            if chunkSize % 2 != 0 {
                offset += 1 // padding byte
            }
        }
        
        return chunks
    }
}
