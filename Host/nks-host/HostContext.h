#pragma once

#include "pluginterfaces/base/funknown.h"
#include "pluginterfaces/vst/ivsthostapplication.h"
#include "pluginterfaces/vst/ivstmessage.h"

using namespace Steinberg;
using namespace Steinberg::Vst;

class HostContext : public IHostApplication {
public:
    HostContext() {
        FUNKNOWN_CTOR
    }
    
    virtual ~HostContext() {}

    DECLARE_FUNKNOWN_METHODS

    tresult PLUGIN_API getName (String128 name) override {
        const char* myName = "NKSFTOVST3";
        for (int i = 0; i < 127 && myName[i] != 0; ++i) {
            name[i] = (char16_t)myName[i];
            name[i+1] = 0;
        }
        return kResultTrue;
    }

    tresult PLUGIN_API createInstance (TUID cid, TUID _iid, void** obj) override {
        *obj = nullptr;
        return kNotImplemented;
    }
};

IMPLEMENT_REFCOUNT(HostContext)

tresult PLUGIN_API HostContext::queryInterface (const char* _iid, void** obj) {
    QUERY_INTERFACE (_iid, obj, FUnknown::iid, IHostApplication)
    QUERY_INTERFACE (_iid, obj, IHostApplication::iid, IHostApplication)
    *obj = nullptr;
    return kNoInterface;
}
