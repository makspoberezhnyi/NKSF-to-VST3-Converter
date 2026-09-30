content = File.read("App/NKSFConverter/NKSFConverter/ContentView.swift")

old_drop = %Q{    private func handleDrop(providers: [NSItemProvider]) {
        var urls = [URL]()
        let group = DispatchGroup()
        
        for provider in providers {
            group.enter()
            _ = provider.loadObject(ofClass: URL.self) { url, error in
                if let url = url {
                    urls.append(url)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            model.processDroppedFolders(urls: urls)
        }
    }}

new_drop = %Q{    private func handleDrop(providers: [NSItemProvider]) {
        var urls = [URL]()
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "drop.queue")
        
        for provider in providers {
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
        }
        
        group.notify(queue: .main) {
            model.log("Dropped \\(urls.count) raw items.")
            model.processDroppedFolders(urls: urls)
        }
    }}

content.sub!(old_drop, new_drop)
File.write("App/NKSFConverter/NKSFConverter/ContentView.swift", content)
