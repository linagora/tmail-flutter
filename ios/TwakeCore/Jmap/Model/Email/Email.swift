import Foundation

struct Email: Codable {
    let id: String
    let subject: String?
    let preview: String?
    let from: [EmailAddress]?
}
