content = File.read("Packages/NKSCore/Sources/NKSCore/Converter/Converter.swift")

old_pipe = %Q{        let pipe = Pipe()
        process.standardOutput = pipe}
new_pipe = %Q{        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe}
content.sub!(old_pipe, new_pipe)

File.write("Packages/NKSCore/Sources/NKSCore/Converter/Converter.swift", content)
