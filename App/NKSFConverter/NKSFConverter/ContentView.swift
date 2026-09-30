import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var model = AppModel()
    @State private var isTargeted = false
    @State private var showingExport = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("NKSF to VST3 Converter")
                .font(.largeTitle)
                .padding(.top)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isTargeted ? Color.blue : Color.gray, style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .background(isTargeted ? Color.blue.opacity(0.1) : Color.clear)
                
                Text(model.isProcessing ? "Processing..." : "Drag NKSF Files or Folders Here")
                    .foregroundColor(isTargeted ? .blue : .primary)
            }
            .frame(height: 150)
            .padding()
            .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted) { providers in
                handleDrop(providers: providers)
                return true
            }
            
            ScrollViewReader { proxy in
                ScrollView {
                    Text(model.logText)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .id("logBottom")
                }
                .border(Color.gray.opacity(0.5))
                .padding(.horizontal)
                .onChange(of: model.logText) { _ in
                    withAnimation {
                        proxy.scrollTo("logBottom", anchor: .bottom)
                    }
                }
            }
            
            HStack {
                Spacer()
                Button("Export Log") {
                    showingExport = true
                }
                .disabled(model.logText.isEmpty)
                .padding()
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .sheet(isPresented: $model.showMissingPlugins) {
            MissingPluginsView(model: model)
        }
        .fileExporter(isPresented: $showingExport, document: TextDocument(text: model.logText), contentType: .plainText, defaultFilename: "ConversionLog.txt") { _ in }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        var urls = [URL]()
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "drop.queue")
        
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                group.enter()
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let u = url {
                        queue.sync { urls.append(u) }
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            model.log("Dropped \(urls.count) raw items.")
            model.processDroppedFolders(urls: urls)
        }
    }
}

struct MissingPluginsView: View {
    @ObservedObject var model: AppModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Missing Plugins Detected")
                .font(.headline)
                .padding()
            
            Text("The following plugins could not be automatically found. Please locate their .vst3 bundles, or skip them.")
                .padding(.horizontal)
            
            List($model.missingPlugins) { $req in
                HStack {
                    VStack(alignment: .leading) {
                        Text(req.name).fontWeight(.bold)
                        Text("Magic: \(String(format: "%08X", req.magic ?? 0))")
                            .font(.caption)
                    }
                    Spacer()
                    if let resolved = req.resolvedBundleURL {
                        Text(resolved.lastPathComponent).foregroundColor(.green)
                    } else {
                        Button("Locate .vst3...") {
                            let panel = NSOpenPanel()
                            if let uti = UTType(filenameExtension: "vst3") {
                                panel.allowedContentTypes = [uti, .bundle, .folder, .directory]
                            } else {
                                panel.allowedContentTypes = [.bundle, .folder, .directory]
                            }
                            panel.canChooseFiles = true
                            panel.canChooseDirectories = true
                            if panel.runModal() == .OK, let url = panel.url {
                                if url.pathExtension.lowercased() == "vst3" {
                                    model.resolveMissingPlugin(req, url: url)
                                } else {
                                    model.log("Error: You must select a valid .vst3 plugin file/folder.")
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(minHeight: 200)
            
            HStack {
                Button("Cancel") {
                    model.missingPlugins.removeAll()
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                Button("Continue") {
                    model.continueWithResolvedPlugins()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
    }
}

struct TextDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }
    var text: String
    init(text: String) { self.text = text }
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents { text = String(decoding: data, as: UTF8.self) } else { text = "" }
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8) ?? Data()
        return .init(regularFileWithContents: data)
    }
}
