content = File.read("App/NKSFConverter/NKSFConverter/AppModel.swift")
content.sub!(/    let objectWillChange = ObservableObjectPublisher\(\)\n/, "")
File.write("App/NKSFConverter/NKSFConverter/AppModel.swift", content)
