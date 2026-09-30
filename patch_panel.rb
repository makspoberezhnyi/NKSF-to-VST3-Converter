content = File.read("App/NKSFConverter/NKSFConverter/ContentView.swift")
content.sub!(/panel.allowedContentTypes = \[UTType\(filenameExtension: "vst3"\) \?\? \.bundle\]/, "panel.allowedFileTypes = [\"vst3\"]")
File.write("App/NKSFConverter/NKSFConverter/ContentView.swift", content)
