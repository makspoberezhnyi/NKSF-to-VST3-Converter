import Foundation

public enum ConversionStrategy {
    case rawPCHK
    case vst2Chunk(magic: Int, isFXB: Bool)
}

public struct ConversionResult {
    public let componentState: Data
    public let controllerState: Data?
}

public class Converter {
    private let hostHelperURL: URL
    
    public init(hostHelperURL: URL) {
        self.hostHelperURL = hostHelperURL
    }
    
    public func convert(
        bundlePath: String,
        classID: String,
        pchkData: Data,
        strategy: ConversionStrategy
    ) throws -> ConversionResult {
        
        let stateToLoad: Data
        switch strategy {
        case .rawPCHK:
            stateToLoad = pchkData
        case .vst2Chunk(let magic, let isFXB):
            stateToLoad = VST2ChunkBuilder.build(magic: magic, isFXB: isFXB, pluginData: pchkData)
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let inStateURL = tempDir.appendingPathComponent(UUID().uuidString + ".in.bin")
        let outCompURL = tempDir.appendingPathComponent(UUID().uuidString + ".out_comp.bin")
        let outContURL = tempDir.appendingPathComponent(UUID().uuidString + ".out_cont.bin")
        
        defer {
            try? FileManager.default.removeItem(at: inStateURL)
            try? FileManager.default.removeItem(at: outCompURL)
            try? FileManager.default.removeItem(at: outContURL)
        }
        
        try stateToLoad.write(to: inStateURL)
        
        let process = Process()
        process.executableURL = hostHelperURL
        process.arguments = [
            "convert",
            bundlePath,
            classID,
            inStateURL.path,
            outCompURL.path,
            outContURL.path
        ]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            throw NSError(domain: "Converter", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "nks-host failed or crashed"])
        }
        
        let compState = try Data(contentsOf: outCompURL)
        let contState = (try? Data(contentsOf: outContURL)) ?? Data()
        
        return ConversionResult(
            componentState: compState,
            controllerState: contState.isEmpty ? nil : contState
        )
    }
}
