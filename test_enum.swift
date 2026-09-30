import Foundation
let fm = FileManager.default
let fileURL = URL(fileURLWithPath: "test_enum.swift")
if let enumerator = fm.enumerator(at: fileURL, includingPropertiesForKeys: nil) {
    print("Enumerator created for file!")
    var count = 0
    for case let u as URL in enumerator {
        print(u)
        count += 1
    }
    print("Yielded \(count) items")
}
