import Foundation

public enum MessagePackValue: Equatable {
    case `nil`
    case bool(Bool)
    case int(Int64)
    case uint(UInt64)
    case float(Float)
    case double(Double)
    case string(String)
    case binary(Data)
    case array([MessagePackValue])
    case map([MessagePackValue: MessagePackValue])
    case ext(type: Int8, data: Data)
}

extension MessagePackValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .nil: hasher.combine(0)
        case .bool(let v): hasher.combine(1); hasher.combine(v)
        case .int(let v): hasher.combine(2); hasher.combine(v)
        case .uint(let v): hasher.combine(3); hasher.combine(v)
        case .float(let v): hasher.combine(4); hasher.combine(v)
        case .double(let v): hasher.combine(5); hasher.combine(v)
        case .string(let v): hasher.combine(6); hasher.combine(v)
        case .binary(let v): hasher.combine(7); hasher.combine(v)
        case .array(let v): hasher.combine(8); hasher.combine(v)
        case .map(let v): hasher.combine(9); hasher.combine(v)
        case .ext(let t, let d): hasher.combine(10); hasher.combine(t); hasher.combine(d)
        }
    }
}

public enum MessagePackError: Error {
    case outOfBounds
    case invalidFormat(UInt8)
    case invalidString
}

public struct MessagePackDecoder {
    public static func decode(data: Data) throws -> MessagePackValue {
        let normalizedData = Data(data)
        var offset = 0
        return try decode(data: normalizedData, offset: &offset)
    }
    
    private static func decode(data: Data, offset: inout Int) throws -> MessagePackValue {
        guard offset < data.count else { throw MessagePackError.outOfBounds }
        let byte = data[offset]
        offset += 1
        
        switch byte {
        case 0x00...0x7f: // positive fixint
            return .uint(UInt64(byte))
        case 0x80...0x8f: // fixmap
            let count = Int(byte & 0x0f)
            return try decodeMap(count: count, data: data, offset: &offset)
        case 0x90...0x9f: // fixarray
            let count = Int(byte & 0x0f)
            return try decodeArray(count: count, data: data, offset: &offset)
        case 0xa0...0xbf: // fixstr
            let count = Int(byte & 0x1f)
            return try decodeString(count: count, data: data, offset: &offset)
        case 0xc0: // nil
            return .nil
        case 0xc2: // false
            return .bool(false)
        case 0xc3: // true
            return .bool(true)
        case 0xc4: // bin 8
            let count = try readUInt8(data: data, offset: &offset)
            return try decodeBinary(count: Int(count), data: data, offset: &offset)
        case 0xc5: // bin 16
            let count = try readUInt16(data: data, offset: &offset)
            return try decodeBinary(count: Int(count), data: data, offset: &offset)
        case 0xc6: // bin 32
            let count = try readUInt32(data: data, offset: &offset)
            return try decodeBinary(count: Int(count), data: data, offset: &offset)
        case 0xc7: // ext 8
            let count = try readUInt8(data: data, offset: &offset)
            let type = try readInt8(data: data, offset: &offset)
            return try decodeExt(count: Int(count), type: type, data: data, offset: &offset)
        case 0xc8: // ext 16
            let count = try readUInt16(data: data, offset: &offset)
            let type = try readInt8(data: data, offset: &offset)
            return try decodeExt(count: Int(count), type: type, data: data, offset: &offset)
        case 0xc9: // ext 32
            let count = try readUInt32(data: data, offset: &offset)
            let type = try readInt8(data: data, offset: &offset)
            return try decodeExt(count: Int(count), type: type, data: data, offset: &offset)
        case 0xca: // float 32
            let bitPattern = try readUInt32(data: data, offset: &offset)
            return .float(Float(bitPattern: bitPattern))
        case 0xcb: // float 64
            let bitPattern = try readUInt64(data: data, offset: &offset)
            return .double(Double(bitPattern: bitPattern))
        case 0xcc: // uint 8
            return .uint(UInt64(try readUInt8(data: data, offset: &offset)))
        case 0xcd: // uint 16
            return .uint(UInt64(try readUInt16(data: data, offset: &offset)))
        case 0xce: // uint 32
            return .uint(UInt64(try readUInt32(data: data, offset: &offset)))
        case 0xcf: // uint 64
            return .uint(try readUInt64(data: data, offset: &offset))
        case 0xd0: // int 8
            return .int(Int64(try readInt8(data: data, offset: &offset)))
        case 0xd1: // int 16
            return .int(Int64(try readInt16(data: data, offset: &offset)))
        case 0xd2: // int 32
            return .int(Int64(try readInt32(data: data, offset: &offset)))
        case 0xd3: // int 64
            return .int(try readInt64(data: data, offset: &offset))
        case 0xd4: // fixext 1
            let type = try readInt8(data: data, offset: &offset)
            return try decodeExt(count: 1, type: type, data: data, offset: &offset)
        case 0xd5: // fixext 2
            let type = try readInt8(data: data, offset: &offset)
            return try decodeExt(count: 2, type: type, data: data, offset: &offset)
        case 0xd6: // fixext 4
            let type = try readInt8(data: data, offset: &offset)
            return try decodeExt(count: 4, type: type, data: data, offset: &offset)
        case 0xd7: // fixext 8
            let type = try readInt8(data: data, offset: &offset)
            return try decodeExt(count: 8, type: type, data: data, offset: &offset)
        case 0xd8: // fixext 16
            let type = try readInt8(data: data, offset: &offset)
            return try decodeExt(count: 16, type: type, data: data, offset: &offset)
        case 0xd9: // str 8
            let count = try readUInt8(data: data, offset: &offset)
            return try decodeString(count: Int(count), data: data, offset: &offset)
        case 0xda: // str 16
            let count = try readUInt16(data: data, offset: &offset)
            return try decodeString(count: Int(count), data: data, offset: &offset)
        case 0xdb: // str 32
            let count = try readUInt32(data: data, offset: &offset)
            return try decodeString(count: Int(count), data: data, offset: &offset)
        case 0xdc: // array 16
            let count = try readUInt16(data: data, offset: &offset)
            return try decodeArray(count: Int(count), data: data, offset: &offset)
        case 0xdd: // array 32
            let count = try readUInt32(data: data, offset: &offset)
            return try decodeArray(count: Int(count), data: data, offset: &offset)
        case 0xde: // map 16
            let count = try readUInt16(data: data, offset: &offset)
            return try decodeMap(count: Int(count), data: data, offset: &offset)
        case 0xdf: // map 32
            let count = try readUInt32(data: data, offset: &offset)
            return try decodeMap(count: Int(count), data: data, offset: &offset)
        case 0xe0...0xff: // negative fixint
            return .int(Int64(Int8(bitPattern: byte)))
        default:
            throw MessagePackError.invalidFormat(byte)
        }
    }
    
