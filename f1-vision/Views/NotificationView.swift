import SwiftUI

struct NotificationView: View {
    var notificationMessage: String
    var displayDuration: TimeInterval // Time in seconds
    @State private var isVisible = true

    var body: some View {
        ZStack {
            if isVisible {
                // Background parallelogram
                Parallelogram()
                    .fill(Color(hex: "111015"))
                    .frame(height: 120)
                    .shadow(radius: 5)

                // Text overlay
                Text(notificationMessage)
                    .foregroundColor(.white)
                    .font(.title)
                    .padding(.horizontal)
            }
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
                // Hide the notification after the specified duration
                withAnimation {
                    isVisible = false
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

#Preview {
    NotificationView(notificationMessage: "Fastest lap by VER with 1:30.456.", displayDuration: 3.0)
}
