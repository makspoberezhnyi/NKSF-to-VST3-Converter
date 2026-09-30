import Foundation
guard let data = try? Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1])),
      let rawString = String(data: data, encoding: .utf8) else { exit(0) }
let _ = rawString.replacingOccurrences(of: "(?s)/\\*.*?\\*/", with: "", options: .regularExpression)
let _ = rawString.replacingOccurrences(of: ",\\s*([}\\]])", with: "$1", options: .regularExpression)
