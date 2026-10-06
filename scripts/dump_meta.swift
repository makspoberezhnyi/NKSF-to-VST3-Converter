import Foundation
import NKSCore

let data = try! Data(contentsOf: URL(fileURLWithPath: "Fixtures/08-15 Bass.nksf"))
let model = try! NKSFParser.parse(data: data)

if let meta = model.metadata, case .map(let dict) = meta {
    for (k, v) in dict {
        if case .string(let keyStr) = k {
            print("\(keyStr): \(v)")
        }
    }
}
