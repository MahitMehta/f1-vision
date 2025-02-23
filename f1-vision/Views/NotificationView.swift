import SwiftUI

struct NotificationViewProps : Decodable, Encodable, Hashable {
    let notificationMessage: String
    let displayDuration: TimeInterval
}

struct NotificationView: View {
    
    @Environment(\.dismissWindow) var dismissWindow
    var contentProps: NotificationViewProps?
    
    var body: some View {
        ZStack {
            Parallelogram()
                .fill(Color(hex: "111015"))
                .frame(height: 120)
                .shadow(radius: 5)
            
            if let contentProps = contentProps {
                Text(contentProps.notificationMessage)
                    .foregroundColor(.white)
                    .font(.title2)
                    .padding(.horizontal)
            }
            
        }
        .padding()
        .onAppear {
            if let contentProps = contentProps {
                DispatchQueue.main.asyncAfter(deadline: .now() + contentProps.displayDuration) {
                    dismissWindow(id: "notification")
                }
            }
        }
    }
}

struct Parallelogram: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let offset: CGFloat = 20
            path.move(to: CGPoint(x: offset, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - offset, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}
