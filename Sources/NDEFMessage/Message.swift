extension NDEF {
	public struct Message: Sendable {
		let records: [Record]
	}
}

// TODO: test this \xd1\x01\x0fU\x04swiftisland.nl