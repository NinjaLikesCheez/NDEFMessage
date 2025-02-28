import Testing
@testable import NDEFMessage

@Suite struct DataTests {
	@Test func testURI() {
		let expected: [UInt8] = [
			0xd1, 0x01, 0x0f, 0x55, 0x04, 0x73, 0x77, 0x69, 0x66, 0x74, 0x69, 0x73, 0x6c, 0x61, 0x6e, 0x64, 0x2e, 0x6e, 0x6c
		]

		let ndef = NDEF.Message([.uri("https://swiftisland.nl")])
		let encoded = ndef.encoded
		print("actual: \(encoded.map { String(format: "%02x", $0) }.joined(separator: ""))")
		print("expected: \(expected.map { String(format: "%02x", $0) }.joined(separator: ""))")
		#expect(ndef.encoded == expected)
	}

	@Test func testEmpty() {
		let expected: [UInt8] = [
			0xd0, 0x00, 0x00
		]

		let ndef = NDEF.Message([.empty])
		let encoded = ndef.encoded
		print("actual: \(encoded.map { String(format: "%02x", $0) }.joined(separator: ""))")
		print("expected: \(expected.map { String(format: "%02x", $0) }.joined(separator: ""))")
		#expect(ndef.encoded == expected)
	}
}
