import XCTest
@testable import NKSCore

final class RIFFTests: XCTestCase {
    
    func testValidRIFF() throws {
        var data = Data()
        data.append(contentsOf: "RIFF".utf8)
        let chunkSize: UInt32 = 4 + 8 + 4 + 8 + 5 // NIKS (4) + id (4) + size (4) + data (4) + id (4) + size (4) + data (5 + 1 pad)
        data.append(contentsOf: Swift.withUnsafeBytes(of: chunkSize.littleEndian, { Array($0) }))
        data.append(contentsOf: "NIKS".utf8)
        
        // Chunk 1
        data.append(contentsOf: "TST1".utf8)
        data.append(contentsOf: Swift.withUnsafeBytes(of: UInt32(4).littleEndian, { Array($0) }))
        data.append(Data([0, 1, 2, 3]))
        
        // Chunk 2 (odd size)
        data.append(contentsOf: "TST2".utf8)
        data.append(contentsOf: Swift.withUnsafeBytes(of: UInt32(5).littleEndian, { Array($0) }))
        data.append(Data([0, 1, 2, 3, 4]))
        data.append(Data([0])) // pad byte
        
        let chunks = try RIFFParser.parse(data: data, expectedFormType: "NIKS")
        XCTAssertEqual(chunks.count, 2)
        XCTAssertEqual(chunks[0].id, "TST1")
        XCTAssertEqual(chunks[0].data, Data([0, 1, 2, 3]))
        XCTAssertEqual(chunks[1].id, "TST2")
        XCTAssertEqual(chunks[1].data, Data([0, 1, 2, 3, 4]))
    }
    
    func testInvalidSignature() throws {
        var data = Data()
        data.append(contentsOf: "RxFF".utf8)
        data.append(contentsOf: Swift.withUnsafeBytes(of: UInt32(4).littleEndian, { Array($0) }))
        data.append(contentsOf: "NIKS".utf8)
        
        XCTAssertThrowsError(try RIFFParser.parse(data: data)) { error in
            XCTAssertEqual(error as? RIFFError, RIFFError.invalidSignature)
        }
    }
    
    func testTruncatedChunk() throws {
        var data = Data()
        data.append(contentsOf: "RIFF".utf8)
        let chunkSize: UInt32 = 4 + 8 + 4 // NIKS + TST1 + size(4)
        data.append(contentsOf: Swift.withUnsafeBytes(of: chunkSize.littleEndian, { Array($0) }))
        data.append(contentsOf: "NIKS".utf8)
        
        data.append(contentsOf: "TST1".utf8)
        data.append(contentsOf: Swift.withUnsafeBytes(of: UInt32(4).littleEndian, { Array($0) }))
        data.append(Data([0, 1, 2])) // missing 1 byte!
        
        XCTAssertThrowsError(try RIFFParser.parse(data: data)) { error in
            XCTAssertEqual(error as? RIFFError, RIFFError.truncatedFile)
        }
    }
}
