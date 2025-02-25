import Foundation

extension NDEF {
	public struct URIRecord: Record {
		public let header: NDEF.Header
		public let type: [UInt8] = [0x55] // 'U' - see NFC RTD URI Spec 2.3.1
		public let id: [UInt8]?
		public let payload: [UInt8]

		init(_ uri: String, id: [UInt8]? = nil) {
			// Create payload
			let uriProtocol = URIProtocol.uriProtocol(for: uri)
			let trimmedURI = String(uri[uri.index(uri.startIndex, offsetBy: uriProtocol.rawValue.count)...])

			payload = [uriProtocol.identifier] + Array(trimmedURI.utf8)

			header = .init(
				flags: [.messageBegin],
				typeNameFormat: .wellKnownType,
				type: type,
				payload: payload,
				id: id
			)

			self.id = id
		}
	}
}
