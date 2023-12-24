import Foundation

class TwakeLogger {
    static let shared: TwakeLogger = TwakeLogger()
    
    func log(message: String) {
        debugPrint(message)
    }
}
