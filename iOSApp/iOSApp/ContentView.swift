////
////  ContentView.swift
////  iOSApp
////
////  Created by Javy on 2026/4/24.
////
//
////import SwiftUI
////
////struct ContentView: View {
////    var body: some View {
////        VStack {
////            Image(systemName: "globe")
////                .imageScale(.large)
////                .foregroundStyle(.tint)
////            Text("Hello, world!")
////        }
////        .padding()
////    }
////}
////
////#Preview {
////    ContentView()
////}
////
////  ContentView.swift
////  SafeTap - Silent Emergency Alert System
////
////  Created by Group 15 on 2026/04/24.
////
//
////
////  ContentView.swift
////  SafeTap - Silent Emergency Alert System
////
//
//import SwiftUI
//import CoreLocation
//
//struct ContentView: View {
//    @State private var isRealApp = false
//    @State private var calculatorInput = ""
//    @State private var sosTriggered = false
//    @State private var secretTapCount = 0
//    @State private var lastTapTime: Date = Date()
//    
//    var body: some View {
//        ZStack {
//            if isRealApp {
//                EmergencyDashboardView(sosTriggered: $sosTriggered, isRealApp: $isRealApp)
//            } else {
//                CalculatorDisguiseView(
//                    input: $calculatorInput,
//                    onSecretTap: handleSecretTap
//                )
//            }
//        }
//        .onAppear {
//            setupSOSListener()
//        }
//    }
//    
//    func handleSecretTap() {
//        let now = Date()
//        if now.timeIntervalSince(lastTapTime) < 0.8 {
//            secretTapCount += 1
//        } else {
//            secretTapCount = 1
//        }
//        lastTapTime = now
//        
//        if secretTapCount >= 3 {
//            withAnimation {
//                isRealApp = true
//            }
//            secretTapCount = 0
//        }
//    }
//    
//    func setupSOSListener() {
//        NotificationCenter.default.addObserver(
//            forName: NSNotification.Name("SOSButtonTriggered"),
//            object: nil,
//            queue: .main
//        ) { _ in
//            sosTriggered = true
//            isRealApp = true
//            SOSManager.shared.startRecording()
//        }
//    }
//}
//
//// MARK: - Calculator Disguise
//struct CalculatorDisguiseView: View {
//    @Binding var input: String
//    var onSecretTap: () -> Void
//    
//    let buttons = [
//        ["7", "8", "9", "/"],
//        ["4", "5", "6", "*"],
//        ["1", "2", "3", "-"],
//        ["0", ".", "=", "+"]
//    ]
//    
//    var body: some View {
//        VStack(spacing: 12) {
//            Spacer()
//            
//            // Display
//            Text(input.isEmpty ? "0" : input)
//                .font(.system(size: 64, weight: .light))
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity, alignment: .trailing)
//                .padding(.horizontal, 24)
//                .padding(.vertical, 20)
//                .background(Color.black.opacity(0.3))
//                .cornerRadius(20)
//            
//            // Buttons
//            ForEach(buttons, id: \.self) { row in
//                HStack(spacing: 12) {
//                    ForEach(row, id: \.self) { button in
//                        Button(action: {
//                            handleCalculatorTap(button)
//                        }) {
//                            Text(button)
//                                .font(.title)
//                                .frame(width: 70, height: 70)
//                                .background(buttonColor(button))
//                                .foregroundColor(.white)
//                                .cornerRadius(35)
//                        }
//                    }
//                }
//            }
//            
//            Spacer()
//        }
//        .padding()
//        .background(Color.black)
//        .ignoresSafeArea()
//    }
//    
//    func handleCalculatorTap(_ button: String) {
//        if button == "=" {
//            // Fix: Check if input is not empty before evaluating
//            if !input.isEmpty && input != "." {
//                // Simple safe evaluation
//                let result = evaluateExpression(input)
//                if let result = result {
//                    // Remove .0 if it's a whole number
//                    if result.truncatingRemainder(dividingBy: 1) == 0 {
//                        input = String(Int(result))
//                    } else {
//                        input = String(result)
//                    }
//                }
//            }
//            onSecretTap()
//        } else if button == "C" {
//            input = ""
//        } else {
//            input += button
//        }
//    }
//
//    // Safe calculator function (no crashes)
//    func evaluateExpression(_ expression: String) -> Double? {
//        // Simple implementation for basic operations
//        let trimmed = expression.replacingOccurrences(of: " ", with: "")
//        
//        // Handle division by zero
//        if trimmed.contains("/0") {
//            return 0
//        }
//        
//        // Use NSExpression safely
//        let safeExpression = NSExpression(format: trimmed)
//        if let result = safeExpression.expressionValue(with: nil, context: nil) as? Double {
//            return result
//        }
//        return nil
//    }
//    
//    func buttonColor(_ button: String) -> Color {
//        let operators = ["/", "*", "-", "+", "="]
//        if operators.contains(button) {
//            return Color.orange
//        } else if button == "C" {
//            return Color.red
//        } else {
//            return Color.gray.opacity(0.7)
//        }
//    }
//}
//
////// MARK: - Calculator Disguise View (Fixed)
////struct CalculatorDisguiseView: View {
////    @Binding var input: String
////    var onSecretTap: () -> Void
////    
////    let buttons = [
////        ["7", "8", "9", "/"],
////        ["4", "5", "6", "*"],
////        ["1", "2", "3", "-"],
////        ["0", ".", "=", "+"]
////    ]
////    
////    var body: some View {
////        VStack(spacing: 12) {
////            Spacer()
////            
////            // Display
////            Text(input.isEmpty ? "0" : input)
////                .font(.system(size: 64, weight: .light))
////                .foregroundColor(.white)
////                .frame(maxWidth: .infinity, alignment: .trailing)
////                .padding(.horizontal, 24)
////                .padding(.vertical, 20)
////                .background(Color.black.opacity(0.3))
////                .cornerRadius(20)
////            
////            // Buttons
////            ForEach(buttons, id: \.self) { row in
////                HStack(spacing: 12) {
////                    ForEach(row, id: \.self) { button in
////                        Button(action: {
////                            handleCalculatorTap(button)
////                        }) {
////                            Text(button)
////                                .font(.title)
////                                .frame(width: 70, height: 70)
////                                .background(buttonColor(button))
////                                .foregroundColor(.white)
////                                .cornerRadius(35)
////                        }
////                    }
////                }
////            }
////            
////            Spacer()
////        }
////        .padding()
////        .background(Color.black)
////        .ignoresSafeArea()
////    }
////    
////    func handleCalculatorTap(_ button: String) {
////        if button == "=" {
////            // Only evaluate if input has content
////            if !input.isEmpty && input != "." {
////                let result = safeEvaluate(input)
////                if let result = result {
////                    if result.truncatingRemainder(dividingBy: 1) == 0 {
////                        input = String(Int(result))
////                    } else {
////                        input = String(result)
////                    }
////                }
////            }
////            // Trigger secret unlock on "=" tap
////            onSecretTap()
////        } else if button == "C" {
////            input = ""
////        } else {
////            input += button
////        }
////    }
////    
////    func safeEvaluate(_ expression: String) -> Double? {
////        // Remove any spaces
////        let cleaned = expression.replacingOccurrences(of: " ", with: "")
////        
////        // Prevent division by zero
////        if cleaned.contains("/0") {
////            return 0
////        }
////        
////        // Simple evaluation using NSExpression
////        let exp = NSExpression(format: cleaned)
////        if let result = exp.expressionValue(with: nil, context: nil) as? Double {
////            return result
////        }
////        return nil
////    }
////    
////    func buttonColor(_ button: String) -> Color {
////        let operators = ["/", "*", "-", "+", "="]
////        if operators.contains(button) {
////            return Color.orange
////        } else if button == "C" {
////            return Color.red
////        } else {
////            return Color.gray.opacity(0.7)
////        }
////    }
////}
////
////
//
//
//// MARK: - Emergency Dashboard
//struct EmergencyDashboardView: View {
//    @Binding var sosTriggered: Bool
//    @Binding var isRealApp: Bool
//    @State private var contacts: [EmergencyContact] = []
//    @State private var showingAddContact = false
//    @State private var locationStatus = "Waiting for GPS..."
//    @State private var recordingStatus = "Standby"
//    @State private var showCancelButton = false
//    @State private var cancelCountdown = 3
//    
//    var body: some View {
//        NavigationView {
//            List {
//                Section {
//                    if sosTriggered {
//                        VStack(alignment: .leading, spacing: 10) {
//                            HStack {
//                                Image(systemName: "exclamationmark.triangle.fill")
//                                    .foregroundColor(.red)
//                                Text("EMERGENCY ACTIVE")
//                                    .font(.headline)
//                                    .foregroundColor(.red)
//                            }
//                            
//                            if showCancelButton {
//                                Button(action: cancelSOS) {
//                                    HStack {
//                                        Text("Cancel SOS (\(cancelCountdown))")
//                                        Spacer()
//                                        Image(systemName: "xmark.circle")
//                                    }
//                                    .foregroundColor(.white)
//                                    .padding()
//                                    .background(Color.red)
//                                    .cornerRadius(10)
//                                }
//                            } else {
//                                Text("Emergency contacts notified")
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                    } else {
//                        Button(action: manualTriggerSOS) {
//                            HStack {
//                                Image(systemName: "sos")
//                                Text("Test SOS")
//                            }
//                            .foregroundColor(.red)
//                        }
//                    }
//                }
//                
//                Section(header: Text("Live Location")) {
//                    HStack {
//                        Image(systemName: "location.fill")
//                            .foregroundColor(.blue)
//                        Text(locationStatus)
//                    }
//                    if let location = SOSManager.shared.lastLocation {
//                        Text("Lat: \(String(format: "%.6f", location.coordinate.latitude))")
//                        Text("Lon: \(String(format: "%.6f", location.coordinate.longitude))")
//                    }
//                }
//                
//                Section(header: Text("Audio Recording")) {
//                    HStack {
//                        Image(systemName: "mic.fill")
//                            .foregroundColor(recordingStatus == "Recording" ? .red : .gray)
//                        Text(recordingStatus)
//                    }
//                }
//                
//                Section(header: Text("Emergency Contacts")) {
//                    ForEach(contacts) { contact in
//                        VStack(alignment: .leading) {
//                            Text(contact.name)
//                                .font(.headline)
//                            Text(contact.phoneNumber)
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    .onDelete(perform: deleteContacts)
//                    
//                    Button(action: { showingAddContact = true }) {
//                        Label("Add Contact", systemImage: "plus.circle")
//                    }
//                }
//                
//                Section(header: Text("Instructions")) {
//                    Text("• Press power button 5x to trigger SOS")
//                    Text("• No sound or vibration")
//                    Text("• Tap '=' 3x to return to calculator")
//                }
//            }
//            .navigationTitle("SafeTap")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Lock") {
//                        withAnimation {
//                            isRealApp = false
//                        }
//                    }
//                }
//            }
//            .sheet(isPresented: $showingAddContact) {
//                AddContactView { name, phone in
//                    let newContact = EmergencyContact(name: name, phoneNumber: phone)
//                    contacts.append(newContact)
//                    CloudManager.shared.saveContacts(contacts)
//                }
//            }
//        }
//        .onAppear {
//            contacts = CloudManager.shared.loadContacts()
//            startStatusTimers()
//        }
//    }
//    
//    func startStatusTimers() {
//        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
//            if let location = SOSManager.shared.lastLocation {
//                locationStatus = "📍 \(String(format: "%.6f", location.coordinate.latitude)), \(String(format: "%.6f", location.coordinate.longitude))"
//            }
//            recordingStatus = SOSManager.shared.isRecording ? "🔴 Recording" : "⚪ Standby"
//        }
//    }
//    
//    func manualTriggerSOS() {
//        showCancelButton = true
//        cancelCountdown = 3
//        
//        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//            if cancelCountdown <= 1 {
//                timer.invalidate()
//                showCancelButton = false
//                sosTriggered = true
//                SOSManager.shared.startRecording()
//                CloudManager.shared.sendBulkAlert()
//            } else {
//                cancelCountdown -= 1
//            }
//        }
//    }
//    
//    func cancelSOS() {
//        showCancelButton = false
//        sosTriggered = false
//        SOSManager.shared.stopRecording()
//    }
//    
//    func deleteContacts(at offsets: IndexSet) {
//        contacts.remove(atOffsets: offsets)
//        CloudManager.shared.saveContacts(contacts)
//    }
//}
//
//// MARK: - Add Contact View
//struct AddContactView: View {
//    @Environment(\.dismiss) var dismiss
//    @State private var name = ""
//    @State private var phone = ""
//    var onSave: (String, String) -> Void
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                TextField("Contact Name", text: $name)
//                TextField("Phone Number (with country code)", text: $phone)
//                    .keyboardType(.phonePad)
//            }
//            .navigationTitle("Add Emergency Contact")
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") { dismiss() }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Save") {
//                        if !name.isEmpty && !phone.isEmpty {
//                            onSave(name, phone)
//                            dismiss()
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Data Model
//struct EmergencyContact: Identifiable, Codable {
//    let id: UUID
//    let name: String
//    let phoneNumber: String
//    
//    init(id: UUID = UUID(), name: String, phoneNumber: String) {
//        self.id = id
//        self.name = name
//        self.phoneNumber = phoneNumber
//    }
//}

//
//  ContentView.swift
//  SafeTap - Silent Emergency Alert System
//

import SwiftUI
import CoreLocation
import AVFoundation
import UIKit

struct ContentView: View {
    @EnvironmentObject private var sessionManager: UserSessionManager
    @State private var isRealApp = false
    @State private var calculatorInput = ""
    @State private var sosTriggered = false
    @State private var secretTapCount = 0
    @State private var lastTapTime: Date = Date()
    @State private var sosObserver: NSObjectProtocol?
    @State private var profileNameDraft = ""
    
    var body: some View {
        Group {
            if sessionManager.isLoading {
                ProgressView("Preparing SafeTap...")
            } else {
                ZStack {
                    if isRealApp {
                        EmergencyDashboardView(sosTriggered: $sosTriggered, isRealApp: $isRealApp)
                    } else {
                        CalculatorDisguiseView(
                            input: $calculatorInput,
                            onSecretTap: handleSecretTap
                        )
                    }
                }
                .onAppear {
                    setupSOSListener()
                }
                .onDisappear {
                    removeSOSListener()
                }
            }
        }
        .sheet(
            isPresented: Binding(
                get: { !sessionManager.isLoading && sessionManager.requiresProfileSetup },
                set: { _ in }
            )
        ) {
            ProfileSetupView(
                draftName: $profileNameDraft,
                onSave: {
                    sessionManager.updateDisplayName(profileNameDraft)
                }
            )
        }
    }
    
    func handleSecretTap() {
        let now = Date()
        if now.timeIntervalSince(lastTapTime) < 0.8 {
            secretTapCount += 1
        } else {
            secretTapCount = 1
        }
        lastTapTime = now
        
        if secretTapCount >= 3 {
            withAnimation {
                isRealApp = true
            }
            secretTapCount = 0
        }
    }
    
    func setupSOSListener() {
        guard sosObserver == nil else { return }

        sosObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("SOSButtonTriggered"),
            object: nil,
            queue: .main
        ) { _ in
            activateSOS()
        }
    }

    func removeSOSListener() {
        guard let sosObserver else { return }
        NotificationCenter.default.removeObserver(sosObserver)
        self.sosObserver = nil
    }

    func activateSOS() {
        guard !sosTriggered else { return }
        sosTriggered = true
        isRealApp = true
        _ = SOSManager.shared.activateSOS()
    }
}

