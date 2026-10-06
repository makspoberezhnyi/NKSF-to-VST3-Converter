content = File.read("Host/nks-host/main.cpp")
content = %(#include "HostContext.h"\n) + content

# Patch component init
old_comp = %Q{    if (factory->createInstance(targetCID, IComponent::iid, (void**)&component) != kResultOk || !component) {
        std::cerr << "Failed to create IComponent instance\\n";
        factory->release();
        return 1;
    }

    DEBUG: Initializing controller
    IEditController* controller = nullptr;
    component->queryInterface(IEditController::iid, (void**)&controller);

    if (controller) {
        controller->initialize(component);
        component->connect(controller);
        controller->connect(component);
    }}

new_comp = %Q{    HostContext* hostContext = new HostContext();
    if (factory->createInstance(targetCID, IComponent::iid, (void**)&component) != kResultOk || !component) {
        std::cerr << "Failed to create IComponent instance\\n";
        factory->release();
        hostContext->release();
        return 1;
    }

    if (component->initialize(hostContext) != kResultOk) {
        std::cerr << "Warning: Failed to initialize component\\n";
    }

    IEditController* controller = nullptr;
    component->queryInterface(IEditController::iid, (void**)&controller);

    if (controller) {
        if (controller->initialize(hostContext) != kResultOk) {
            std::cerr << "Warning: Failed to initialize controller\\n";
        }
        component->connect(controller);
        controller->connect(component);
    }}
content.sub!(old_comp, new_comp)

# Patch cleanup
old_clean = %Q{        component->setActive(false);
        component->terminate();
        component->release();
        
        factory->release();
        module->exit();}
new_clean = %Q{        component->setActive(false);
        component->terminate();
        component->release();
        
        factory->release();
        hostContext->release();
        module->exit();}
content.sub!(old_clean, new_clean)

# Also fix the patch log statements I added earlier
content.gsub!("DEBUG: Getting factory\\n", "")
content.gsub!("DEBUG: Creating instance\\n", "")
content.gsub!("DEBUG: Initializing controller\\n", "")
content.gsub!("DEBUG: Loading state\\n", "")
content.gsub!("DEBUG: Setting state\\n", "")
content.gsub!("DEBUG: Setting controller state\\n", "")
content.gsub!("DEBUG: Getting state out\\n", "")
content.gsub!("std::cout << \"\";", "")

File.write("Host/nks-host/main.cpp", content)
