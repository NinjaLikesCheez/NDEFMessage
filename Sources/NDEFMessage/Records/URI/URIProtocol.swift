extension NDEF.URIRecord {
	public enum URIProtocol: String, CaseIterable {
		case none = ""
		case httpWWW = "http://www."
		case httpsWWW = "https://www."
		case http = "http://"
		case https = "https://"
		case tel = "tel:"
		case mailto = "mailto:"
		case ftpAnonymous = "ftp://anonymous:anonymous@"
		case ftpDotFtp = "ftp://ftp."
		case ftps = "ftps://"
		case sftp = "sftp://"
		case smb = "smb://"
		case nfs = "nfs://"
		case ftp = "ftp://"
		case dav = "dav://"
		case news = "news:"
		case telnet = "telnet://"
		case imap = "imap:"
		case rtsp = "rtsp://"
		case urn = "urn:"
		case pop = "pop:"
		case sip = "sip:"
		case sips = "sips:"
		case tftp = "tftp:"
		case btspp = "btspp://"
		case btl2cap = "btl2cap://"
		case btgoep = "btgoep://"
		case tcpobex = "tcpobex://"
		case irdaobex = "irdaobex://"
		case file = "file://"
		case urnEpcId = "urn:epc:id:"
		case urnEpcTag = "urn:epc:tag:"
		case urnEpcPat = "urn:epc:pat:"
		case urnEpcRaw = "urn:epc:raw:"
		case urnEpc = "urn:epc:"
		case urnNfc = "urn:nfc:"

		static func uriProtocol(for uri: String) -> URIProtocol {
			for uriPrefix in URIProtocol.allCases where uri.starts(with: uriPrefix.rawValue) {
				return uriPrefix
			}

			return .none
		}

		var identifier: UInt8 {
			switch self {
			case .none: 0x00
			case .httpWWW: 0x01
			case .httpsWWW: 0x02
			case .http: 0x03
			case .https: 0x04
			case .tel: 0x05
			case .mailto: 0x06
			case .ftpAnonymous: 0x07
			case .ftpDotFtp: 0x08
			case .ftps: 0x09
			case .sftp: 0x0A
			case .smb: 0x0B
			case .nfs: 0x0C
			case .ftp: 0x0D
			case .dav: 0x0E
			case .news: 0x0F
			case .telnet: 0x10
			case .imap: 0x11
			case .rtsp: 0x12
			case .urn: 0x13
			case .pop: 0x14
			case .sip: 0x15
			case .sips: 0x16
			case .tftp: 0x17
			case .btspp: 0x18
			case .btl2cap: 0x19
			case .btgoep: 0x1A
			case .tcpobex: 0x1B
			case .irdaobex: 0x1C
			case .file: 0x1D
			case .urnEpcId: 0x1E
			case .urnEpcTag: 0x1F
			case .urnEpcPat: 0x20
			case .urnEpcRaw: 0x21
			case .urnEpc: 0x22
			case .urnNfc: 0x23
			}
		}
	}
}
