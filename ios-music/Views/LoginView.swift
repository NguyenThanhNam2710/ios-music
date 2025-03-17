import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
                Text("MusicApp")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Millions of songs, just for you.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { _ in }
                )
                .frame(width: 300, height: 50)
                .signInWithAppleButtonStyle(.white)
                .onTapGesture {
                    viewModel.signInWithApple()
                }
            }
        }
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel())
}
