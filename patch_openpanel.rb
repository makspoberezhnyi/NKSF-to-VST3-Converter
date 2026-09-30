content = File.read("App/NKSFConverter/NKSFConverter/ContentView.swift")

old_code = %Q{                            let panel = NSOpenPanel()
                            let vst3UTI = UTType(tag: "vst3", tagClass: .filenameExtension, conformingTo: nil) ?? .bundle
                            panel.allowedContentTypes = [vst3UTI]
                            panel.canChooseFiles = true
                            panel.canChooseDirectories = false}

new_code = %Q{                            let panel = NSOpenPanel()
                            if let uti = UTType(filenameExtension: "vst3") {
                                panel.allowedContentTypes = [uti, .bundle, .folder, .directory]
                            } else {
                                panel.allowedContentTypes = [.bundle, .folder, .directory]
                            }
                            panel.canChooseFiles = true
                            panel.canChooseDirectories = true}

content.sub!(old_code, new_code)
File.write("App/NKSFConverter/NKSFConverter/ContentView.swift", content)
