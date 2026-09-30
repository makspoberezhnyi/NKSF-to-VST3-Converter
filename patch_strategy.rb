content = File.read("App/NKSFConverter/NKSFConverter/AppModel.swift")
old_strat = %Q{                let strategy: ConversionStrategy
                if let m = job.magic {
                    strategy = .vst2Chunk(magic: m, isFXB: false)
                } else {
                    strategy = .rawPCHK
                }}
new_strat = %Q{                // Always pass raw PCHK data directly to VST3 plugins.
                // Wrapping it in an FXP header causes strict VST3 plugins like TAL to segfault.
                let strategy: ConversionStrategy = .rawPCHK}
content.sub!(old_strat, new_strat)
File.write("App/NKSFConverter/NKSFConverter/AppModel.swift", content)
