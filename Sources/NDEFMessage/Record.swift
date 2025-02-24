import Foundation

extension NDEF {
	public protocol Record: NDEFEncodable {
		var header: Header { get }
		var type: [UInt8] { get }
		var id: [UInt8]? { get }
		var payload: [UInt8] { get }
	}
}

extension NDEF {
	public struct Header: NDEFEncodable {
		let flags: Set<Flag>
		let typeNameFormat: TNF
		let typeLength: UInt8
		let payloadLength: UInt32
		let idLength: UInt8?

		public enum Flag: Sendable {
			case messageBegin
			case messageEnd
			case chunk
			case shortRecord
			case idLengthIsPresent

			var mask: UInt8 {
				switch self {
				case .messageBegin:
					0b10000000
				case .messageEnd:
					0b01000000
				case .chunk:
					0b00100000
				case .shortRecord:
					0b00010000
				case .idLengthIsPresent:
					0b00001000
				}
			}
		}

		public enum TNF: UInt8, Sendable {
			case empty
			case wellKnownType
			case mimeType
			case absoluteURI
			case external
			case unknown
			case unchanged
			case reserved
		}

		public var encode: Data {
			let capacity = 1 + UInt(typeLength) + UInt(payloadLength) + UInt(idLength ?? 0)
			var data = Data(capacity: Int(capacity))

			var flagsAndTNF = typeNameFormat.rawValue
			for flag in flags {
				flagsAndTNF |= flag.mask
			}

			data.append(flagsAndTNF)
			data.append(typeLength)
			data.append(contentsOf: withUnsafeBytes(of: payloadLength.bigEndian) { Array($0) })
			if let idLength {
				data.append(idLength)
			}

			return data
		}
	}
}
