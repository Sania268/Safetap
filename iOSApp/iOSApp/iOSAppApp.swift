//
//  iOSAppApp.swift
//  iOSApp
//
//  Created by Javy on 2026/4/24.
//
//
//import SwiftUI
//
//@main
//struct iOSAppApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//
//  iOSAppApp.swift
//  SafeTap - Silent Emergency Alert System
//
//  Created by Group 15 on 2026/04/24.
//

//
//  iOSAppApp.swift
//  iOSApp - SafeTap Emergency System
//

//
//  iOSAppApp.swift
//  iOSApp - SafeTap Emergency System
//

//
//  iOSAppApp.swift
//  SafeTap - Silent Emergency Alert System
//

import SwiftUI
import Firebase

@main
struct iOSAppApp: App {
    @UIApplicationDelegateAdaptor(SafeTapAppDelegate.self) private var appDelegate
    @StateObject private var sessionManager = UserSessionManager.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
                .task {
                    sessionManager.configureIfNeeded()
                }
        }
    }
}
