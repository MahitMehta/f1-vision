//
//  EventNotification.swift
//  f1-vision
//
//  Created by Mahit Mehta on 2/23/25.
//

import SwiftUI

struct EventNotification: View {
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        Text("Event Notification")
            .onAppear {
                delayedDismiss()
            }
    }
    
    func delayedDismiss() {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(3 * 1_000_000_000))
            
            DispatchQueue.main.async {
                dismissWindow(id: "event-notif")
            }
        }
    }
}

#Preview {
    EventNotification()
}
