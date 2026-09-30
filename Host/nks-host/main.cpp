#include "HostContext.h"
#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include "json.hpp"
#include "public.sdk/source/vst/hosting/module.h"
#include "public.sdk/source/vst/hosting/hostclasses.h"
#include "pluginterfaces/vst/ivstcomponent.h"
#include "pluginterfaces/vst/ivsteditcontroller.h"
#include "pluginterfaces/base/ibstream.h"
#include <CoreFoundation/CoreFoundation.h>

using json = nlohmann::json;
using namespace Steinberg;
using namespace Steinberg::Vst;

void pumpRunLoop(int ms) {
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, ms / 1000.0, false);
}

std::string fuidToString(const FUID& uid) {
    char uidStr[33];
    uid.toString(uidStr);
    return std::string(uidStr);
}

int cmdScan(const std::string& bundlePath) {
    std::string errorStr;
    auto module = VST3::Hosting::Module::create(bundlePath, errorStr);
    if (!module) {
        json j = {{"error", "Failed to load module: " + errorStr}};
        std::cerr << j.dump() << std::endl;
        return 1;
    }

    auto factory = module->getFactory();
    json result = json::array();
    for (const auto& ci : factory.classInfos()) {
        json cls;
        cls["CID"] = ci.ID().toString();
        cls["Category"] = ci.category();
        cls["Name"] = ci.name();
        json subCats = json::array();
        for (const auto& sc : ci.subCategories()) {
            subCats.push_back(sc);
        }
        cls["SubCategories"] = subCats;
        result.push_back(cls);
    }
    std::cout << result.dump(2) << std::endl;
    return 0;
}

class MemoryStream : public IBStream {
public:
    MemoryStream() {}
    MemoryStream(const std::vector<char>& d) : data(d) {}
    
    virtual ~MemoryStream() {}
    
    tresult PLUGIN_API read(void* buffer, int32 numBytes, int32* numBytesRead) override {
        int32 available = static_cast<int32>(data.size() - cursor);
        int32 toRead = std::min(numBytes, available);
        if (toRead > 0) {
            memcpy(buffer, data.data() + cursor, toRead);
            cursor += toRead;
        }
        if (numBytesRead) *numBytesRead = toRead;
        return kResultTrue;
    }
    
    tresult PLUGIN_API write(void* buffer, int32 numBytes, int32* numBytesWritten) override {
        data.insert(data.end(), (char*)buffer, (char*)buffer + numBytes);
        cursor += numBytes;
        if (numBytesWritten) *numBytesWritten = numBytes;
        return kResultTrue;
    }
    
    tresult PLUGIN_API seek(int64 pos, int32 mode, int64* result) override {
        if (mode == kIBSeekSet) cursor = pos;
        else if (mode == kIBSeekCur) cursor += pos;
        else if (mode == kIBSeekEnd) cursor = data.size() + pos;
        if (cursor < 0) cursor = 0;
        if (cursor > data.size()) cursor = data.size();
        if (result) *result = cursor;
        return kResultTrue;
    }
    
    tresult PLUGIN_API tell(int64* pos) override {
        if (pos) *pos = cursor;
        return kResultTrue;
    }
    
    std::vector<char> data;
    int64 cursor = 0;

    DECLARE_FUNKNOWN_METHODS
};

IMPLEMENT_REFCOUNT(MemoryStream)
tresult PLUGIN_API MemoryStream::queryInterface(const TUID _iid, void** obj) {
    if (FUnknownPrivate::iidEqual(_iid, IBStream::iid)) {
        *obj = static_cast<IBStream*>(this);
        addRef();
        return kResultOk;
    }
    return kResultFalse;
}

std::vector<char> readFile(const std::string& path) {
    std::ifstream file(path, std::ios::binary);
    if (!file) return {};
    return std::vector<char>((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
}

void writeFile(const std::string& path, const std::vector<char>& data) {
    std::ofstream file(path, std::ios::binary);
    if (!data.empty()) {
        file.write(data.data(), data.size());
    }
}

int cmdConvert(int argc, char** argv) {
    if (argc < 7) {
        std::cerr << "Usage: nks-host convert <bundlePath> <classID> <inState.bin> <outComp.bin> <outCont.bin>" << std::endl;
        return 1;
    }
    
    std::string bundlePath = argv[2];
    std::string classIDStr = argv[3];
    std::string inStatePath = argv[4];
    std::string outCompPath = argv[5];
    std::string outContPath = argv[6];
    
    std::string errorStr;
    auto module = VST3::Hosting::Module::create(bundlePath, errorStr);
    if (!module) {
        std::cerr << "Failed to load module: " << errorStr << std::endl;
        return 1;
    }
    
    auto factory = module->getFactory();
    auto uidOpt = VST3::UID::fromString(classIDStr);
    if (!uidOpt) {
        std::cerr << "Invalid class ID format" << std::endl;
        return 1;
    }
    
    // Convert VST3::UID to Steinberg::FUID correctly using TUID
    Steinberg::TUID tuid;
    memcpy(tuid, uidOpt->data(), sizeof(Steinberg::TUID));
    Steinberg::FUID fuid(tuid);
    
    auto component = factory.createInstance<IComponent>(*uidOpt);
    if (!component) {
        std::cerr << "Failed to create IComponent" << std::endl;
        return 1;
    }
    
    component->initialize(nullptr);
    
    auto inStateData = readFile(inStatePath);
    if (!inStateData.empty()) {
        auto inStream = owned(new MemoryStream(inStateData));
        component->setState(inStream);
    }
    
    auto compStream = owned(new MemoryStream());
    component->getState(compStream);
    writeFile(outCompPath, compStream->data);
    
     IEditController* controller = nullptr;
    if (component->queryInterface(IEditController::iid, (void**)&controller) == kResultOk) {
        controller->initialize(nullptr);
        
        auto contStream = owned(new MemoryStream());
        if (controller->getState(contStream) == kResultOk) {
            writeFile(outContPath, contStream->data);
        }
        
        controller->terminate();
        controller->release();
    }
    
    component->terminate();
    std::cout << "{\"status\":\"ok\"}" << std::endl;
    return 0;
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    std::string cmd = argv[1];
    if (cmd == "scan") return cmdScan(argv[2]);
    if (cmd == "convert") return cmdConvert(argc, argv);
    return 1;
}
