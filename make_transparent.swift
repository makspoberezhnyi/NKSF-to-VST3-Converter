import AppKit

let inputPath = CommandLine.arguments[1]
let outputPath = CommandLine.arguments[2]

guard let img = NSImage(contentsOfFile: inputPath),
      let cgImage = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    print("Failed to load image")
    exit(1)
}

let width = cgImage.width
let height = cgImage.height
let colorSpace = CGColorSpaceCreateDeviceRGB()
let bytesPerPixel = 4
let bytesPerRow = bytesPerPixel * width
let bitsPerComponent = 8
let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

guard let context = CGContext(data: nil, width: width, height: height,
                              bitsPerComponent: bitsPerComponent,
                              bytesPerRow: bytesPerRow,
                              space: colorSpace,
                              bitmapInfo: bitmapInfo) else {
    exit(1)
}

context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
guard let data = context.data else { exit(1) }

let buffer = data.bindMemory(to: UInt8.self, capacity: width * height * 4)

for y in 0..<height {
    for x in 0..<width {
        let offset = (y * width + x) * 4
        let r = buffer[offset]
        let g = buffer[offset+1]
        let b = buffer[offset+2]
        // If close to white, make transparent
        if r > 240 && g > 240 && b > 240 {
            buffer[offset] = 0
            buffer[offset+1] = 0
            buffer[offset+2] = 0
            buffer[offset+3] = 0
        }
    }
}

guard let outCGImage = context.makeImage() else { exit(1) }
let outNSImage = NSImage(cgImage: outCGImage, size: NSSize(width: width, height: height))
guard let tiffData = outNSImage.tiffRepresentation,
      let bitmapRep = NSBitmapImageRep(data: tiffData),
      let pngData = bitmapRep.representation(using: .png, properties: [:]) else { exit(1) }

try? pngData.write(to: URL(fileURLWithPath: outputPath))
