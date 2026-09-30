import Foundation
import NKSCore
import SwiftUI
import Combine

class AppModel: ObservableObject {
    @Published var logText = ""
    @Published var isProcessing = false
    @Published var autoScanSystem = true
    
    @Published var missingPlugins = [MissingPluginRequirement]()
    @Published var showMissingPlugins = false
    
    private let scanner: NKSCore.Scanner
    private let converter: Converter
    private let hostHelperURL: URL
    
    private var knownPlugins = [ScannedPlugin]()
    private var pendingJobs = [ConversionJob]()
    
    struct MissingPluginRequirement: Identifiable {
        let id = UUID()
        let name: String
        let magic: Int?
        let model: NKSFModel
        var resolvedBundleURL: URL?
    }
    
    struct ConversionJob {
        let nksfURL: URL
        let outURL: URL
        let pluginName: String
        let magic: Int?
        let pchkData: Data
        let model: NKSFModel
        var resolvedMatch: PluginMatch?
        var primaryTag: String?
    }
    
    init() {
        let bundle = Bundle.main
        if let helper = bundle.url(forAuxiliaryExecutable: "nks-host") {
            self.hostHelperURL = helper
        } else if let exec = bundle.executableURL?.deletingLastPathComponent().appendingPathComponent("nks-host"), FileManager.default.fileExists(atPath: exec.path) {
            self.hostHelperURL = exec
        } else {
            self.hostHelperURL = URL(fileURLWithPath: "/Users/mpob/Developer/NKSFTOVST3/Host/build/Release/nks-host")
        }
        
        self.scanner = NKSCore.Scanner(hostHelperURL: self.hostHelperURL)
        self.converter = Converter(hostHelperURL: self.hostHelperURL)
        
        scanInstalledPlugins()
    }
    
    func log(_ message: String) {
        DispatchQueue.main.async {
            self.logText += message + "\n"
        }
    }
    
