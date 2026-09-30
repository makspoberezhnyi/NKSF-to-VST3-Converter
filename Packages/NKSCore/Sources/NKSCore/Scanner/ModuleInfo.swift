import Foundation

public struct ModuleInfo: Codable {
    public let name: String
    public let version: String
    public let vendor: String
    public let classes: [PluginClass]
    public let compatibility: [CompatibilityEntry]?
    
    public init(name: String, version: String, vendor: String, classes: [PluginClass], compatibility: [CompatibilityEntry]? = nil) {
        self.name = name
        self.version = version
        self.vendor = vendor
        self.classes = classes
        self.compatibility = compatibility
    }

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case version = "Version"
        case factoryInfo = "Factory Info"
        case classes = "Classes"
        case compatibility = "Compatibility"
        case vendor = "Vendor" // used for custom encoding
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        version = try container.decodeIfPresent(String.self, forKey: .version) ?? ""
        classes = try container.decodeIfPresent([PluginClass].self, forKey: .classes) ?? []
        compatibility = try container.decodeIfPresent([CompatibilityEntry].self, forKey: .compatibility)
        
        if let factoryDict = try? container.decode([String: String].self, forKey: .factoryInfo) {
            vendor = factoryDict["Vendor"] ?? ""
        } else {
            vendor = ""
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(version, forKey: .version)
        try container.encode(classes, forKey: .classes)
        try container.encodeIfPresent(compatibility, forKey: .compatibility)
        try container.encode(["Vendor": vendor], forKey: .factoryInfo)
    }
}

public struct PluginClass: Codable {
    public let cid: String
    public let category: String
    public let name: String
    public let vendor: String?
    public let subCategories: [String]?
    
    public init(cid: String, category: String, name: String, vendor: String? = nil, subCategories: [String]? = nil) {
        self.cid = cid
        self.category = category
        self.name = name
        self.vendor = vendor
        self.subCategories = subCategories
    }

    enum CodingKeys: String, CodingKey {
        case cid = "CID"
        case category = "Category"
        case name = "Name"
        case vendor = "Vendor"
        case subCategories = "Sub Categories"
    }
}

public struct CompatibilityEntry: Codable {
    public let new: String
    public let old: [String]
    
    enum CodingKeys: String, CodingKey {
        case new = "New"
        case old = "Old"
    }
}

public struct ModuleInfoParser {
    public static func parse(url: URL) throws -> ModuleInfo {
        let data = try Data(contentsOf: url)
        guard let string = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "ModuleInfoParser", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid UTF-8"])
        }
        
        var cleaned = string
        cleaned = cleaned.replacingOccurrences(of: "/\\*.*?\\*/", with: "", options: .regularExpression)
        cleaned = cleaned.replacingOccurrences(of: "//.*", with: "", options: .regularExpression)
        cleaned = cleaned.replacingOccurrences(of: ",(?=\\s*[\\]}])", with: "", options: .regularExpression)
        
        let cleanedData = Data(cleaned.utf8)
        let decoder = JSONDecoder()
        return try decoder.decode(ModuleInfo.self, from: cleanedData)
    }
}
