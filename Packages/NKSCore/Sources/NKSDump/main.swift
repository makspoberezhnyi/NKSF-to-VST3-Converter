import Foundation
import NKSCore

func dumpPLID(file: String) {
    let data = try! Data(contentsOf: URL(fileURLWithPath: file))
    let model = try! NKSFParser.parse(data: data)
    print("\(file) PLID: \(model.pluginId ?? .nil)")
}

dumpPLID(file: "Fixtures/08-15 Bass.nksf")
