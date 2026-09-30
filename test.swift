import Foundation

let path = "/Library/Audio/Plug-Ins/VST3/"
let fm = FileManager.default
let contents = try fm.contentsOfDirectory(atPath: path)

for item in contents where item.contains("Arturia") || item.contains("Augmented") || item.contains("Pigments") {
    print("Found plugin: \(item)")
}
