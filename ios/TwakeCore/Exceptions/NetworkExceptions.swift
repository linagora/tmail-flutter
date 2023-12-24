import Foundation

class NetworkExceptions: Error {
    static let requestUrlInvalid = NetworkExceptions(value: "Request url invalid")
    
    var value: String?
    
    init(value: String? = nil) {
        self.value = value
    }
}
