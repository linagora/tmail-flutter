import Foundation

class PayloadParser {
    static let shared: PayloadParser = PayloadParser()
    
    private let prefixState: String = ":"
    
    private func validatePushNotificationStateChange(state: String) -> Bool {
        return state.contains(prefixState) &&
        (state.contains(TypeName.mailbox.rawValue) ||
         state.contains(TypeName.email.rawValue) ||
         state.contains(TypeName.EmailDelivery.rawValue))
    }
    
    func parsingPayloadNotification(payloadData: [String: Any]) -> [String: [TypeName: String]]{
        var mapStateChanges = [String: [TypeName: String]]()
        
        payloadData.keys.forEach { key in
            if validatePushNotificationStateChange(state: key),
               let accountId = key.components(separatedBy: prefixState).first,
               let typeName = TypeName(rawValue: key.components(separatedBy: prefixState).last ?? ""),
               let stateValue = payloadData[key] as? String {
                if (mapStateChanges.keys.contains(accountId)) {
                    var mapTypes = mapStateChanges[accountId]!
                    mapTypes[typeName] = stateValue
                    mapStateChanges[accountId] = mapTypes
                } else {
                    var mapTypes = [TypeName: String]()
                    mapTypes[typeName] = stateValue
                    mapStateChanges[accountId] = mapTypes
                }
            }
        }
        
        return mapStateChanges
    }
}