    private func scanInstalledPlugins() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.log("Scanning /Library/Audio/Plug-Ins/VST3 for installed plugins...")
            do {
                let infos = try self.scanner.scan(at: URL(fileURLWithPath: "/Library/Audio/Plug-Ins/VST3"))
                DispatchQueue.main.async {
                    self.knownPlugins = infos
                    self.log("Scan complete. Found \(infos.count) VST3 plugins.")
                }
            } catch {
                self.log("Error scanning plugins: \(error)")
            }
        }
    }
    
    func processDroppedFolders(urls: [URL]) {
        guard !isProcessing else { return }
        isProcessing = true
        
        pendingJobs.removeAll()
        missingPlugins.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var allNKSF = [URL]()
            
            let fm = FileManager.default
            for url in urls {
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
                    DispatchQueue.main.async { self.log("File does not exist at path: \(url.path)") }
                }
            }
            
            self.log("Found \(allNKSF.count) NKSF files to process.")
            
            var missingSet = Set<String>()
            var missingReqs = [MissingPluginRequirement]()
            
            for fileURL in allNKSF {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let model = try NKSFParser.parse(data: data)
                    
                    guard let pchk = model.pluginState else {
                        self.log("Skipping \(fileURL.lastPathComponent): No PCHK chunk.")
                        continue
                    }
                    
                    var pluginName = "Unknown"
                    var pluginMagic: Int? = nil
                    
                    if let plid = model.pluginId, case .map(let dict) = plid {
                        if let magicVal = dict[.string("VST.magic")], case .uint(let m) = magicVal {
                            pluginMagic = Int(m)
                        } else if let magicVal = dict[.string("VST.magic")], case .int(let m) = magicVal {
                            pluginMagic = Int(m)
                        }
                    }
                    
                    var primaryTag: String? = nil
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
                    }
                    
                    let match = Matcher.match(nksf: model, availablePlugins: self.knownPlugins).first
                    
                    // Note: outURL was in the ConversionJob struct before the grouping patch, 
                    // but we WANT the grouping patch (it was before the UI rewrite!).
                    let job = ConversionJob(nksfURL: fileURL, outURL: URL(fileURLWithPath: "/dev/null"), pluginName: pluginName, magic: pluginMagic, pchkData: pchk, model: model, resolvedMatch: match, primaryTag: primaryTag)
                    self.pendingJobs.append(job)
                    
                    if match == nil {
                        let missingKey = "\(pluginName)-\(pluginMagic ?? 0)"
                        if !missingSet.contains(missingKey) {
                            missingSet.insert(missingKey)
                            missingReqs.append(MissingPluginRequirement(name: pluginName, magic: pluginMagic, model: model))
                        }
                    }
                } catch {
                    self.log("Error parsing \(fileURL.lastPathComponent): \(error)")
                }
            }
            
            DispatchQueue.main.async {
                if !missingReqs.isEmpty {
                    self.missingPlugins = missingReqs
                    self.showMissingPlugins = true
                } else {
                    self.runConversionJobs()
                }
            }
        }
    }
    
    func resolveMissingPlugin(_ req: MissingPluginRequirement, url: URL) {
        if let index = missingPlugins.firstIndex(where: { $0.id == req.id }) {
            missingPlugins[index].resolvedBundleURL = url
        }
    }
    
    func continueWithResolvedPlugins() {
        showMissingPlugins = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Scan specifically chosen bundles
            for req in self.missingPlugins {
                if let url = req.resolvedBundleURL {
                    if let newInfo = try? self.scanner.scanFile(at: url) {
                         DispatchQueue.main.async {
                             self.knownPlugins.append(newInfo)
                         }
                    }
                }
            }
            
            Thread.sleep(forTimeInterval: 0.5)
            
            for i in 0..<self.pendingJobs.count {
                if self.pendingJobs[i].resolvedMatch == nil {
                    self.pendingJobs[i].resolvedMatch = Matcher.match(nksf: self.pendingJobs[i].model, availablePlugins: self.knownPlugins).first
                }
            }
            
            DispatchQueue.main.async {
                self.runConversionJobs()
            }
        }
    }
    
    private func runConversionJobs() {
        DispatchQueue.global(qos: .userInitiated).async {
            var successCount = 0
            var failCount = 0
            
            for job in self.pendingJobs {
                guard let match = job.resolvedMatch else {
                    self.log("Failed to match plugin for \(job.nksfURL.lastPathComponent)")
                    failCount += 1
                    continue
                }
                
                self.log("Converting \(job.nksfURL.lastPathComponent) -> \(match.plugin.bundlePath.lastPathComponent)")
                
                let strategy: ConversionStrategy
                if let m = job.magic {
                    strategy = .vst2Chunk(magic: m, isFXB: false)
                } else {
                    strategy = .rawPCHK
                }
                
                let actualPluginName = match.plugin.moduleInfo.name
                var pluginDir = job.nksfURL.deletingLastPathComponent().appendingPathComponent(actualPluginName)
                if let tag = job.primaryTag {
                    pluginDir = pluginDir.appendingPathComponent(tag.replacingOccurrences(of: "/", with: "-"))
                }
                
                do {
                    try FileManager.default.createDirectory(at: pluginDir, withIntermediateDirectories: true, attributes: nil)
                    
                    let originalName = job.nksfURL.lastPathComponent
                    let baseName = (originalName as NSString).deletingPathExtension
                    let strictName = "\(actualPluginName) - \(baseName).vstpreset"
                    let finalOutURL = pluginDir.appendingPathComponent(strictName)
                    
                    let result = try self.converter.convert(bundlePath: match.plugin.bundlePath.path, classID: match.classID, pchkData: job.pchkData, strategy: strategy)
                    let presetData = VSTPresetWriter.write(classID: match.classID, componentState: result.componentState, controllerState: result.controllerState, pluginName: actualPluginName)
                    
                    try presetData.write(to: finalOutURL)
                    self.log("✔ Saved \(actualPluginName)/\(finalOutURL.lastPathComponent)")
                    successCount += 1
                } catch {
                    self.log("✘ Failed \(job.nksfURL.lastPathComponent): \(error)")
                    failCount += 1
                }
            }
            
            DispatchQueue.main.async {
                self.log("Conversion Finished. Success: \(successCount), Failed: \(failCount)")
                self.isProcessing = false
            }
        }
    }
}
