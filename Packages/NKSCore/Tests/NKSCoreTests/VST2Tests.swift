import XCTest
@testable import NKSCore

final class VST2ChunkBuilderTests: XCTestCase {
    
    func testVstW() {
        let data = VST2ChunkBuilder.buildVstW()
        XCTAssertEqual(data.count, 16)
        
        let header = String(data: data[0..<4], encoding: .ascii)
        XCTAssertEqual(header, "VstW")
        
        let size = Int(data[4..<8].withUnsafeBytes { $0.loadUnaligned(as: Int32.self).bigEndian })
        XCTAssertEqual(size, 8)
        
        let version = Int(data[8..<12].withUnsafeBytes { $0.loadUnaligned(as: Int32.self).bigEndian })
        XCTAssertEqual(version, 1)
        
        let bypass = Int(data[12..<16].withUnsafeBytes { $0.loadUnaligned(as: Int32.self).bigEndian })
        XCTAssertEqual(bypass, 0)
    }
    
    func testFPCh() {
        let chunkData = Data([0, 1, 2, 3])
        let data = VST2ChunkBuilder.buildFPCh(fxID: 1234, name: "TestProgram", chunkData: chunkData)
        
        XCTAssertEqual(String(data: data[0..<4], encoding: .ascii), "CcnK")
        let totalSize = Int(data[4..<8].withUnsafeBytes { $0.loadUnaligned(as: Int32.self).bigEndian })
        XCTAssertEqual(totalSize, 4 + 4 + 4 + 4 + 4 + 28 + 4 + 4)
        XCTAssertEqual(String(data: data[8..<12], encoding: .ascii), "FPCh")
    }
    
    func testFBCh() {
        let chunkData = Data([0, 1, 2, 3])
        let data = VST2ChunkBuilder.buildFBCh(fxID: 1234, chunkData: chunkData)
        
        XCTAssertEqual(String(data: data[0..<4], encoding: .ascii), "CcnK")
        let totalSize = Int(data[4..<8].withUnsafeBytes { $0.loadUnaligned(as: Int32.self).bigEndian })
        XCTAssertEqual(totalSize, 152 + 4) // FBCh header is 152, chunk data is 4
        XCTAssertEqual(String(data: data[8..<12], encoding: .ascii), "FBCh")
    }
}
