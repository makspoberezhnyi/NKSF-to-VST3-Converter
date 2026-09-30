content = File.read("App/NKSFConverter/NKSFConverter/AppModel.swift")
content.sub!(/self\.log\("Failed to match plugin for \\\(job\.nksfURL\.lastPathComponent\)"\)\n                    localFail \+= 1\n                    continue/, 
%Q{self.log("Failed to match plugin for \\(job.nksfURL.lastPathComponent)")
                    localFail += 1
                    DispatchQueue.main.async { self.completedJobs += 1 }
                    continue})
File.write("App/NKSFConverter/NKSFConverter/AppModel.swift", content)
