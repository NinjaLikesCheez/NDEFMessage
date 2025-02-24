import Foundation

public struct EmptyRecord: NDEF.Record {
    public var header: NDEF.Header

    public var type: [UInt8]

    public var id: [UInt8]?

    public var payload: [UInt8]

	public var encode: Data {
		.init()
	}
}