struct ProfileSetupView: View {
    @Binding var draftName: String
    let onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Profile")) {
                    TextField("Display Name", text: $draftName)
                        .textInputAutocapitalization(.words)
                    Text("This name appears in incidents, alerts, and response history inside SafeTap.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Set Up SafeTap")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if draftName.isEmpty {
                    draftName = UserSessionManager.shared.displayName == "SafeTap User" ? "" : UserSessionManager.shared.displayName
                }
            }
        }
        .interactiveDismissDisabled(true)
    }
}

// MARK: - Calculator Disguise View (FIXED - No Crashes)
struct CalculatorDisguiseView: View {
    @Binding var input: String
    var onSecretTap: () -> Void
    
    let buttons = [
        ["7", "8", "9", "/"],
        ["4", "5", "6", "*"],
        ["1", "2", "3", "-"],
        ["0", ".", "=", "+"]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            // Display
            Text(input.isEmpty ? "0" : input)
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(Color.black.opacity(0.3))
                .cornerRadius(20)
            
            // Buttons
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { button in
                        Button(action: {
                            handleCalculatorTap(button)
                        }) {
                            Text(button)
                                .font(.title)
                                .frame(width: 70, height: 70)
                                .background(buttonColor(button))
                                .foregroundColor(.white)
                                .cornerRadius(35)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.black)
        .ignoresSafeArea()
    }
    
    func handleCalculatorTap(_ button: String) {
        if button == "=" {
            // FIXED: Only evaluate if input is valid
            let isValid = !input.isEmpty && input != "." && input != "+" && input != "-" && input != "*" && input != "/"
            
            if isValid {
                let result = simpleCalculate(input)
                if let result = result {
                    if result.truncatingRemainder(dividingBy: 1) == 0 {
                        input = String(Int(result))
                    } else {
                        // Remove trailing zeros
                        let formatted = String(format: "%g", result)
                        input = formatted
                    }
                }
            }
            
            // Trigger secret unlock on every "=" tap
            onSecretTap()
            
        } else if button == "C" {
            input = ""
        } else {
            input += button
        }
    }
    
    // FIXED: Safe calculator that won't crash
    func simpleCalculate(_ expression: String) -> Double? {
        // Remove spaces
        let expr = expression.replacingOccurrences(of: " ", with: "")
        
        // Check for empty
        if expr.isEmpty { return nil }
        
        // Check for single invalid characters
        let invalid = [".", "+", "-", "*", "/"]
        if invalid.contains(expr) { return nil }
        
        // Prevent division by zero
        if expr.contains("/0") { return 0 }
        
        let exp = NSExpression(format: expr)
        if let result = exp.expressionValue(with: nil, context: nil) as? Double {
            return result
        }

        return nil
    }
    
    func buttonColor(_ button: String) -> Color {
        let operators = ["/", "*", "-", "+", "="]
        if operators.contains(button) {
            return Color.orange
        } else if button == "C" {
            return Color.red
        } else {
            return Color.gray.opacity(0.7)
        }
    }
}

// MARK: - Emergency Dashboard
struct EmergencyDashboardView: View {
    @EnvironmentObject private var sessionManager: UserSessionManager
    @Binding var sosTriggered: Bool
    @Binding var isRealApp: Bool
    @AppStorage("dashboardMode") private var dashboardModeRawValue = DashboardMode.owner.rawValue
    private let authorizationProbe = CLLocationManager()
    @State private var contacts: [EmergencyContact] = []
    @State private var incidents: [IncidentRecord] = []
    @State private var showingAddContact = false
    @State private var editingContact: EmergencyContact?
    @State private var locationStatus = "Waiting for GPS..."
    @State private var recordingStatus = "Standby"
    @State private var showCancelButton = false
    @State private var cancelCountdown = 3
    @State private var statusTimer: Timer?
    @State private var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    @State private var microphonePermissionState = MicrophonePermissionState.current
    @State private var expandedFeature: DashboardFeature?
    @State private var expandedIncidentID: String?
    @State private var isSyncingSharedIncidents = false
    @State private var notifiedSharedIncidentIDs = Set<String>()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Workspace")) {
                    Picker("Mode", selection: $dashboardModeRawValue) {
                        ForEach(DashboardMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(sessionManager.displayName)
                            .font(.headline)
                        Text("Identity: \(sessionManager.currentUserID)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Button("Copy My SafeTap ID") {
                            UIPasteboard.general.string = sessionManager.currentUserID
                        }
                        .font(.caption)
                    }

                    Button("Refresh Shared Incidents") {
                        refreshSharedIncidents()
                    }
                    .disabled(isSyncingSharedIncidents)
                }

