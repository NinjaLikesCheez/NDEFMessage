import Testing
@testable import NDEFMessage

@Suite struct MessageRequirements {
	@Test func firstRecordIsMarkedWithMB() {
		let ndef = NDEF(message: .init([.uri("https://example.com"), .empty, .empty]))

		let firstRecord = ndef.message.records[0]
		let middleRecord = ndef.message.records[1]
		let lastRecord = ndef.message.records[2]

		#expect(firstRecord.header.flags.contains(.messageBegin), "First record should contain MB flag")
		#expect(!firstRecord.header.flags.contains(.messageEnd), "First record should not contain ME flag")

		#expect(!middleRecord.header.flags.contains(.messageBegin), "Middle record should not contain MB flag")
		#expect(!middleRecord.header.flags.contains(.messageEnd), "Middle record should not contain ME flag")

		#expect(!lastRecord.header.flags.contains(.messageBegin), "Last record should not contain MB flag")
		#expect(lastRecord.header.flags.contains(.messageEnd), "Last record should contain ME flag")
	}
}
