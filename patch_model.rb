content = File.read("App/NKSFConverter/NKSFConverter/AppModel.swift")
old_logic = %Q{            for url in urls {
                if let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey]) {
                    for case let fileURL as URL in enumerator {
                        if fileURL.pathExtension.lowercased() == "nksf" {
                            allNKSF.append(fileURL)
                        }
                    }
                } else if url.pathExtension.lowercased() == "nksf" {
                    allNKSF.append(url)
                }
            }}

new_logic = %Q{            for url in urls {
                var isDir: ObjCBool = false
                if fm.fileExists(atPath: url.path, isDirectory: &isDir) {
                    if isDir.boolValue {
                        if let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: nil) {
                            for case let fileURL as URL in enumerator {
                                if fileURL.pathExtension.lowercased() == "nksf" {
                                    allNKSF.append(fileURL)
                                }
                            }
                        }
                    } else if url.pathExtension.lowercased() == "nksf" {
                        allNKSF.append(url)
                    }
                } else {
                    DispatchQueue.main.async { self.log("File does not exist at path: \\(url.path)") }
                }
            }}
content.sub!(old_logic, new_logic)
File.write("App/NKSFConverter/NKSFConverter/AppModel.swift", content)
