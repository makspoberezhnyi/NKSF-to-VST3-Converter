import Foundation

let path = "/Library/Audio/Plug-Ins/VST3/Kontakt 7.vst3/Contents/Resources/moduleinfo.json"
guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
      let rawString = String(data: data, encoding: .utf8) else {
    print("No moduleinfo for Kontakt 7")
    exit(0)
}

print("Loaded string of length \(rawString.count)")
let start = Date()
let noComments = rawString.replacingOccurrences(of: "(?s)/\\*.*?\\*/", with: "", options: .regularExpression)
print("Regex 1 took \(Date().timeIntervalSince(start))s")
let start2 = Date()
let noTrailing = noComments.replacingOccurrences(of: ",\\s*([}\\]])", with: "$1", options: .regularExpression)
print("Regex 2 took \(Date().timeIntervalSince(start2))s")
