import Foundation
import AuthenticationServices

class LoginViewModel: NSObject, ObservableObject { // Kế thừa NSObject
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    
    private let keychain = KeychainManager.shared
    
    override init() {
        super.init()
        checkExistingLogin()
    }
    
    func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
    
    func checkExistingLogin() {
        if let userID = keychain.get(forKey: "appleUserID") {
            checkCredentialState(userID: userID)
        }
    }
    
    private func checkCredentialState(userID: String) {
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { [weak self] state, error in
            DispatchQueue.main.async {
                switch state {
                case .authorized:
                    self?.isLoggedIn = true
                case .revoked, .notFound:
                    self?.logout()
                default:
                    self?.errorMessage = error?.localizedDescription
                }
            }
        }
    }
    
    func logout() {
        keychain.delete(forKey: "appleUserID")
        keychain.delete(forKey: "appleRefreshToken")
        isLoggedIn = false
    }
}

extension LoginViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userID = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            keychain.save(userID, forKey: "appleUserID")
            if let refreshToken = appleIDCredential.authorizationCode?.base64EncodedString() {
                keychain.save(refreshToken, forKey: "appleRefreshToken")
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.isLoggedIn = true
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = error.localizedDescription
        }
    }
}
