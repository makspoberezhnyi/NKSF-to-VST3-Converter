content = File.read("App/NKSFConverter/NKSFConverter/ContentView.swift")

# Fix loadItem deprecation
old_drop = %Q{        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                group.enter()
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                    var loadedURL: URL? = nil
                    if let data = item as? Data {
                        loadedURL = URL(dataRepresentation: data, relativeTo: nil)
                    } else if let url = item as? URL {
                        loadedURL = url
                    }
                    
                    if let u = loadedURL {
                        queue.sync { urls.append(u) }
                    } else {
                        DispatchQueue.main.async { self.model.log("Drop item failed: \\(String(describing: error))") }
                    }
                    group.leave()
                }
            }
        }}

new_drop = %Q{        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                group.enter()
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let u = url {
                        queue.sync { urls.append(u) }
                    } else {
                        DispatchQueue.main.async { self.model.log("Drop item failed: \\(String(describing: error))") }
                    }
                    group.leave()
                }
            }
        }}
content.sub!(old_drop, new_drop)

# Fix allowedFileTypes deprecation
old_panel = %Q{                            let panel = NSOpenPanel()
                            panel.allowedFileTypes = ["vst3"]
                            panel.canChooseFiles = true}
new_panel = %Q{                            let panel = NSOpenPanel()
                            let vst3UTI = UTType(tag: "vst3", tagClass: .filenameExtension, conformingTo: nil) ?? .bundle
                            panel.allowedContentTypes = [vst3UTI]
                            panel.canChooseFiles = true}
content.sub!(old_panel, new_panel)

File.write("App/NKSFConverter/NKSFConverter/ContentView.swift", content)
