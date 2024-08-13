//
//  URL_Kit.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/4/9.
//

import Foundation
import CommonCrypto

extension URL {
    
    
    /// url 文件大小
    /// - Returns: res
    func fileSize() -> Int? {
        let resources = try? self.resourceValues(forKeys:[.fileSizeKey])
        return resources?.fileSize
    }
    
    
    /// file url md5 耗时操作
    /// - Returns: md5
    func md5String() -> String? {
        let bufferSize = 1024 * 1024
        do {
            // Open file for reading:
            let file = try FileHandle(forReadingFrom: self)
            defer {
                file.closeFile()
            }
            // Create and initialize MD5 context:
            var context = CC_MD5_CTX()
            CC_MD5_Init(&context)
            
            // Read up to `bufferSize` bytes, until EOF is reached, and update MD5 context:
            while autoreleasepool(invoking: {
                let data = file.readData(ofLength: bufferSize)
                if data.count > 0 {
                    data.withUnsafeBytes {
                        _ = CC_MD5_Update(&context, $0.baseAddress, numericCast(data.count))
                    }
                    return true // Continue
                } else {
                    return false // End of file
                }
            }) { }
            // Compute the MD5 digest:
            var digest: [UInt8] = Array(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            _ = CC_MD5_Final(&digest, &context)
            let hexDigest = digest.map { String(format: "%02hhx", $0) }.joined()
            return hexDigest
        } catch {
            print("Cannot open file:", error.localizedDescription)
            return nil
        }
    }
    
}
 
