import Testing
@testable import NDEFMessage

@Suite struct PayloadRequirements {
	@Test func payloadLengthIsCorrectSizeForRecordType() {
		let ndef = NDEF(message:
			.init([
				// swiftlint:disable:next line_length
				.uri("https://example.com/reallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallylong"),
				.uri("https://example.com"),
				.empty
			])
		)

		let firstRecord = ndef.message.records[0]
		let middleRecord = ndef.message.records[1]
		let lastRecord = ndef.message.records[2]

		let srSize = MemoryLayout<UInt8>.size
		let lrSize = MemoryLayout<UInt32>.size

		#expect(!firstRecord.header.flags.contains(.shortRecord), "Payload size of more than 256 should not have SR flag")
		var firstEncoded = firstRecord.encoded
		let firstRecordPayloadLength: UInt32 = firstEncoded.read(at: firstRecord.size - lrSize - 1)
		#expect(firstRecord.header.payloadLength == firstRecordPayloadLength)

		#expect(middleRecord.header.flags.contains(.shortRecord), "Payload size of less than 256 should not have SR flag")
		let middleRecordPayloadLength: UInt8 = middleRecord.encoded.read(at: middleRecord.size - srSize - 1)
		#expect(middleRecord.header.payloadLength == middleRecordPayloadLength)
	}
}

extension [UInt8] {
	func read<T>(at offset: Int) -> T {
		let slice = self[offset..<(offset + MemoryLayout<T>.size)]

		return slice.withUnsafeBytes { buffer in
			buffer.load(as: T.self)
		}
	}
}
