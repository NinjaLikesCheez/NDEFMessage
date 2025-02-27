protocol NDEFEncodable {
	var encoded: [UInt8] { get }
	var size: Int { get }
}

struct NDEF: NDEFEncodable {
	let message: Message

	var size: Int { message.size }
	var encoded: [UInt8] { message.encoded }
}
