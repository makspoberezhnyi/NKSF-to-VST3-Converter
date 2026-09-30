import UniformTypeIdentifiers

if let t1 = UTType(filenameExtension: "vst3") {
    print("t1: \(t1.identifier)")
} else {
    print("t1 is nil")
}

if let t2 = UTType(tag: "vst3", tagClass: .filenameExtension, conformingTo: nil) {
    print("t2: \(t2.identifier)")
} else {
    print("t2 is nil")
}
