content = File.read("App/NKSFConverter/NKSFConverter/ContentView.swift")

old_code = %Q{                            if panel.runModal() == .OK, let url = panel.url {
                                model.resolveMissingPlugin(req, url: url)
                            }}

new_code = %Q{                            if panel.runModal() == .OK, let url = panel.url {
                                if url.pathExtension.lowercased() == "vst3" {
                                    model.resolveMissingPlugin(req, url: url)
                                } else {
                                    model.log("Error: You must select a valid .vst3 plugin file/folder.")
                                }
                            }}

content.sub!(old_code, new_code)
File.write("App/NKSFConverter/NKSFConverter/ContentView.swift", content)
