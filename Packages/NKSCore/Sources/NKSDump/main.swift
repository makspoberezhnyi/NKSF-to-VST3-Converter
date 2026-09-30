import Foundation
import NKSCore

guard CommandLine.arguments.count > 1 else {
    print("Usage: nks-dump <file.nksf>")
    exit(1)
}

let path = CommandLine.arguments[1]
let data = try Data(contentsOf: URL(fileURLWithPath: path))
let model = try NKSFParser.parse(data: data)

if let meta = model.metadata, case .map(let dict) = meta {
    for (k, v) in dict {
        if case .string(let keyStr) = k {
            print("\(keyStr): \(v)")
        }
    }
}
