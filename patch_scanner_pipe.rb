content = File.read("Packages/NKSCore/Sources/NKSCore/Scanner/Scanner.swift")
content.sub!(/try process\.run\(\)\n            process\.waitUntilExit\(\)\n            \n            let data = pipe\.fileHandleForReading\.readDataToEndOfFile\(\)/, 
%Q{try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()})
File.write("Packages/NKSCore/Sources/NKSCore/Scanner/Scanner.swift", content)
