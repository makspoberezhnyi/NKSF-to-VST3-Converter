content = File.read("App/NKSFConverter/NKSFConverter/AppModel.swift")

# 1. Add `tag` to ConversionJob
old_job = %Q{        let pchkData: Data
        let model: NKSFModel
        var resolvedMatch: PluginMatch?}
new_job = %Q{        let pchkData: Data
        let model: NKSFModel
        var resolvedMatch: PluginMatch?
        var primaryTag: String?}
content.sub!(old_job, new_job)

# 2. Extract tag during parsing
old_parse = %Q{                    if let metadata = model.metadata, case .map(let metaDict) = metadata {
                        if let bankChain = metaDict[.string("bankchain")], case .array(let arr) = bankChain, let first = arr.first, case .string(let s) = first {
                            pluginName = s
                        } else if let nameVal = metaDict[.string("name")], case .string(let n) = nameVal {
                            pluginName = n
                        }
                    }}
new_parse = %Q{                    var primaryTag: String? = nil
                    if let metadata = model.metadata, case .map(let metaDict) = metadata {
                        if let bankChain = metaDict[.string("bankchain")], case .array(let arr) = bankChain, let first = arr.first, case .string(let s) = first {
                            pluginName = s
                        } else if let nameVal = metaDict[.string("name")], case .string(let n) = nameVal {
                            pluginName = n
                        }
                        
                        if let typesVal = metaDict[.string("types")], case .array(let types) = typesVal {
                            for typeChain in types {
                                if case .array(let chain) = typeChain, let first = chain.first, case .string(let tag) = first {
                                    if tag.lowercased() == "genre" { continue }
                                    primaryTag = tag
                                    break
                                }
                            }
                        }
                    }}
content.sub!(old_parse, new_parse)

# 3. Add it to the ConversionJob init
old_init = "let job = ConversionJob(nksfURL: fileURL, outURL: URL(fileURLWithPath: \"/dev/null\"), pluginName: pluginName, magic: pluginMagic, pchkData: pchk, model: model, resolvedMatch: match)"
new_init = "let job = ConversionJob(nksfURL: fileURL, outURL: URL(fileURLWithPath: \"/dev/null\"), pluginName: pluginName, magic: pluginMagic, pchkData: pchk, model: model, resolvedMatch: match, primaryTag: primaryTag)"
content.sub!(old_init, new_init)

# 4. Modify the output directory to include the tag
old_dir = %Q{                let actualPluginName = match.plugin.moduleInfo.name
                let pluginDir = job.nksfURL.deletingLastPathComponent().appendingPathComponent(actualPluginName)}
new_dir = %Q{                let actualPluginName = match.plugin.moduleInfo.name
                var pluginDir = job.nksfURL.deletingLastPathComponent().appendingPathComponent(actualPluginName)
                if let tag = job.primaryTag {
                    pluginDir = pluginDir.appendingPathComponent(tag.replacingOccurrences(of: "/", with: "-"))
                }}
content.sub!(old_dir, new_dir)

File.write("App/NKSFConverter/NKSFConverter/AppModel.swift", content)
