content = File.read("App/NKSFConverter/NKSFConverter/ContentView.swift")
content.gsub!("provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                    urls.append(url)
                } else if let url = item as? URL {
                    urls.append(url)
                }
                group.leave()
            }", %Q{_ = provider.loadObject(ofClass: URL.self) { url, error in
                if let url = url {
                    urls.append(url)
                }
                group.leave()
            }})
File.write("App/NKSFConverter/NKSFConverter/ContentView.swift", content)