                Section(header: Text(dashboardMode == .owner ? "Owner Controls" : "Emergency Response")) {
                    if dashboardMode == .owner {
                        ownerControlSection
                    } else {
                        emergencyResponseSection
                    }
                }

                Section(header: Text("System Readiness")) {
                    readinessRow(
                        title: "Emergency Contacts",
                        detail: contacts.isEmpty ? "Add at least one trusted contact before relying on SOS." : "\(contacts.count) contact\(contacts.count == 1 ? "" : "s") configured",
                        isReady: !contacts.isEmpty
                    )
                    readinessRow(
                        title: "Microphone Access",
                        detail: microphonePermissionState.detailText,
                        isReady: microphonePermissionState == .granted
                    )
                    readinessRow(
                        title: "Location Access",
                        detail: locationAuthorizationStatus.detailText,
                        isReady: locationAuthorizationStatus == .authorizedAlways || locationAuthorizationStatus == .authorizedWhenInUse
                    )
                    readinessRow(
                        title: "Back Tap Trigger",
                        detail: "Set Triple Tap to the 'Trigger SOS' shortcut in iPhone Settings > Accessibility > Touch > Back Tap.",
                        isReady: true
                    )
                }

                Section(header: Text("Key Functions")) {
                    featureRow(
                        feature: .triggerSOS
                    )
                    featureRow(
                        feature: .liveTracking
                    )
                    featureRow(
                        feature: .mistakeCorrection
                    )
                    featureRow(
                        feature: .emergencyContacts
                    )
                }

