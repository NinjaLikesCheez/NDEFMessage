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

		var count: Int {
			header.count + type.count + (id?.count ?? 0) + payload.count
		}

		var size: Int {
			header.size +
				(MemoryLayout<UInt8>.size * type.count) +
				(MemoryLayout<UInt8>.size * (id?.count ?? 0)) +
				(MemoryLayout<UInt8>.size * payload.count)
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

			if payload.count < 255 {
				flags.insert(.shortRecord)
			}

			// Verify specification requirements
			assert(0x00...0x06 ~= typeNameFormat.rawValue, "TNF must be between 0x00 & 0x06")

			switch typeNameFormat.rawValue {
			case 0x00:
				assert(
					typeLength == 0 && idLength == 0 && payloadLength == 0,
					"A TNF of 0x00 (Empty) requires that type, id, and payload length are all zero"
				)
			case 0x05:
				assert(typeLength == 0, "A TNF of 0x05 (Unknown) requires that type length is 0")
			case 0x06:
				assert(typeLength == 0, "A TNF of 0x06 (Unchanged) requires that type length is 0")
			case 0x07:
				assert(true, "A TNF of 0x07 (Reserved) is not allowed")
			default:
				break
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
			var size: Int = 1
			size += MemoryLayout.size(ofValue: typeLength)
			if flags.contains(.shortRecord) {
				size += MemoryLayout<UInt8>.size
			} else {
				size += MemoryLayout<UInt32>.size
			}

			if let idLength {
				size += MemoryLayout.size(ofValue: idLength)
			}

			return size
		}

		var count: Int {
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