    private static func decodeString(count: Int, data: Data, offset: inout Int) throws -> MessagePackValue {
        guard offset + count <= data.count else { throw MessagePackError.outOfBounds }
        let strData = data[offset..<offset+count]
        guard let str = String(data: strData, encoding: .utf8) else {
            throw MessagePackError.invalidString
        }
        offset += count
        return .string(str)
    }
    
    private static func decodeBinary(count: Int, data: Data, offset: inout Int) throws -> MessagePackValue {
        guard offset + count <= data.count else { throw MessagePackError.outOfBounds }
        let binData = Data(data[offset..<offset+count])
        offset += count
        return .binary(binData)
    }
    
    private static func decodeExt(count: Int, type: Int8, data: Data, offset: inout Int) throws -> MessagePackValue {
        guard offset + count <= data.count else { throw MessagePackError.outOfBounds }
        let extData = Data(data[offset..<offset+count])
        offset += count
        return .ext(type: type, data: extData)
    }
    
    private static func decodeArray(count: Int, data: Data, offset: inout Int) throws -> MessagePackValue {
        var elements = [MessagePackValue]()
        elements.reserveCapacity(count)
        for _ in 0..<count {
            elements.append(try decode(data: data, offset: &offset))
        }
        return .array(elements)
    }
    
    private static func decodeMap(count: Int, data: Data, offset: inout Int) throws -> MessagePackValue {
        var elements = [MessagePackValue: MessagePackValue]()
        elements.reserveCapacity(count)
        for _ in 0..<count {
            let key = try decode(data: data, offset: &offset)
            let value = try decode(data: data, offset: &offset)
            elements[key] = value
        }
        return .map(elements)
    }
    
    private static func readUInt8(data: Data, offset: inout Int) throws -> UInt8 {
        guard offset + 1 <= data.count else { throw MessagePackError.outOfBounds }
        let val = data[offset]
        offset += 1
        return val
    }
    
    private static func readInt8(data: Data, offset: inout Int) throws -> Int8 {
        return Int8(bitPattern: try readUInt8(data: data, offset: &offset))
    }
    
    private static func readUInt16(data: Data, offset: inout Int) throws -> UInt16 {
        guard offset + 2 <= data.count else { throw MessagePackError.outOfBounds }
        let val = data[offset..<offset+2].withUnsafeBytes { $0.loadUnaligned(as: UInt16.self).bigEndian }
        offset += 2
        return val
    }
    
    private static func readInt16(data: Data, offset: inout Int) throws -> Int16 {
        return Int16(bitPattern: try readUInt16(data: data, offset: &offset))
    }
    
    private static func readUInt32(data: Data, offset: inout Int) throws -> UInt32 {
        guard offset + 4 <= data.count else { throw MessagePackError.outOfBounds }
        let val = data[offset..<offset+4].withUnsafeBytes { $0.loadUnaligned(as: UInt32.self).bigEndian }
        offset += 4
        return val
    }
    
    private static func readInt32(data: Data, offset: inout Int) throws -> Int32 {
        return Int32(bitPattern: try readUInt32(data: data, offset: &offset))
    }
    
    private static func readUInt64(data: Data, offset: inout Int) throws -> UInt64 {
        guard offset + 8 <= data.count else { throw MessagePackError.outOfBounds }
        let val = data[offset..<offset+8].withUnsafeBytes { $0.loadUnaligned(as: UInt64.self).bigEndian }
        offset += 8
        return val
    }
    
    private static func readInt64(data: Data, offset: inout Int) throws -> Int64 {
        return Int64(bitPattern: try readUInt64(data: data, offset: &offset))
    }
}
