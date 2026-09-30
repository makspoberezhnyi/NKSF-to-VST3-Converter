import XCTest
@testable import NKSCore

final class MessagePackTests: XCTestCase {
    
    func testNil() throws {
        let val = try MessagePackDecoder.decode(data: Data([0xc0]))
        XCTAssertEqual(val, .nil)
    }
    
    func testBools() throws {
        XCTAssertEqual(try MessagePackDecoder.decode(data: Data([0xc2])), .bool(false))
        XCTAssertEqual(try MessagePackDecoder.decode(data: Data([0xc3])), .bool(true))
    }
    
    func testPositiveFixInt() throws {
        XCTAssertEqual(try MessagePackDecoder.decode(data: Data([0x00])), .uint(0))
        XCTAssertEqual(try MessagePackDecoder.decode(data: Data([0x7f])), .uint(127))
    }
    
    func testNegativeFixInt() throws {
        XCTAssertEqual(try MessagePackDecoder.decode(data: Data([0xe0])), .int(-32))
        XCTAssertEqual(try MessagePackDecoder.decode(data: Data([0xff])), .int(-1))
    }
    
    func testUInt8() throws {
        XCTAssertEqual(try MessagePackDecoder.decode(data: Data([0xcc, 0xff])), .uint(255))
    }
    
    func testFloat32() throws {
        let bytes: [UInt8] = [0xca, 0x3f, 0x80, 0x00, 0x00] // 1.0
        XCTAssertEqual(try MessagePackDecoder.decode(data: Data(bytes)), .float(1.0))
    }
    
    func testFixStr() throws {
        let bytes: [UInt8] = [0xa4, 0x74, 0x65, 0x73, 0x74] // "test"
        XCTAssertEqual(try MessagePackDecoder.decode(data: Data(bytes)), .string("test"))
    }
    
    func testFixArray() throws {
        let bytes: [UInt8] = [0x92, 0xc2, 0xc3] // [false, true]
        XCTAssertEqual(try MessagePackDecoder.decode(data: Data(bytes)), .array([.bool(false), .bool(true)]))
    }
    
    func testFixMap() throws {
        // {"a": 1}
        let bytes: [UInt8] = [0x81, 0xa1, 0x61, 0x01]
        XCTAssertEqual(try MessagePackDecoder.decode(data: Data(bytes)), .map([.string("a"): .uint(1)]))
    }
}
