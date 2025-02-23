import SwiftUI

struct NewContentView: View {
    
    var body: some View {
        ZStack {
            Color(hex: "18191A")
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                Text("Welcome to F1 Vision!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.leading, 40)
                
                Text("Welcome to F1 Vision!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                    .padding(.leading, 40)
                
                Button(action: {
                    
                }) {
                    HStack {
                        Text("Watch Race")
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
    NewContentView()
}


