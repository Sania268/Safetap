//
//  SOSManager.swift
//  SafeTap - Silent Emergency Alert System
//

import Foundation
import AVFoundation
import CoreLocation
import UIKit

class SOSManager: NSObject {
    static let shared = SOSManager()
    
    // Recording
    var audioRecorder: AVAudioRecorder?
    var isRecording = false
    private var currentRecordingURL: URL?
    
    // Location
    private let locationManager = CLLocationManager()
    var lastLocation: CLLocation?
    private var lastUploadedLocationAt: Date?
    private let locationUploadInterval: TimeInterval = 20
    private(set) var isSOSActive = false
    
    override private init() {
        super.init()
        setupLocation()
        setupAudioSession()
    }
    
    // MARK: - Audio Recording
    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default, options: .mixWithOthers)
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func startRecording() {
        guard !isRecording else { return }
        if #available(iOS 17.0, *) {
            switch AVAudioApplication.shared.recordPermission {
            case .granted:
                beginRecordingSession()
            case .undetermined:
                AVAudioApplication.requestRecordPermission { [weak self] granted in
                    guard granted else {
                        print("Microphone permission denied")
                        return
                    }

                    DispatchQueue.main.async {
                        self?.beginRecordingSession()
                    }
                }
            case .denied:
                print("Microphone permission denied")
            @unknown default:
                print("Unknown microphone permission state")
            }
        } else {
            let permission = AVAudioSession.sharedInstance().recordPermission

            switch permission {
            case .granted:
                beginRecordingSession()
            case .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                    guard granted else {
                        print("Microphone permission denied")
                        return
                    }

                    DispatchQueue.main.async {
                        self?.beginRecordingSession()
                    }
                }
            case .denied:
                print("Microphone permission denied")
            @unknown default:
                print("Unknown microphone permission state")
            }
        }
    }

    private func beginRecordingSession() {
        guard !isRecording else { return }
        lastUploadedLocationAt = nil
        
        let filename = "sos_recording_\(Date().timeIntervalSince1970).m4a"
        let filepath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        currentRecordingURL = filepath
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: filepath, settings: settings)
            audioRecorder?.record()
            isRecording = true
            print("🔴 Recording started")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 600) { [weak self] in
                self?.stopRecording()
            }
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        lastUploadedLocationAt = nil
        print("⏹️ Recording stopped")
        
        if let url = currentRecordingURL {
            CloudManager.shared.uploadRecording(url)
        }
    }

    @discardableResult
    func activateSOS() -> Bool {
        guard !isSOSActive else { return false }
        isSOSActive = true
        startRecording()
        CloudManager.shared.sendBulkAlert()
        return true
    }

    func cancelSOS() {
        guard isSOSActive else { return }
        CloudManager.shared.sendCancellationAlert()
        isSOSActive = false
        stopRecording()
    }
    
    // MARK: - Location Setup real iphon
    // MARK: - Location Setup
    func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check iOS version for proper authorization
        if #available(iOS 14, *) {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.requestAlwaysAuthorization()
        }
        
        // Only enable background updates on real device
        #if targetEnvironment(simulator)
        // Don't enable background location on simulator
        print("Running on simulator - background location disabled")
        #else
        // Only enable background updates when the app declares the location background mode.
        if supportsBackgroundLocationUpdates {
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
        } else {
            print("Background location mode not enabled in app configuration")
        }
        #endif
        
        locationManager.startUpdatingLocation()
    }

    private var supportsBackgroundLocationUpdates: Bool {
        guard let backgroundModes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String] else {
            return false
        }
        return backgroundModes.contains("location")
    }
    
//    // MARK: - Location Setup
//    func setupLocation() {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()  // Use "When In Use" instead of "Always"
//        // Background location is commented out for simulator testing
//        // locationManager.allowsBackgroundLocationUpdates = true
//        locationManager.startUpdatingLocation()
//    }
}

// MARK: - CLLocationManagerDelegate
extension SOSManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        if isRecording, shouldUploadLocation(at: Date()) {
            CloudManager.shared.sendLocation(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    private func shouldUploadLocation(at timestamp: Date) -> Bool {
        guard let lastUploadedLocationAt else {
            lastUploadedLocationAt = timestamp
            return true
        }

        guard timestamp.timeIntervalSince(lastUploadedLocationAt) >= locationUploadInterval else {
            return false
        }

        self.lastUploadedLocationAt = timestamp
        return true
    }
}
