content = File.read("App/NKSFConverter/NKSFConverter/ContentView.swift")
content.sub!("            .padding(.bottom, 30)\n        }\n        .frame(minWidth: 600, minHeight: 500)", "            .padding(.bottom, 30)\n        }\n        .onAppear {\n            model.startScanningIfNeeded()\n        }\n        .frame(minWidth: 600, minHeight: 500)")
content.sub!(/\s*\.onAppear \{\n            model\.startScanningIfNeeded\(\)\n        \}\n    \}/, "\n    }")
File.write("App/NKSFConverter/NKSFConverter/ContentView.swift", content)
