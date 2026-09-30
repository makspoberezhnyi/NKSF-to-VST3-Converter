import SwiftUI
import NKSCore
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var isTargeted = false
    @State private var logText = ""
    @State private var isProcessing = false
    @State private var missingPlugins = [String: [String]]() // PluginName -> [NKSF Paths]
    
    var body: some View {
        VStack {
            Text("NKSF to VST3 Converter")
                .font(.largeTitle)
                .padding()
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isTargeted ? Color.blue : Color.gray, style: StrokeStyle(lineWidth: 2, dash: [10]))
                    .frame(height: 200)
                    .background(isTargeted ? Color.blue.opacity(0.1) : Color.clear)
                
                Text(isProcessing ? "Processing..." : "Drag NKSF Folders Here")
                    .foregroundColor(.gray)
            }
            .padding()
            .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted) { providers in
                handleDrop(providers: providers)
                return true
            }
            
            TextEditor(text: $logText)
                .font(.system(.body, design: .monospaced))
                .padding()
                .border(Color.gray, width: 1)
        }
        .frame(minWidth: 600, minHeight: 400)
    }
    
    private func log(_ message: String) {
        DispatchQueue.main.async {
            self.logText += message + "\n"
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        isProcessing = true
        log("Started scanning...")
        
        // Simplified flow for testing
        // Run Scanner over plugins
        DispatchQueue.global(qos: .userInitiated).async {
            let scanner = Scanner()
            self.log("Scanning /Library/Audio/Plug-Ins/VST3...")
            do {
                let infos = try scanner.scan(at: URL(fileURLWithPath: "/Library/Audio/Plug-Ins/VST3"))
                self.log("Found \(infos.count) VST3 plugins with moduleinfo.json")
                
                // TODO: Orchestrate NKSF directory crawling and Converter invocation
                // For now just outputting that we dropped items.
                
                DispatchQueue.main.async {
                    self.log("Ready to process NKSF files.")
                    self.isProcessing = false
                }
            } catch {
                self.log("Error: \(error)")
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
            }
        }
    }
}
