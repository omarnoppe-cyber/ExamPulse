import Foundation
import Compression


enum ZIPExtractor {
    private static let localHeaderSignature: UInt32 = 0x04034b50
    private static let centralHeaderSignature: UInt32 = 0x02014b50
    private static let endOfCentralSignature: UInt32 = 0x06054b50
    private static let compressionStored: UInt16 = 0
    private static let compressionDeflate: UInt16 = 8

    static func extract(zipURL: URL, to destinationURL: URL) throws {
        let data = try Data(contentsOf: zipURL)
        try extract(zipData: data, to: destinationURL)
    }

    static func extract(zipData: Data, to destinationURL: URL) throws {
        let fm = FileManager.default
        try fm.createDirectory(at: destinationURL, withIntermediateDirectories: true)

        let entries = try findCentralDirectoryEntries(in: zipData)

        for entry in entries {
            let localHeaderOffset = Int(entry.localHeaderOffset)
            guard localHeaderOffset < zipData.count else { continue }

            let (path, compressionMethod, compressedSize, uncompressedSize, dataOffset) = try parseLocalHeader(
                zipData: zipData, offset: localHeaderOffset
            )
            guard !path.isEmpty, !path.hasPrefix("/"),
                  !path.contains("..") else { continue }

            let destFile = destinationURL.appendingPathComponent(path)
            if path.hasSuffix("/") {
                try fm.createDirectory(at: destFile, withIntermediateDirectories: true)
            } else {
                let parentDir = destFile.deletingLastPathComponent()
                try fm.createDirectory(at: parentDir, withIntermediateDirectories: true)

                let range = dataOffset..<(dataOffset + Int(compressedSize))
                guard range.upperBound <= zipData.count else { continue }

                let compressed = zipData.subdata(in: range)
                let decompressed: Data
                switch compressionMethod {
                case compressionStored:
                    decompressed = compressed
                case compressionDeflate:
                    decompressed = try inflate(compressed, uncompressedSize: Int(uncompressedSize))
                default:
                    throw DocumentParsingError.parsingFailed("Unsupported compression method: \(compressionMethod).")
                }
                try decompressed.write(to: destFile)
            }
        }
    }

    private struct CentralEntry {
        let localHeaderOffset: UInt32
        let filenameLength: UInt16
        let extraLength: UInt16
        let commentLength: UInt16
        let filenameOffset: Int
    }

    private static func findCentralDirectoryEntries(in data: Data) throws -> [CentralEntry] {
        var searchStart = data.count - 22
        if searchStart < 0 { searchStart = 0 }

        var eocdOffset = -1
        for i in stride(from: min(data.count - 22, searchStart), through: 0, by: -1) {
            let sig = data.withUnsafeBytes { $0.load(fromByteOffset: i, as: UInt32.self) }
            if sig == endOfCentralSignature.littleEndian {
                eocdOffset = i
                break
            }
        }
        guard eocdOffset >= 0 else { throw DocumentParsingError.parsingFailed("Invalid ZIP archive.") }

        let cdOffset = Int(data.withUnsafeBytes { $0.load(fromByteOffset: eocdOffset + 16, as: UInt32.self) }.littleEndian)
        let cdSize = Int(data.withUnsafeBytes { $0.load(fromByteOffset: eocdOffset + 12, as: UInt32.self) }.littleEndian)
        let cdEnd = cdOffset + cdSize
        guard cdEnd <= data.count else { throw DocumentParsingError.parsingFailed("Invalid ZIP archive.") }

        var entries: [CentralEntry] = []
        var offset = cdOffset

        while offset < cdEnd {
            let sig = data.withUnsafeBytes { $0.load(fromByteOffset: offset, as: UInt32.self) }
            if sig != centralHeaderSignature.littleEndian { break }

            let localHeaderOffset = data.withUnsafeBytes { $0.load(fromByteOffset: offset + 42, as: UInt32.self) }.littleEndian
            let filenameLength = data.withUnsafeBytes { $0.load(fromByteOffset: offset + 28, as: UInt16.self) }.littleEndian
            let extraLength = data.withUnsafeBytes { $0.load(fromByteOffset: offset + 30, as: UInt16.self) }.littleEndian
            let commentLength = data.withUnsafeBytes { $0.load(fromByteOffset: offset + 32, as: UInt16.self) }.littleEndian

            entries.append(CentralEntry(
                localHeaderOffset: localHeaderOffset,
                filenameLength: filenameLength,
                extraLength: extraLength,
                commentLength: commentLength,
                filenameOffset: offset + 46
            ))

            offset += 46 + Int(filenameLength) + Int(extraLength) + Int(commentLength)
        }

        return entries
    }

    private static func parseLocalHeader(zipData: Data, offset: Int) throws -> (path: String, method: UInt16, compressedSize: UInt32, uncompressedSize: UInt32, dataOffset: Int) {
        guard offset + 30 <= zipData.count else { throw DocumentParsingError.parsingFailed("Invalid ZIP archive.") }

        let sig = zipData.withUnsafeBytes { $0.load(fromByteOffset: offset, as: UInt32.self) }
        guard sig == localHeaderSignature.littleEndian else { throw DocumentParsingError.parsingFailed("Invalid ZIP archive.") }

        let compressionMethod = zipData.withUnsafeBytes { $0.load(fromByteOffset: offset + 8, as: UInt16.self) }.littleEndian
        let compressedSize = zipData.withUnsafeBytes { $0.load(fromByteOffset: offset + 18, as: UInt32.self) }.littleEndian
        let uncompressedSize = zipData.withUnsafeBytes { $0.load(fromByteOffset: offset + 22, as: UInt32.self) }.littleEndian
        let filenameLength = zipData.withUnsafeBytes { $0.load(fromByteOffset: offset + 26, as: UInt16.self) }.littleEndian
        let extraLength = zipData.withUnsafeBytes { $0.load(fromByteOffset: offset + 28, as: UInt16.self) }.littleEndian

        let filenameStart = offset + 30
        let path: String
        if filenameLength > 0, filenameStart + Int(filenameLength) <= zipData.count {
            path = String(data: zipData.subdata(in: filenameStart..<(filenameStart + Int(filenameLength))), encoding: .utf8)
                ?? String(data: zipData.subdata(in: filenameStart..<(filenameStart + Int(filenameLength))), encoding: .ascii) ?? ""
        } else {
            path = ""
        }

        let dataOffset = filenameStart + Int(filenameLength) + Int(extraLength)
        return (path, compressionMethod, compressedSize, uncompressedSize, dataOffset)
    }

    private static func inflate(_ data: Data, uncompressedSize: Int) throws -> Data {
        let destCapacity = uncompressedSize * 4
        let destBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: destCapacity)
        defer { destBuffer.deallocate() }

        var zlibData = Data([0x78, 0x9C])
        zlibData.append(data)

        let decodedCount = zlibData.withUnsafeBytes { src in
            compression_decode_buffer(
                destBuffer,
                destCapacity,
                src.bindMemory(to: UInt8.self).baseAddress!,
                zlibData.count,
                nil,
                COMPRESSION_ZLIB
            )
        }

        guard decodedCount > 0 else { throw DocumentParsingError.parsingFailed("Failed to decompress ZIP entry.") }
        return Data(bytes: destBuffer, count: decodedCount)
    }
}
