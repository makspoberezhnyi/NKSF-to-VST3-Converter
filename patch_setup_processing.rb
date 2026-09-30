content = File.read("Host/nks-host/main.cpp")
old_active = "        if (component->setActive(true) != kResultOk) {"
new_active = "        std::cout << \"[DEBUG] setupProcessing...\" << std::endl;\n        ProcessSetup setup;\n        setup.processMode = kRealtime;\n        setup.symbolicSampleSize = kSample32;\n        setup.maxSamplesPerBlock = 1024;\n        setup.sampleRate = 44100.0;\n        component->setupProcessing(setup);\n\n        std::cout << \"[DEBUG] setActive(true)...\" << std::endl;\n        if (component->setActive(true) != kResultOk) {"
content.sub!(old_active, new_active)

old_comp = "    HostContext* hostContext = new HostContext();\n    if (factory->createInstance(targetCID, IComponent::iid, (void**)&component) != kResultOk || !component) {"
new_comp = "    std::cout << \"[DEBUG] Creating HostContext...\" << std::endl;\n    HostContext* hostContext = new HostContext();\n    std::cout << \"[DEBUG] createInstance...\" << std::endl;\n    if (factory->createInstance(targetCID, IComponent::iid, (void**)&component) != kResultOk || !component) {"
content.sub!(old_comp, new_comp)

content.gsub!("if (component->initialize(hostContext)", "std::cout << \"[DEBUG] component->initialize...\" << std::endl;\n    if (component->initialize(hostContext)")
content.gsub!("component->queryInterface(IEditController::iid", "std::cout << \"[DEBUG] queryInterface IEditController...\" << std::endl;\n    component->queryInterface(IEditController::iid")
content.gsub!("if (controller->initialize(hostContext)", "std::cout << \"[DEBUG] controller->initialize...\" << std::endl;\n        if (controller->initialize(hostContext)")
content.gsub!("component->connect(controller);", "std::cout << \"[DEBUG] connect controller...\" << std::endl;\n        component->connect(controller);")

content.gsub!("std::ifstream inFile(inStatePath", "std::cout << \"[DEBUG] Loading state file...\" << std::endl;\n        std::ifstream inFile(inStatePath")
content.gsub!("if (component->setState(&inStream)", "std::cout << \"[DEBUG] component->setState...\" << std::endl;\n        if (component->setState(&inStream)")
content.gsub!("if (controller && controller->setComponentState(&inStream)", "std::cout << \"[DEBUG] controller->setComponentState...\" << std::endl;\n        if (controller && controller->setComponentState(&inStream)")
content.gsub!("component->getState(&outStream);", "std::cout << \"[DEBUG] component->getState...\" << std::endl;\n        component->getState(&outStream);")
content.gsub!("component->setActive(false);", "std::cout << \"[DEBUG] Cleanup...\" << std::endl;\n        component->setActive(false);")

File.write("Host/nks-host/main.cpp", content)
