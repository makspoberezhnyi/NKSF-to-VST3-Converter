sed -i '' 's/IPluginFactory\* factory = nullptr;/std::cout << "DEBUG: Getting factory\\n"; IPluginFactory* factory = nullptr;/g' Host/nks-host/main.cpp
sed -i '' 's/IComponent\* component = nullptr;/std::cout << "DEBUG: Creating instance\\n"; IComponent* component = nullptr;/g' Host/nks-host/main.cpp
sed -i '' 's/IEditController\* controller = nullptr;/std::cout << "DEBUG: Initializing controller\\n"; IEditController* controller = nullptr;/g' Host/nks-host/main.cpp
sed -i '' 's/std::ifstream inFile/std::cout << "DEBUG: Loading state\\n"; std::ifstream inFile/g' Host/nks-host/main.cpp
sed -i '' 's/if (component->setState/std::cout << "DEBUG: Setting state\\n"; if (component->setState/g' Host/nks-host/main.cpp
sed -i '' 's/if (controller && controller->setComponentState/std::cout << "DEBUG: Setting controller state\\n"; if (controller \&\& controller->setComponentState/g' Host/nks-host/main.cpp
sed -i '' 's/component->getState(&outStream)/std::cout << "DEBUG: Getting state out\\n"; component->getState(\&outStream)/g' Host/nks-host/main.cpp
