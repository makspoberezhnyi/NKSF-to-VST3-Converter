content = File.read("App/NKSFConverter/NKSFConverter/ContentView.swift")

old_log = %Q{            TextEditor(text: $model.logText)
                .font(.system(.caption, design: .monospaced))
                .padding()
                .border(Color.gray.opacity(0.5))
                .padding(.horizontal)}

new_log = %Q{            ScrollViewReader { proxy in
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
            }}

content.sub!(old_log, new_log)
File.write("App/NKSFConverter/NKSFConverter/ContentView.swift", content)
