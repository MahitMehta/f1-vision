import SwiftUI

struct LoginView: View {
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            Color(hex: "18191A")
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.leading, 40)
                
                Text("Enter your details to sign into your account")
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "D3D3D3"))
                    .padding(.top, 1)
                    .padding(.leading, 40)
                
                Text("Email")
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "D3D3D3"))
                    .padding(.top, 10)
                    .padding(.leading, 40)
                
                TextField("Email", text: $email)
                    .padding(.vertical, 15)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
                    .keyboardType(.emailAddress)
                
                Text("Password")
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "D3D3D3"))
                    .padding(.top, 10)
                    .padding(.leading, 40)
                                    
                SecureField("Password", text: $password)
                    .padding(.vertical, 15)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
                
                Button(action: {
                    
                }) {
                    HStack {
                        Image("google")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                        
                        Text("Continue with Google")
                            .font(.headline)
                            .padding(.vertical, 10)
                    }
                    .cornerRadius(10)
                    .padding(.vertical, 5)
                }
                .padding(.leading, 40)
                .padding(.top, 10)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .cornerRadius(20)
    }
}
        

#Preview() {
    LoginView()
    .frame(width: 500, height: 600)
}


