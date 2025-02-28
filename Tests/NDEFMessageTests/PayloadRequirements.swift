import Testing
@testable import NDEFMessage

@Suite struct PayloadRequirements {
	@Test func payloadLengthIsCorrectSizeForRecordType() {
		let ndef = NDEF(message:
			.init([
				// swiftlint:disable:next line_length
				.uri("https://example.com/reallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallyreallylong"),
				.uri("https://example.com"),
				.empty
			])
		)

		let firstRecord = ndef.message.records[0]
		let secondRecord = ndef.message.records[1]

		// FIRST: Check the 'large' record encoded size matches the expected value

		let lrSize = MemoryLayout<UInt32>.size
		#expect(!firstRecord.header.flags.contains(.shortRecord), "Payload size of more than 256 should not have SR flag")
		let firstEncoded = firstRecord.header.encoded

		// Get the offset into the header for a 'large' record size (4 bytes)
		let firstOffset = firstRecord.header.size - lrSize
		var largeSlice = Array(firstEncoded[firstOffset..<(firstOffset + lrSize)])

		#expect(
			largeSlice.count * MemoryLayout<UInt8>.stride >= MemoryLayout<UInt32>.stride,
			"Expected slice to be of the same memory size as a UInt32"
		)

		let length = largeSlice.withUnsafeMutableBytes { buffer in
			buffer.load(as: UInt32.self)
		}
		#expect(length == firstRecord.header.payloadLength)

		// SECOND: Check the 'small' record encoded size matches the expected value
		let srSize = MemoryLayout<UInt8>.size
		#expect(secondRecord.header.flags.contains(.shortRecord), "Payload size of more than 256 should not have SR flag")
		let secondEncoded = secondRecord.header.encoded

		// Get the offset into the header for a 'small' record size (1 byte)
		let secondOffset = secondRecord.header.size - srSize
		var secondSlice = Array(secondEncoded[secondOffset..<(secondOffset + srSize)])

		#expect(
			secondSlice.count * MemoryLayout<UInt8>.stride >= MemoryLayout<UInt8>.stride,
			"Expected slice to be of the same memory size as a UInt32"
		)

		let secondLength = secondSlice.withUnsafeMutableBytes { buffer in
			buffer.load(as: UInt8.self)
		}
		#expect(secondLength == secondRecord.header.payloadLength)
	}
}
