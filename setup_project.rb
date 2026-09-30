require 'xcodeproj'

project_path = 'App/NKSFConverter/NKSFConverter.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Add local package
pkg_ref = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
pkg_ref.relative_path = "../../Packages/NKSCore"
project.root_object.package_references << pkg_ref

# Add product dependency
pkg_dep = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
pkg_dep.product_name = "NKSCore"
pkg_dep.package = pkg_ref

# Link the product in the target
target.package_product_dependencies << pkg_dep

# Add a Copy Files Phase for nks-host
copy_phase = project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
copy_phase.name = "Copy nks-host"
copy_phase.dst_subfolder_spec = "6" # Executables / MacOS
target.build_phases << copy_phase

# Add the file reference
file_ref = project.new(Xcodeproj::Project::Object::PBXFileReference)
file_ref.path = "../../Host/build/Release/nks-host"
file_ref.source_tree = "<group>"
project.main_group.children << file_ref

build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
build_file.file_ref = file_ref

copy_phase.files << build_file

project.save
