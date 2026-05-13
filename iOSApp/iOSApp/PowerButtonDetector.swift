//
//  PowerButtonDetector.swift
//  SafeTap - Silent Emergency Alert System
//

import UIKit
import SwiftUI

class PowerButtonDetector {
    static let shared = PowerButtonDetector()
    
    private var pressCount = 0
    private var pressTimer: Timer?
    
    private init() {
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    @objc private func applicationWillResignActive() {
        pressCount += 1
        print("⚡ Power button pressed: \(pressCount)")
        
        pressTimer?.invalidate()
        pressTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.pressCount = 0
        }
        
        if pressCount >= 4 {
            print("🚨 SOS TRIGGERED BY POWER BUTTON! 🚨")
            NotificationCenter.default.post(name: NSNotification.Name("SOSButtonTriggered"), object: nil)
            pressCount = 0
        }
    }
}
