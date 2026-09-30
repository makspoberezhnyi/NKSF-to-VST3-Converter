content = File.read("App/NKSFConverter/NKSFConverter/ContentView.swift")
content.sub!(/\.fileExporter\(isPresented: \$showingExport, document: TextDocument\(text: model\.logText\), contentType: \.plainText, defaultFilename: "PresetBridgeLog\.txt"\) \{ _ in \}\n    \}/, 
%Q{.fileExporter(isPresented: $showingExport, document: TextDocument(text: model.logText), contentType: .plainText, defaultFilename: "PresetBridgeLog.txt") { _ in }
        .onAppear {
            model.startScanningIfNeeded()
        }
    }})
File.write("App/NKSFConverter/NKSFConverter/ContentView.swift", content)
