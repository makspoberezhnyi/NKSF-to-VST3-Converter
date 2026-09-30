import XCTest
@testable import NKSCore

final class VSTPresetReaderTests: XCTestCase {
    
    func testValidPreset() throws {
        var data = Data()
        data.append(contentsOf: "VST3".utf8)
        data.append(contentsOf: Swift.withUnsafeBytes(of: Int32(1).littleEndian, { Array($0) })) // version
        data.append(contentsOf: "0123456789ABCDEF0123456789ABCDEF".utf8) // 32 hex chars
        
        let chunkListOffset: Int64 = 48 + 10 // Comp data is 10 bytes
        data.append(contentsOf: Swift.withUnsafeBytes(of: chunkListOffset.littleEndian, { Array($0) }))
        
        // Chunk Data
        data.append(Data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])) // 10 bytes at offset 48
        
        // List
        data.append(contentsOf: "List".utf8) // at offset 58
        data.append(contentsOf: Swift.withUnsafeBytes(of: Int32(1).littleEndian, { Array($0) })) // entryCount = 1
        
        // Entry 1
        data.append(contentsOf: "Comp".utf8)
        data.append(contentsOf: Swift.withUnsafeBytes(of: Int64(48).littleEndian, { Array($0) })) // offset = 48
        data.append(contentsOf: Swift.withUnsafeBytes(of: Int64(10).littleEndian, { Array($0) })) // size = 10
        
        let model = try VSTPresetReader.parse(data: data)
        XCTAssertEqual(model.classID, "0123456789ABCDEF0123456789ABCDEF")
        XCTAssertEqual(model.chunks.count, 1)
        XCTAssertEqual(model.chunks[0].id, "Comp")
        XCTAssertEqual(model.chunks[0].offset, 48)
        XCTAssertEqual(model.chunks[0].size, 10)
        XCTAssertEqual(model.chunks[0].data, Data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]))
    }
}
