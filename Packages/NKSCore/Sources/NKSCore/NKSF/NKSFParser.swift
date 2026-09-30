import Foundation

public struct NKSFModel {
    public let metadata: MessagePackValue? // NISI
    public let controllerAssignments: MessagePackValue? // NICA
    public let pluginId: MessagePackValue? // PLID
    public let pluginState: Data? // PCHK payload (after version field)
    public let unknownChunks: [String]
}

public enum NKSFError: Error {
    case invalidRIFF
    case unsupportedVersion
}

public struct NKSFParser {
    public static func parse(data: Data) throws -> NKSFModel {
        let chunks = try RIFFParser.parse(data: data, expectedFormType: "NIKS")
        
        var metadata: MessagePackValue? = nil
        var nica: MessagePackValue? = nil
        var plid: MessagePackValue? = nil
        var pchk: Data? = nil
        var unknownChunks: [String] = []
        
        for chunk in chunks {
            switch chunk.id {
            case "NISI":
                guard chunk.data.count >= 4 else { continue }
                let msgpackData = Data(chunk.data.dropFirst(4))
                print("Decoding NISI")
                metadata = try? MessagePackDecoder.decode(data: msgpackData)
                print("Decoded NISI")
                
            case "NICA":
                guard chunk.data.count >= 4 else { continue }
                let msgpackData = Data(chunk.data.dropFirst(4))
                nica = try? MessagePackDecoder.decode(data: msgpackData)
                
            case "PLID":
                guard chunk.data.count >= 4 else { continue }
                let msgpackData = Data(chunk.data.dropFirst(4))
                plid = try? MessagePackDecoder.decode(data: msgpackData)
                
            case "PCHK":
                guard chunk.data.count >= 4 else { continue }
                pchk = Data(chunk.data.dropFirst(4))
                
            default:
                unknownChunks.append(chunk.id)
            }
        }
        
        return NKSFModel(
            metadata: metadata,
            controllerAssignments: nica,
            pluginId: plid,
            pluginState: pchk,
            unknownChunks: unknownChunks
        )
    }
}
