import XCTest
@testable import NKSCore

final class NKSFTests: XCTestCase {
    
    func testNKSFParser() throws {
        var data = Data()
        data.append(contentsOf: "RIFF".utf8)
        
        let chunk1Id = "NISI"
        var chunk1Data = Data()
        chunk1Data.append(contentsOf: Swift.withUnsafeBytes(of: UInt32(1).littleEndian, { Array($0) })) // version
        chunk1Data.append(Data([0x81, 0xa4, 0x6e, 0x61, 0x6d, 0x65, 0xa4, 0x74, 0x65, 0x73, 0x74])) // {"name": "test"}
        // count = 15, needs pad
        
        let chunk2Id = "PCHK"
        var chunk2Data = Data()
        chunk2Data.append(contentsOf: Swift.withUnsafeBytes(of: UInt32(1).littleEndian, { Array($0) })) // version
        chunk2Data.append(Data([0x01, 0x02, 0x03])) // count 7, needs pad
        
        let chunkSize = 4 + (8 + chunk1Data.count + 1) + (8 + chunk2Data.count + 1)
        data.append(contentsOf: Swift.withUnsafeBytes(of: UInt32(chunkSize).littleEndian, { Array($0) }))
        data.append(contentsOf: "NIKS".utf8)
        
        data.append(contentsOf: chunk1Id.utf8)
        data.append(contentsOf: Swift.withUnsafeBytes(of: UInt32(chunk1Data.count).littleEndian, { Array($0) }))
        data.append(chunk1Data)
        data.append(Data([0])) // pad
        
        data.append(contentsOf: chunk2Id.utf8)
        data.append(contentsOf: Swift.withUnsafeBytes(of: UInt32(chunk2Data.count).littleEndian, { Array($0) }))
        data.append(chunk2Data)
        data.append(Data([0])) // pad
        
        let model = try NKSFParser.parse(data: data)
        if case .map(let dict) = model.metadata {
            XCTAssertEqual(dict[.string("name")], .string("test"))
        } else {
            XCTFail("metadata should be map")
        }
        
        XCTAssertEqual(model.pluginState, Data([0x01, 0x02, 0x03]))
    }
}
