extension NDEF {
	struct Message: NDEFEncodable {
		let records: [Record]

		init(_ records: [Record]) {
			if let first = records.first {
				first.header.add(flag: .messageBegin)
			}

			if let last = records.last {
				last.header.add(flag: .messageEnd)
			}

			self.records = records
		}

		var count: Int {
			records.map(\.count).reduce(0, +)
		}

		var size: Int {
			records.map(\.size).reduce(0, +)
		}

		var encoded: [UInt8] {
			records.flatMap(\.encoded)
		}
	}
}
