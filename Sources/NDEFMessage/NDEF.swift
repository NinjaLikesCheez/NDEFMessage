protocol NDEFEncodable {
	var encoded: [UInt8] { get }
	var size: Int { get }
	var count: Int { get }
}

struct NDEF: NDEFEncodable {
	let message: Message

	var size: Int { message.size }
	var count: Int { message.count }
	var encoded: [UInt8] { message.encoded }
}
