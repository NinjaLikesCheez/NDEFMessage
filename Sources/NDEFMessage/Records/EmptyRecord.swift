import Foundation

final class EmptyRecord: NDEF.Record {
	required init(
		header: NDEF.Header = .init(typeNameFormat: .empty, type: [], payload: [], id: nil),
		type: [UInt8] = [],
		id: [UInt8]? = nil,
		payload: [UInt8] = []
	) {
		assert(type.count == 0, "Empty record should not have a type")
		assert(id == nil, "Empty record should not have an ID")
		assert(payload.count == 0, "Empty record should not have a payload")

		super.init(
			header:
			.init(
				typeNameFormat: .empty,
				type: type,
				payload: type,
				id: id
			),
			type: type,
			id: id,
			payload: payload
		)
	}
}
