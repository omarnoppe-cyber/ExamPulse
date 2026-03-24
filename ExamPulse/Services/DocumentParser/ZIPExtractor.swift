import Foundation
import Compression


enum ZIPExtractor {
    /// ZIP metadata is little-endian; reads must be alignment-safe on all CPUs.
    private static func readUInt32LE(_ data: Data, offset: Int) -> UInt32 {
        guard offset + 4 <= data.count else { return 0 }
        return UInt32(data[offset])
            | UInt32(data[offset + 1]) << 8
            | UInt32(data[offset + 2]) << 16
            | UInt32(data[offset + 3]) << 24
    }

    private static func readUInt16LE(_ data: Data, offset: Int) -> UInt16 {
        guard offset + 2 <= data.count else { return 0 }
        return UInt16(data[offset]) | UInt16(data[offset + 1]) << 8
    }

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
            let sig = readUInt32LE(data, offset: i)
            if sig == endOfCentralSignature {
                eocdOffset = i
                break
            }
        }
        guard eocdOffset >= 0 else { throw DocumentParsingError.parsingFailed("Invalid ZIP archive.") }

        let cdOffset = Int(readUInt32LE(data, offset: eocdOffset + 16))
        let cdSize = Int(readUInt32LE(data, offset: eocdOffset + 12))
        let cdEnd = cdOffset + cdSize
        guard cdEnd <= data.count else { throw DocumentParsingError.parsingFailed("Invalid ZIP archive.") }

        var entries: [CentralEntry] = []
        var offset = cdOffset

        while offset < cdEnd {
            let sig = readUInt32LE(data, offset: offset)
            if sig != centralHeaderSignature { break }

            let localHeaderOffset = readUInt32LE(data, offset: offset + 42)
            let filenameLength = readUInt16LE(data, offset: offset + 28)
            let extraLength = readUInt16LE(data, offset: offset + 30)
            let commentLength = readUInt16LE(data, offset: offset + 32)

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

        let sig = readUInt32LE(zipData, offset: offset)
        guard sig == localHeaderSignature else { throw DocumentParsingError.parsingFailed("Invalid ZIP archive.") }

        let compressionMethod = readUInt16LE(zipData, offset: offset + 8)
        let compressedSize = readUInt32LE(zipData, offset: offset + 18)
        let uncompressedSize = readUInt32LE(zipData, offset: offset + 22)
        let filenameLength = readUInt16LE(zipData, offset: offset + 26)
        let extraLength = readUInt16LE(zipData, offset: offset + 28)

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
        let destCapacity = max(uncompressedSize * 4, 4096)
        let destBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: destCapacity)
        defer { destBuffer.deallocate() }

        // ZIP stores raw deflate; Apple's COMPRESSION_ZLIB expects raw deflate (no zlib header).
        let decodedCount = data.withUnsafeBytes { src in
            compression_decode_buffer(
                destBuffer,
                destCapacity,
                src.bindMemory(to: UInt8.self).baseAddress!,
                data.count,
                nil,
                COMPRESSION_ZLIB
            )
        }

        guard decodedCount > 0 else { throw DocumentParsingError.parsingFailed("Failed to decompress ZIP entry.") }
        return Data(bytes: destBuffer, count: decodedCount)
    }
}
