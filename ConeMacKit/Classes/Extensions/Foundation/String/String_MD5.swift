//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/6.
//

import Foundation

public extension String {

    /// MD5加密类型
    enum MD5EncryptType {
        /// 32位小写
        case lowercase32
        /// 32位大写
        case uppercase32
        /// 16位小写
        case lowercase16
        /// 16位大写
        case uppercase16
    }
}

public extension String {
    /// MD5加密 默认是32位小写加密 因为CC_MD5 在iOS13 之后废弃 抄至 Kingfisher
    /// - Parameter type: 加密类型
    /// - Returns: 加密字符串
    func encryptMD5(_ md5Type: String.MD5EncryptType = .lowercase32) -> String {
        guard let data = self.data(using: .utf8) else {
            return self
        }

        let message = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            return [UInt8](bytes)
        }

        let MD5Calculator = MD5(message)
        let MD5Data = MD5Calculator.calculate()

        var MD5String = String()
        switch md5Type {
        case .lowercase32:
            for c in MD5Data {
                MD5String += String(format: "%02x", c)
            }
            return MD5String
        case .uppercase32:
            for c in MD5Data {
                MD5String += String(format: "%02X", c)
            }
            return MD5String
        case .lowercase16:
            for c in MD5Data {
                MD5String += String(format: "%02x", c)
            }
            return MD5String[8..<25]
        case .uppercase16:
            for c in MD5Data {
                MD5String += String(format: "%02X", c)
            }
            return MD5String[8..<25]
        }
        
    }
}

private func arrayOfBytes<T>(_ value: T, length: Int? = nil) -> [UInt8] {
    let totalBytes = length ?? (MemoryLayout<T>.size * 8)

    let valuePointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    valuePointer.pointee = value

    let bytes = valuePointer.withMemoryRebound(to: UInt8.self, capacity: totalBytes) { (bytesPointer) -> [UInt8] in
        var bytes = [UInt8](repeating: 0, count: totalBytes)
        for j in 0..<min(MemoryLayout<T>.size, totalBytes) {
            bytes[totalBytes - 1 - j] = (bytesPointer + j).pointee
        }
        return bytes
    }
    
    valuePointer.deinitialize(count: 1)
    valuePointer.deallocate()

    return bytes
}

private extension Int {
    
    func bytes(_ totalBytes: Int = MemoryLayout<Int>.size) -> [UInt8] {
        return arrayOfBytes(self, length: totalBytes)
    }

}

private extension NSMutableData {
    
    func appendBytes(_ arrayOfBytes: [UInt8]) {
        append(arrayOfBytes, length: arrayOfBytes.count)
    }

}

private protocol HashProtocol {
    var message: [UInt8] { get }
    func prepare(_ len: Int) -> [UInt8]
}

private extension HashProtocol {

    func prepare(_ len: Int) -> [UInt8] {
        var tmpMessage = message
        tmpMessage.append(0x80)

        var msgLength = tmpMessage.count
        var counter = 0

        while msgLength % len != (len - 8) {
            counter += 1
            msgLength += 1
        }

        tmpMessage += [UInt8](repeating: 0, count: counter)
        return tmpMessage
    }
}

private func toUInt32Array(_ slice: ArraySlice<UInt8>) -> [UInt32] {
    var result = [UInt32]()
    result.reserveCapacity(16)

    for idx in stride(from: slice.startIndex, to: slice.endIndex, by: MemoryLayout<UInt32>.size) {
        let d0 = UInt32(slice[idx.advanced(by: 3)]) << 24
        let d1 = UInt32(slice[idx.advanced(by: 2)]) << 16
        let d2 = UInt32(slice[idx.advanced(by: 1)]) << 8
        let d3 = UInt32(slice[idx])
        let val: UInt32 = d0 | d1 | d2 | d3

        result.append(val)
    }
    return result
}

private struct BytesIterator: IteratorProtocol {

    let chunkSize: Int
    let data: [UInt8]

    init(chunkSize: Int, data: [UInt8]) {
        self.chunkSize = chunkSize
        self.data = data
    }

    var offset = 0

    mutating func next() -> ArraySlice<UInt8>? {
        let end = min(chunkSize, data.count - offset)
        let result = data[offset..<offset + end]
        offset += result.count
        return result.count > 0 ? result : nil
    }
}

private struct BytesSequence: Sequence {
    let chunkSize: Int
    let data: [UInt8]

    func makeIterator() -> BytesIterator {
        return BytesIterator(chunkSize: chunkSize, data: data)
    }
}

private func rotateLeft(_ value: UInt32, bits: UInt32) -> UInt32 {
    return ((value << bits) & 0xFFFFFFFF) | (value >> (32 - bits))
}

private class MD5: HashProtocol {

    static let size = 16 // 128 / 8
    let message: [UInt8]

    init (_ message: [UInt8]) {
        self.message = message
    }

    private let shifts: [UInt32] = [7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
                                    5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
                                    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
                                    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21]

    private let sines: [UInt32] = [0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
                                   0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
                                   0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
                                   0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
                                   0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
                                   0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
                                   0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
                                   0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
                                   0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
                                   0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
                                   0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x4881d05,
                                   0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
                                   0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
                                   0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
                                   0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
                                   0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391]

    private let hashes: [UInt32] = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476]

    func calculate() -> [UInt8] {
        var tmpMessage = prepare(64)
        tmpMessage.reserveCapacity(tmpMessage.count + 4)
        
        var hh = hashes

        let lengthInBits = (message.count * 8)
        let lengthBytes = lengthInBits.bytes(64 / 8)
        tmpMessage += lengthBytes.reversed()
        
        let chunkSizeBytes = 512 / 8 // 64

        for chunk in BytesSequence(chunkSize: chunkSizeBytes, data: tmpMessage) {
            let M = toUInt32Array(chunk)
            assert(M.count == 16, "Invalid array")
            
            var A: UInt32 = hh[0]
            var B: UInt32 = hh[1]
            var C: UInt32 = hh[2]
            var D: UInt32 = hh[3]

            var dTemp: UInt32 = 0

            for j in 0 ..< sines.count {
                var g = 0
                var F: UInt32 = 0

                switch j {
                case 0...15:
                    F = (B & C) | ((~B) & D)
                    g = j
                case 16...31:
                    F = (D & B) | (~D & C)
                    g = (5 * j + 1) % 16
                case 32...47:
                    F = B ^ C ^ D
                    g = (3 * j + 5) % 16
                case 48...63:
                    F = C ^ (B | (~D))
                    g = (7 * j) % 16
                default:
                    break
                }
                dTemp = D
                D = C
                C = B
                B = B &+ rotateLeft((A &+ F &+ sines[j] &+ M[g]), bits: shifts[j])
                A = dTemp
            }

            hh[0] = hh[0] &+ A
            hh[1] = hh[1] &+ B
            hh[2] = hh[2] &+ C
            hh[3] = hh[3] &+ D
        }
        var result = [UInt8]()
        result.reserveCapacity(hh.count / 4)

        hh.forEach {
            let itemLE = $0.littleEndian
            let r1 = UInt8(itemLE & 0xff)
            let r2 = UInt8((itemLE >> 8) & 0xff)
            let r3 = UInt8((itemLE >> 16) & 0xff)
            let r4 = UInt8((itemLE >> 24) & 0xff)
            result += [r1, r2, r3, r4]
        }
        return result
    }
}

