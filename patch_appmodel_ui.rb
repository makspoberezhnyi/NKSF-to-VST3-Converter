content = File.read("App/NKSFConverter/NKSFConverter/AppModel.swift")

# Add AppState enum and new published vars
if !content.include?("enum AppState")
    insert_point = "class AppModel: ObservableObject {\n    let objectWillChange = ObservableObjectPublisher()\n"
    new_vars = %Q{    enum AppState {
        case initializing
        case idle
        case parsing
        case converting
        case done
    }
    
    @Published var state: AppState = .initializing
    @Published var totalJobs = 0
    @Published var completedJobs = 0
    @Published var successCount = 0
    @Published var failCount = 0
}
    content.sub!(insert_point, insert_point + new_vars)
end

# Update scanInstalledPlugins
content.sub!(/self\.knownPlugins = infos\n                    self\.log\("Scan complete. Found \\\(infos\.count\) VST3 plugins."\)/, 
%Q{self.knownPlugins = infos
                    self.state = .idle
                    self.log("Scan complete. Found \\(infos.count) VST3 plugins.")})

# Update processDroppedFolders
content.sub!(/isProcessing = true/, "isProcessing = true\n        DispatchQueue.main.async { self.state = .parsing }")

# Update runConversionJobs setup
content.sub!(/DispatchQueue\.global\(qos: \.userInitiated\)\.async \{\n            var successCount = 0\n            var failCount = 0/, 
%Q{DispatchQueue.main.async {
            self.state = .converting
            self.totalJobs = self.pendingJobs.count
            self.completedJobs = 0
            self.successCount = 0
            self.failCount = 0
        }
        DispatchQueue.global(qos: .userInitiated).async {
            var localSuccess = 0
            var localFail = 0})

# Update loop variables and progress
content.gsub!("successCount += 1", "localSuccess += 1")
content.gsub!("failCount += 1", "localFail += 1")

content.sub!(/self\.log\("✘ Failed \\\(job\.nksfURL\.lastPathComponent\): \\\(error\)"\)\n                    localFail \+= 1\n                \}/, 
%Q{self.log("✘ Failed \\(job.nksfURL.lastPathComponent): \\(error)")
                    localFail += 1
                }
                DispatchQueue.main.async { self.completedJobs += 1 }})

# Update end of runConversionJobs
content.sub!(/self\.log\("Conversion Finished\. Success: \\\(localSuccess\), Failed: \\\(localFail\)"\)\n                self\.isProcessing = false/, 
%Q{self.log("Conversion Finished. Success: \\(localSuccess), Failed: \\(localFail)")
                self.isProcessing = false
                self.successCount = localSuccess
                self.failCount = localFail
                self.state = .done})

File.write("App/NKSFConverter/NKSFConverter/AppModel.swift", content)
