import Foundation

public struct VSTPresetWriter {
    public static func write(classID: String, componentState: Data, controllerState: Data? = nil, pluginName: String = "Unknown") -> Data {
        var data = Data()
        
        // VST3 preset header
        data.append(contentsOf: "VST3".utf8)
        
        // Version
        let version: Int32 = 1
        data.append(contentsOf: Swift.withUnsafeBytes(of: version.littleEndian, { Array($0) }))
        
        // Class ID (32 bytes)
        var paddedClassID = classID
        while paddedClassID.utf8.count < 32 { paddedClassID += "\0" }
        if paddedClassID.utf8.count > 32 { paddedClassID = String(paddedClassID.prefix(32)) }
        data.append(contentsOf: paddedClassID.utf8)
        
        // List Offset placeholder (8 bytes)
        var listOffset: Int64 = 0
        let listOffsetIndex = data.count
        data.append(contentsOf: Swift.withUnsafeBytes(of: listOffset.littleEndian, { Array($0) }))
        
        // Write Component State (Comp)
        let compOffset = Int64(data.count)
        data.append(componentState)
        let compSize = Int64(componentState.count)
        
        // Write Controller State (Cont) if present
        var contOffset: Int64 = 0
        var contSize: Int64 = 0
        if let controllerState = controllerState, !controllerState.isEmpty {
            contOffset = Int64(data.count)
            data.append(controllerState)
            contSize = Int64(controllerState.count)
        }
        
        // Write Info (XML)
        let xml = """
        <?xml version="1.0" encoding="utf-8"?>
        <MetaInfo>
            <Attribute id="PlugInCategory" value="Instrument" type="string"/>
            <Attribute id="PlugInName" value="\(pluginName)" type="string"/>
        </MetaInfo>
        """
        let infoOffset = Int64(data.count)
        let infoData = Data(xml.utf8)
        data.append(infoData)
        let infoSize = Int64(infoData.count)
        
        // Write List
        listOffset = Int64(data.count)
        
        // List header: "List", count
        data.append(contentsOf: "List".utf8)
        let chunkCount: Int32 = contSize > 0 ? 3 : 2
        data.append(contentsOf: Swift.withUnsafeBytes(of: chunkCount.littleEndian, { Array($0) }))
        
        // List entries: ID (4 bytes), offset (8 bytes), size (8 bytes)
        // 1. Comp
        data.append(contentsOf: "Comp".utf8)
        data.append(contentsOf: Swift.withUnsafeBytes(of: compOffset.littleEndian, { Array($0) }))
        data.append(contentsOf: Swift.withUnsafeBytes(of: compSize.littleEndian, { Array($0) }))
        
        // 2. Cont
        if contSize > 0 {
            data.append(contentsOf: "Cont".utf8)
            data.append(contentsOf: Swift.withUnsafeBytes(of: contOffset.littleEndian, { Array($0) }))
            data.append(contentsOf: Swift.withUnsafeBytes(of: contSize.littleEndian, { Array($0) }))
        }
        
        // 3. Info
        data.append(contentsOf: "Info".utf8)
        data.append(contentsOf: Swift.withUnsafeBytes(of: infoOffset.littleEndian, { Array($0) }))
        data.append(contentsOf: Swift.withUnsafeBytes(of: infoSize.littleEndian, { Array($0) }))
        
        // Backfill listOffset
        let listOffsetBytes = Swift.withUnsafeBytes(of: listOffset.littleEndian, { Array($0) })
        for i in 0..<8 {
            data[listOffsetIndex + i] = listOffsetBytes[i]
        }
        
        return data
    }
}