                Section(header: Text("Incident Feed")) {
                    if incidents.isEmpty {
                        Text("No incidents saved yet. Trigger a test SOS or respond from Emergency mode to build history.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(incidents) { incident in
                            incidentRow(incident)
                        }
                    }
                }
                
                Section(header: Text("Live Location")) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text(locationStatus)
                    }
                    if let location = SOSManager.shared.lastLocation {
                        Text("Lat: \(String(format: "%.6f", location.coordinate.latitude))")
                        Text("Lon: \(String(format: "%.6f", location.coordinate.longitude))")
                    }
                }
                
                Section(header: Text("Audio Recording")) {
                    HStack {
                        Image(systemName: "mic.fill")
                            .foregroundColor(recordingStatus == "Recording" ? .red : .gray)
                        Text(recordingStatus)
                    }
                    Text("Recording starts when SOS is activated and stops automatically after 10 minutes.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section(header: Text("Emergency Contacts")) {
                    ForEach(contacts) { contact in
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(contact.name)
                                    .font(.headline)
                                Text(contact.phoneNumber)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                if let linkedUserID = contact.linkedUserID, !linkedUserID.isEmpty {
                                    Text("SafeTap ID: \(linkedUserID)")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                }
                            }
                            Spacer()
                            Button("Edit") {
                                editingContact = contact
                            }
                            .font(.caption)
                            Button("Delete", role: .destructive) {
                                deleteContact(contact)
                            }
                            .font(.caption)
                        }
                    }
                    .onDelete(perform: deleteContacts)
                    
                    Button(action: { showingAddContact = true }) {
                        Label("Add Contact", systemImage: "plus.circle")
                    }
                }
                
            }
            .navigationTitle("SafeTap")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Lock") {
                        withAnimation {
                            isRealApp = false
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddContact) {
                ContactEditorView(mode: .add) { contact in
                    contacts.append(contact)
                    CloudManager.shared.saveContacts(contacts)
                    refreshDashboardData()
                }
            }
            .sheet(item: $editingContact) { contact in
                ContactEditorView(mode: .edit(contact)) { updatedContact in
                    updateContact(updatedContact)
                    refreshDashboardData()
                }
            }
        }
        .onAppear {
            refreshDashboardData()
            startSharedIncidentListener()
            startStatusTimers()
        }
        .onDisappear {
            statusTimer?.invalidate()
            statusTimer = nil
            CloudManager.shared.stopObservingSharedIncidents()
        }
    }

    private var dashboardMode: DashboardMode {
        DashboardMode(rawValue: dashboardModeRawValue) ?? .owner
    }
    
    func startStatusTimers() {
        statusTimer?.invalidate()
        statusTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            if let location = SOSManager.shared.lastLocation {
                locationStatus = "📍 \(String(format: "%.6f", location.coordinate.latitude)), \(String(format: "%.6f", location.coordinate.longitude))"
            }
            recordingStatus = SOSManager.shared.isRecording ? "🔴 Recording" : "⚪ Standby"
            refreshDashboardData()
        }
    }
    
    func manualTriggerSOS() {
        showCancelButton = true
        cancelCountdown = 3
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if cancelCountdown <= 1 {
                timer.invalidate()
                showCancelButton = false
                activateSOS()
            } else {
                cancelCountdown -= 1
            }
        }
    }

    func activateSOS() {
        guard !sosTriggered else { return }
        sosTriggered = true
        _ = SOSManager.shared.activateSOS()
        refreshDashboardData()
    }
    
    func cancelSOS() {
        showCancelButton = false
        sosTriggered = false
        SOSManager.shared.cancelSOS()
        refreshDashboardData()
    }
    
    func deleteContacts(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
        CloudManager.shared.saveContacts(contacts)
        refreshDashboardData()
    }

    func deleteContact(_ contact: EmergencyContact) {
        contacts.removeAll { $0.id == contact.id }
        CloudManager.shared.saveContacts(contacts)
        refreshDashboardData()
    }

    func updateContact(_ updatedContact: EmergencyContact) {
        guard let index = contacts.firstIndex(where: { $0.id == updatedContact.id }) else { return }
        contacts[index] = updatedContact
        CloudManager.shared.saveContacts(contacts)
        refreshDashboardData()
    }

    func refreshDashboardData() {
        contacts = CloudManager.shared.loadContacts()
        incidents = CloudManager.shared.loadIncidentHistory()
        sosTriggered = CloudManager.shared.latestActiveIncident() != nil
        locationAuthorizationStatus = authorizationProbe.authorizationStatus
        microphonePermissionState = MicrophonePermissionState.current
    }

    func refreshSharedIncidents() {
        guard !isSyncingSharedIncidents else { return }
        isSyncingSharedIncidents = true
        CloudManager.shared.syncSharedIncidents { sharedIncidents in
            mergeSharedIncidents(sharedIncidents, shouldNotify: false)
            isSyncingSharedIncidents = false
        }
    }

    func startSharedIncidentListener() {
        CloudManager.shared.observeSharedIncidents { sharedIncidents in
            mergeSharedIncidents(sharedIncidents, shouldNotify: true)
        }
    }

    func mergeSharedIncidents(_ sharedIncidents: [IncidentRecord], shouldNotify: Bool) {
        let localIncidents = CloudManager.shared.loadIncidentHistory()
        let previousIncidentIDs = Set(incidents.map(\.id))
        var incidentMap = Dictionary(uniqueKeysWithValues: localIncidents.map { ($0.id, $0) })

        for sharedIncident in sharedIncidents {
            incidentMap[sharedIncident.id] = sharedIncident

            let isNewSharedIncident = !previousIncidentIDs.contains(sharedIncident.id)
            let isOwnedBySomeoneElse = sharedIncident.ownerID != sessionManager.currentUserID
            if shouldNotify,
               sharedIncident.status == .active,
               isNewSharedIncident,
               isOwnedBySomeoneElse,
               !notifiedSharedIncidentIDs.contains(sharedIncident.id) {
                LocalNotificationManager.shared.notifyAboutSharedIncident(sharedIncident)
                notifiedSharedIncidentIDs.insert(sharedIncident.id)
            }
        }

        incidents = incidentMap.values.sorted { $0.updatedAt > $1.updatedAt }
    }

    @ViewBuilder
    var ownerControlSection: some View {
        if sosTriggered {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("EMERGENCY ACTIVE")
                        .font(.headline)
                        .foregroundColor(.red)
                }

                if showCancelButton {
                    Button(action: cancelSOS) {
                        HStack {
                            Text("Report Mistake / Cancel SOS (\(cancelCountdown))")
                            Spacer()
                            Image(systemName: "xmark.circle")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                } else {
                    Text("Emergency contacts notified and live tracking active")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Location uploads are limited to 3 updates per minute while recording.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("If this was a mistake, use the cancel action to send a correction alert.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        } else {
            Button(action: manualTriggerSOS) {
                HStack {
                    Image(systemName: "sos")
                    Text("Test SOS")
                }
                .foregroundColor(.red)
            }
        }
    }

    @ViewBuilder
    var emergencyResponseSection: some View {
        if let activeIncident = incidents.first(where: { $0.status == .active }) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Latest active incident from \(activeIncident.ownerName)")
                    .font(.headline)
                Text("Created \(activeIncident.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Use a quick response below to acknowledge that the emergency workspace saw the alert.")
                    .font(.caption)
                    .foregroundColor(.gray)

                Button("Acknowledge Alert") {
                    CloudManager.shared.sendSupportResponse("Emergency workspace acknowledged the alert.", incidentID: activeIncident.id)
                    refreshDashboardData()
                }

                Button("Request Check-In") {
                    CloudManager.shared.sendSupportResponse("Please confirm whether you are safe and able to respond.", incidentID: activeIncident.id)
                    refreshDashboardData()
                }

                Button("Mark Incident Resolved") {
                    CloudManager.shared.markLatestIncidentResolved(incidentID: activeIncident.id)
                    refreshDashboardData()
                }
                .foregroundColor(.green)

                if let coordinates = coordinates(from: activeIncident.latestLocationDescription) {
                    Button("Navigate to Location") {
                        openMaps(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    }
                    .foregroundColor(.blue)
                }

                Button("View Alert Details") {
                    expandedIncidentID = activeIncident.id
                }
            }
        } else {
            Text("No active incident to respond to. Switch to Owner mode to send a test SOS or wait for a new alert.")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    @ViewBuilder
    func readinessRow(title: String, detail: String, isReady: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: isReady ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(isReady ? .green : .orange)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    @ViewBuilder
    func featureRow(feature: DashboardFeature) -> some View {
        Button {
            withAnimation {
                expandedFeature = expandedFeature == feature ? nil : feature
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(feature.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: expandedFeature == feature ? "chevron.up.circle.fill" : "chevron.down.circle")
                        .foregroundColor(.blue)
                }
                Text(feature.summary)
                    .font(.caption)
                    .foregroundColor(.gray)

                if expandedFeature == feature {
                    Text(feature.details)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 2)
    }

    @ViewBuilder
    func incidentRow(_ incident: IncidentRecord) -> some View {
        Button {
            withAnimation {
                expandedIncidentID = expandedIncidentID == incident.id ? nil : incident.id
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(incident.ownerName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("\(incident.status.label) • \(incident.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: expandedIncidentID == incident.id ? "chevron.up.circle.fill" : "chevron.down.circle")
                        .foregroundColor(.blue)
                }

                Text(incident.events.last?.message ?? "No updates yet.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if expandedIncidentID == incident.id {
                    VStack(alignment: .leading, spacing: 8) {
                        if let latestLocationDescription = incident.latestLocationDescription {
                            Text("Latest location: \(latestLocationDescription)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            HStack {
                                Button("Navigate") {
                                    if let coordinates = coordinates(from: latestLocationDescription) {
                                        openMaps(latitude: coordinates.latitude, longitude: coordinates.longitude)
                                    }
                                }
                                Button("Copy Location") {
                                    UIPasteboard.general.string = latestLocationDescription
                                }
                            }
                            .font(.caption)
                        }

                        if !incident.recordingURLs.isEmpty {
                            Text("Recordings uploaded: \(incident.recordingURLs.count)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }

                        ForEach(Array(incident.events.suffix(5))) { event in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.type.displayTitle)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                Text(event.message)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Text(event.timestamp.formatted(date: .omitted, time: .shortened))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 2)
    }

    func coordinates(from locationDescription: String?) -> CLLocationCoordinate2D? {
        guard let locationDescription else { return nil }
        let parts = locationDescription.split(separator: ",").map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard parts.count == 2,
              let latitude = Double(parts[0]),
              let longitude = Double(parts[1]) else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func openMaps(latitude: Double, longitude: Double) {
        let urlString = "http://maps.apple.com/?ll=\(latitude),\(longitude)&q=SafeTap%20Emergency"
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Contact Editor
enum ContactEditorMode {
    case add
    case edit(EmergencyContact)

    var title: String {
        switch self {
        case .add:
            return "Add Emergency Contact"
        case .edit:
            return "Edit Emergency Contact"
        }
    }

    var existingContact: EmergencyContact? {
        switch self {
        case .add:
            return nil
        case .edit(let contact):
            return contact
        }
    }
}

struct ContactEditorView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var phone = ""
    @State private var safeTapID = ""
    let mode: ContactEditorMode
    var onSave: (EmergencyContact) -> Void

    init(mode: ContactEditorMode, onSave: @escaping (EmergencyContact) -> Void) {
        self.mode = mode
        self.onSave = onSave
        _name = State(initialValue: mode.existingContact?.name ?? "")
        _phone = State(initialValue: mode.existingContact?.phoneNumber ?? "")
        _safeTapID = State(initialValue: mode.existingContact?.linkedUserID ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Contact Name", text: $name)
                TextField("Phone Number (with country code)", text: $phone)
                    .keyboardType(.phonePad)
                TextField("SafeTap ID (optional)", text: $safeTapID)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Text("Add the contact's SafeTap ID so this incident appears in their Emergency workspace.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .navigationTitle(mode.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmedName.isEmpty && !trimmedPhone.isEmpty {
                            let linkedID = safeTapID.trimmingCharacters(in: .whitespacesAndNewlines)
                            onSave(
                                EmergencyContact(
                                    id: mode.existingContact?.id ?? UUID(),
                                    name: trimmedName,
                                    phoneNumber: trimmedPhone,
                                    linkedUserID: linkedID.isEmpty ? nil : linkedID
                                )
                            )
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Data Model
struct EmergencyContact: Identifiable, Codable {
    let id: UUID
    let name: String
    let phoneNumber: String
    let linkedUserID: String?
    
    init(id: UUID = UUID(), name: String, phoneNumber: String, linkedUserID: String? = nil) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.linkedUserID = linkedUserID
    }
}

private enum MicrophonePermissionState: Equatable {
    case granted
    case denied
    case undetermined
    case unknown

    static var current: MicrophonePermissionState {
        if #available(iOS 17.0, *) {
            switch AVAudioApplication.shared.recordPermission {
            case .granted:
                return .granted
            case .denied:
                return .denied
            case .undetermined:
                return .undetermined
            @unknown default:
                return .unknown
            }
        } else {
            switch AVAudioSession.sharedInstance().recordPermission {
            case .granted:
                return .granted
            case .denied:
                return .denied
            case .undetermined:
                return .undetermined
            @unknown default:
                return .unknown
            }
        }
    }

    var detailText: String {
        switch self {
        case .granted:
            return "Ready to record evidence during SOS."
        case .denied:
            return "Microphone access is off. Enable it in Settings to record during SOS."
        case .undetermined:
            return "Permission has not been requested yet. Start a test SOS to grant access."
        case .unknown:
            return "Permission state could not be determined."
        }
    }
}

private extension CLAuthorizationStatus {
    var detailText: String {
        switch self {
        case .authorizedAlways:
            return "Always-on location access is enabled."
        case .authorizedWhenInUse:
            return "Location access works while the app is open."
        case .denied, .restricted:
            return "Location access is unavailable. Enable it in Settings."
        case .notDetermined:
            return "Permission has not been requested yet."
        @unknown default:
            return "Location permission state could not be determined."
        }
    }
}

enum DashboardFeature: Hashable {
    case triggerSOS
    case liveTracking
    case mistakeCorrection
    case emergencyContacts

    var title: String {
        switch self {
        case .triggerSOS:
            return "Trigger SOS"
        case .liveTracking:
            return "Live Tracking"
        case .mistakeCorrection:
            return "Mistake Correction"
        case .emergencyContacts:
            return "Emergency Contacts"
        }
    }

    var summary: String {
        switch self {
        case .triggerSOS:
            return "Starts recording, sends one emergency alert immediately, and begins live location sharing."
        case .liveTracking:
            return "Uploads location during an active SOS, capped at 3 updates per minute."
        case .mistakeCorrection:
            return "Cancel SOS sends a follow-up message that the previous alert was a mistake."
        case .emergencyContacts:
            return "Add, review, and delete the people who should receive your SOS alerts."
        }
    }

    var details: String {
        switch self {
        case .triggerSOS:
            return "Use the Test SOS button in the dashboard or assign Back Tap Triple Tap to the Trigger SOS shortcut. When triggered, SafeTap starts recording, writes an emergency alert to Firebase for each saved contact, and marks the session as active."
        case .liveTracking:
            return "While SOS is active and recording is running, the app keeps the latest GPS fix visible in the dashboard and uploads location snapshots roughly every 20 seconds. This prevents flooding Firebase while still giving responders a moving trail."
        case .mistakeCorrection:
            return "If an SOS was accidental, use Cancel SOS as soon as possible. SafeTap stops recording, stops active SOS state, and writes a second alert entry marked as a cancellation so contacts know the previous alert was a mistake."
        case .emergencyContacts:
            return "Contacts are stored locally on the phone and deduplicated by name and phone number. The app sends one alert per saved contact, so review this list before relying on the system in a real emergency."
        }
    }
}

private extension IncidentStatus {
    var label: String {
        switch self {
        case .active:
            return "Active"
        case .canceled:
            return "Canceled"
        case .resolved:
            return "Resolved"
        }
    }
}

private extension IncidentEventType {
    var displayTitle: String {
        switch self {
        case .emergencyAlert:
            return "Emergency Alert"
        case .cancellation:
            return "Cancellation"
        case .locationUpdate:
            return "Location Update"
        case .recordingUploaded:
            return "Recording Uploaded"
        case .supportResponse:
            return "Support Response"
        }
    }
}
