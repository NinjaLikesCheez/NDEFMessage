extension NDEF.Record {
	static var empty: EmptyRecord { .init() }

	static func uri(_ uri: String, id: [UInt8]? = nil) -> NDEF.URIRecord {
		.init(uri, id: id)
	}
}

extension NDEF {
	class Record: NDEFEncodable {
		var header: Header
		let type: [UInt8]
		let id: [UInt8]?
		let payload: [UInt8]

		required init(header: Header, type: [UInt8], id: [UInt8]?, payload: [UInt8]) {
			self.header = header
			self.type = type
			self.id = id
			self.payload = payload
		}

		var size: Int {
			// TODO: these sizes are wrong - we want the memory layout representation not the amount of items in the array... duh...
			header.size + type.count + (id?.count ?? 0) + payload.count
		}

		var encoded: [UInt8] {
			var data = [UInt8]()
			data.reserveCapacity(size)

			data.append(contentsOf: header.encoded)
			data.append(contentsOf: type)
			if let id {
				data.append(contentsOf: id)
			}

			data.append(contentsOf: payload)

			return data
		}
	}
}

extension NDEF {
	struct Header {
		private(set) var flags: Set<Flag>
		let typeNameFormat: TNF
		let typeLength: UInt8
		let payloadLength: UInt32
		let idLength: UInt8?

		init(typeNameFormat: TNF, type: [UInt8], payload: [UInt8], id: [UInt8]?) {
			self.typeNameFormat = typeNameFormat
			typeLength = UInt8(type.count)
			payloadLength = UInt32(payload.count)
			flags = []

			if let id {
				flags.insert(.idLengthIsPresent)
				self.idLength = UInt8(id.count)
			} else {
				self.idLength = nil
			}

			if payload.count > 255 {
				flags.insert(.shortRecord)
			}
		}

		mutating func add(flag: Flag) {
			flags.insert(flag)
		}

		enum Flag: Sendable {
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

		enum TNF: UInt8, Sendable {
			case empty
			case wellKnownType
			case mimeType
			case absoluteURI
			case external
			case unknown
			case unchanged
			case reserved
		}

		var size: Int {
			// one byte holds the flags & TNF
			1 + Int(typeLength) + Int(payloadLength) + Int(idLength ?? 0)
		}

		var encoded: [UInt8] {
			var data = [UInt8]()
			data.reserveCapacity(size)

			var flagsAndTNF = typeNameFormat.rawValue
			for flag in flags {
				flagsAndTNF |= flag.mask
			}

			data.append(flagsAndTNF)
			data.append(typeLength)

			if flags.contains(.shortRecord) {
				data.append(UInt8(payloadLength))
			} else {
				data.append(contentsOf: withUnsafeBytes(of: payloadLength.bigEndian) { Array($0) })
			}

			if let idLength {
				data.append(idLength)
			}

			return data
		}
	}
}
