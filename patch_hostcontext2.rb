content = File.read("Host/nks-host/HostContext.h")
content.gsub!("#include \"pluginterfaces/base/ustring.h\"", "")
old_func = %Q{    tresult PLUGIN_API getName (String128 name) override {
        UString str("NKSFTOVST3");
        str.copyTo16(name, 0, 127);
        return kResultTrue;
    }}
new_func = %Q{    tresult PLUGIN_API getName (String128 name) override {
        const char* myName = "NKSFTOVST3";
        for (int i = 0; i < 127 && myName[i] != 0; ++i) {
            name[i] = (char16_t)myName[i];
            name[i+1] = 0;
        }
        return kResultTrue;
    }}
content.sub!(old_func, new_func)
File.write("Host/nks-host/HostContext.h", content)
