content = File.read("Packages/NKSCore/Sources/NKSCore/Converter/Converter.swift")

old_term = %Q{        guard process.terminationStatus == 0 else {
            throw NSError(domain: "Converter", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "nks-host failed or crashed"])
        }}
new_term = %Q{        let outData = pipe.fileHandleForReading.readDataToEndOfFile()
        let outString = String(data: outData, encoding: .utf8) ?? ""
        guard process.terminationStatus == 0 else {
            throw NSError(domain: "Converter", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "Crash Log: \\(outString)"])
        }}

content.sub!(old_term, new_term)
File.write("Packages/NKSCore/Sources/NKSCore/Converter/Converter.swift", content)
