import Foundation

public protocol NDEFEncodable: Sendable {
	var encode: Data { get }
}

public struct NDEF: Sendable {
	let messages: [Message]
}
