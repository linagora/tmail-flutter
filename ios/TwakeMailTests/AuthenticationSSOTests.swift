import XCTest

@testable import Runner

final class AuthenticationSSOTests: XCTestCase {

    func testIsExpiredTimeMethodWithValidExpireTime() {
        let currentDate = CoreUtils.shared.getCurrentDate()
        let expireDate = currentDate.addingTimeInterval(3600)
        
        let authenticationSSO = AuthenticationSSO(
            type: AuthenticationType.oidc,
            accessToken: "abcxyz",
            refreshToken: "abcxyz",
            expireTime: expireDate.convertDateToISO8601String()
        )
        
        XCTAssertFalse(authenticationSSO.isExpiredTime(currentDate: currentDate))
    }
    
    func testIsExpiredTimeMethodWithExpireTime() {
        let currentDate = CoreUtils.shared.getCurrentDate()
        let expireDate = currentDate.addingTimeInterval(-3600)
        
        let authenticationSSO = AuthenticationSSO(
            type: AuthenticationType.oidc,
            accessToken: "abcxyz",
            refreshToken: "abcxyz",
            expireTime: expireDate.convertDateToISO8601String()
        )
        
        XCTAssertTrue(authenticationSSO.isExpiredTime(currentDate: currentDate))
    }

    func testIsExpiredTimeMethodNilExpireTime() {
        let currentDate = CoreUtils.shared.getCurrentDate()
        
        let authenticationSSO = AuthenticationSSO(
            type: AuthenticationType.oidc,
            accessToken: "abcxyz",
            refreshToken: "abcxyz",
            expireTime: nil
        )
        
        XCTAssertFalse(authenticationSSO.isExpiredTime(currentDate: currentDate))
    }
}
