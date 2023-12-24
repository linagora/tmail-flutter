import Foundation

struct JmapRequestObject: Codable {
    let using: [String]
    let methodCalls: [[RequestInvocation]]
}

enum RequestInvocation: Codable {
    case methodRequest(MethodRequest)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(MethodRequest.self) {
            self = .methodRequest(x)
            return
        }
        throw DecodingError.typeMismatch(RequestInvocation.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for RequestInvocation"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .methodRequest(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

struct MethodRequest: Codable {
    let accountId: String
    let sinceState: String?
    let ids: ResultReference?
    let properties: [String]?
    
    enum CodingKeys: String, CodingKey {
        case accountId
        case sinceState
        case ids = "#ids"
        case properties
    }
}

struct ResultReference: Codable {
    let resultOf, name, path: String
}

extension JmapRequestObject {
    func toData() -> Data? {
        if let encodedData = try? JSONEncoder().encode(self) {
            return encodedData
        }
        return nil
    }
    
    func toJson() -> String? {
        if let data = toData(), let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
}
