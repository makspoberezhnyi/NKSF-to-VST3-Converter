content = File.read("App/NKSFConverter/NKSFConverter/AppModel.swift")
old_conversion = %Q{                do {
                    let result = try self.converter.convert(bundlePath: match.plugin.bundlePath.path, classID: match.classID, pchkData: job.pchkData, strategy: strategy)
                    let presetData = VSTPresetWriter.write(classID: match.classID, componentState: result.componentState, controllerState: result.controllerState, pluginName: job.pluginName)
                    try presetData.write(to: job.outURL)
                    self.log("✔ Saved \\(job.outURL.lastPathComponent)")
                    successCount += 1
                } catch {
                    self.log("✘ Failed \\(job.nksfURL.lastPathComponent): \\(error)")
                    failCount += 1
                }}

new_conversion = %Q{                let actualPluginName = match.plugin.moduleInfo.name
                let pluginDir = job.nksfURL.deletingLastPathComponent().appendingPathComponent(actualPluginName)
                
                do {
                    try FileManager.default.createDirectory(at: pluginDir, withIntermediateDirectories: true, attributes: nil)
                    
                    let finalOutURL = pluginDir.appendingPathComponent(job.nksfURL.lastPathComponent).deletingPathExtension().appendingPathExtension("vstpreset")
                    
                    let result = try self.converter.convert(bundlePath: match.plugin.bundlePath.path, classID: match.classID, pchkData: job.pchkData, strategy: strategy)
                    let presetData = VSTPresetWriter.write(classID: match.classID, componentState: result.componentState, controllerState: result.controllerState, pluginName: actualPluginName)
                    
                    try presetData.write(to: finalOutURL)
                    self.log("✔ Saved \\(actualPluginName)/\\(finalOutURL.lastPathComponent)")
                    successCount += 1
                } catch {
                    self.log("✘ Failed \\(job.nksfURL.lastPathComponent): \\(error)")
                    failCount += 1
                }}

content.sub!(old_conversion, new_conversion)
File.write("App/NKSFConverter/NKSFConverter/AppModel.swift", content)
