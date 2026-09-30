import Foundation
let magic: Int32 = 0x50523733
let bigE = magic.bigEndian
let str = String(format: "%08X", UInt32(bitPattern: magic))
let strBigE = String(format: "%08X", UInt32(bitPattern: bigE))
print("Host: \(str)")
print("BigE: \(strBigE)")
