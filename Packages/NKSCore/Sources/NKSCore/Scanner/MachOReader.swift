import Foundation

public enum Architecture: String, Codable, Equatable {
    case arm64
    case x86_64
}

public struct MachOReader {
    public static func readArchitectures(at url: URL) throws -> Set<Architecture> {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        
        guard let headerData = try handle.read(upToCount: 4) else { return [] }
        let magic = headerData.withUnsafeBytes { $0.loadUnaligned(as: UInt32.self).bigEndian }
        
        var architectures: Set<Architecture> = []
        
        // FAT_MAGIC = 0xcafebabe
        if magic == 0xcafebabe {
            guard let countData = try handle.read(upToCount: 4) else { return [] }
            let count = countData.withUnsafeBytes { $0.loadUnaligned(as: UInt32.self).bigEndian }
            
            for _ in 0..<count {
                guard let archData = try handle.read(upToCount: 20) else { break }
                let cputype = archData[0..<4].withUnsafeBytes { $0.loadUnaligned(as: Int32.self).bigEndian }
                if let arch = cpuTypeToArch(cputype) {
                    architectures.insert(arch)
                }
            }
        } else {
            // Check native endian
            let nativeMagic = headerData.withUnsafeBytes { $0.loadUnaligned(as: UInt32.self) }
            // 0xfeedfacf is MH_MAGIC_64
            if nativeMagic == 0xfeedfacf {
                guard let archData = try handle.read(upToCount: 4) else { return architectures }
                let cputype = archData.withUnsafeBytes { $0.loadUnaligned(as: Int32.self) }
                if let arch = cpuTypeToArch(cputype) {
                    architectures.insert(arch)
                }
            }
        }
        
        return architectures
    }
    
    private static func cpuTypeToArch(_ type: Int32) -> Architecture? {
        if type == 0x01000007 { return .x86_64 }
        if type == 0x0100000c { return .arm64 }
        return nil
    }
}
