//
//  CloudManager.swift
//  SafeTap - Silent Emergency Alert System
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import CoreLocation
import UIKit

enum DashboardMode: String, Codable, CaseIterable, Identifiable {
    case owner = "Owner"
    case emergency = "Emergency"

    var id: String { rawValue }
}

enum IncidentStatus: String, Codable {
    case active
    case canceled
    case resolved
}

enum IncidentEventType: String, Codable {
    case emergencyAlert
    case cancellation
    case locationUpdate
    case recordingUploaded
    case supportResponse
}

struct IncidentEvent: Identifiable, Codable, Hashable {
    let id: UUID
    let type: IncidentEventType
    let author: String
    let timestamp: Date
    let message: String
    let locationDescription: String?
    let recordingURL: String?

    init(
        id: UUID = UUID(),
        type: IncidentEventType,
        author: String,
        timestamp: Date = Date(),
        message: String,
        locationDescription: String? = nil,
        recordingURL: String? = nil
    ) {
        self.id = id
        self.type = type
        self.author = author
        self.timestamp = timestamp
        self.message = message
        self.locationDescription = locationDescription
        self.recordingURL = recordingURL
    }
}

struct IncidentRecord: Identifiable, Codable, Hashable {
    let id: String
    let ownerID: String?
    let ownerName: String
    let contactNames: [String]
    let contactIDs: [String]?
    let createdAt: Date
    var updatedAt: Date
    var status: IncidentStatus
    var latestLocationDescription: String?
    var recordingURLs: [String]
    var events: [IncidentEvent]
}

class CloudManager {
    static let shared = CloudManager()

    private static let databaseURL = "https://safetap-2b38b-default-rtdb.asia-southeast1.firebasedatabase.app/"
    private static let contactsKey = "emergencyContacts"
    private static let incidentHistoryKey = "incidentHistory"
    private static let activeIncidentIDKey = "activeIncidentID"

    private let database: DatabaseReference
    private let storage: StorageReference
    private let userDefaults = UserDefaults.standard
    private var sharedIncidentsHandle: DatabaseHandle?

    private init() {
        database = Database.database(url: Self.databaseURL).reference()
        storage = Storage.storage().reference()
    }

    // MARK: - Emergency Contacts
    func saveContacts(_ contacts: [EmergencyContact]) {
        let uniqueContacts = deduplicatedContacts(from: contacts)
        if let encoded = try? JSONEncoder().encode(uniqueContacts) {
            userDefaults.set(encoded, forKey: Self.contactsKey)
        }
        syncConnections(for: uniqueContacts)
    }

    func loadContacts() -> [EmergencyContact] {
        guard let data = userDefaults.data(forKey: Self.contactsKey),
              let contacts = try? JSONDecoder().decode([EmergencyContact].self, from: data) else {
            return []
        }

        return deduplicatedContacts(from: contacts)
    }

    func syncSharedIncidents(completion: @escaping ([IncidentRecord]) -> Void) {
        let currentUserID = currentUserID()
        guard currentUserID != "unknown-user" else {
            completion([])
            return
        }

        database.child("userIncidents").child(currentUserID).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else {
                completion([])
                return
            }

            self.fetchSharedIncidents(from: snapshot, completion: completion)
        }
    }

    func observeSharedIncidents(completion: @escaping ([IncidentRecord]) -> Void) {
        stopObservingSharedIncidents()

        let currentUserID = currentUserID()
        guard currentUserID != "unknown-user" else {
            completion([])
            return
        }

        sharedIncidentsHandle = database.child("userIncidents").child(currentUserID).observe(.value) { [weak self] snapshot in
            self?.fetchSharedIncidents(from: snapshot, completion: completion)
        }
    }

    func stopObservingSharedIncidents() {
        guard let sharedIncidentsHandle else { return }
        database.removeObserver(withHandle: sharedIncidentsHandle)
        self.sharedIncidentsHandle = nil
    }

    // MARK: - Incidents
    func loadIncidentHistory() -> [IncidentRecord] {
        guard let data = userDefaults.data(forKey: Self.incidentHistoryKey),
              let incidents = try? JSONDecoder().decode([IncidentRecord].self, from: data) else {
            return []
        }

        return incidents.sorted { $0.updatedAt > $1.updatedAt }
    }

    func latestActiveIncident() -> IncidentRecord? {
        loadIncidentHistory().first { $0.status == .active }
    }

    func sendBulkAlert() {
        let contacts = loadContacts()
        guard !contacts.isEmpty else {
            print("No emergency contacts configured")
            return
        }

        let incident = createIncident(for: contacts)
        for contact in contacts {
            sendEmergencyAlert(to: contact, incidentID: incident.id)
        }

        if let location = SOSManager.shared.lastLocation {
            sendLocation(location)
        }
    }

    func sendCancellationAlert() {
        let contacts = loadContacts()
        guard !contacts.isEmpty else {
            print("No emergency contacts configured")
            return
        }

        appendEventToActiveIncident(
            type: .cancellation,
            message: "\(getUserName()) marked the previous alert as a mistake."
        ) { incident in
            incident.status = .canceled
        }

        for contact in contacts {
            let message = """
            ✅ SOS CANCELED

            \(getUserName()) marked the previous alert as a mistake.
            Time: \(Date())
            """
            writeAlert(
                title: "📱 SENDING CANCELLATION ALERT",
                message: message,
                contact: contact,
                type: "cancellation",
                incidentID: activeIncidentID
            )
        }

        clearActiveIncident()
    }

    func sendSupportResponse(_ message: String, incidentID: String? = nil) {
        guard let resolvedIncidentID = incidentID ?? latestActiveIncident()?.id else {
            print("No active incident to respond to")
            return
        }

        let event = IncidentEvent(
            type: .supportResponse,
            author: getUserName(),
            message: message
        )
        appendEventToIncident(withID: resolvedIncidentID, event: event)
        database.child("incidentResponses").child(resolvedIncidentID).child(event.id.uuidString).setValue([
            "message": message,
            "author": getUserName(),
            "timestamp": event.timestamp.timeIntervalSince1970
        ])
    }

    func markLatestIncidentResolved(incidentID: String? = nil) {
        guard let resolvedIncidentID = incidentID ?? latestActiveIncident()?.id else {
            print("No active incident to resolve")
            return
        }

        appendEventToIncident(
            withID: resolvedIncidentID,
            event: IncidentEvent(
                type: .supportResponse,
                author: getUserName(),
                message: "Incident marked as resolved."
            )
        ) { record in
            record.status = .resolved
        }
        database.child("incidents").child(resolvedIncidentID).updateChildValues([
            "status": IncidentStatus.resolved.rawValue,
            "updatedAt": Date().timeIntervalSince1970
        ])

        if resolvedIncidentID == activeIncidentID {
            clearActiveIncident()
        }
    }

    // MARK: - Location
    func sendLocation(_ location: CLLocation) {
        let locationDescription = String(
            format: "%.6f, %.6f",
            location.coordinate.latitude,
            location.coordinate.longitude
        )
        let payload: [String: Any] = [
            "lat": location.coordinate.latitude,
            "lon": location.coordinate.longitude,
            "timestamp": Date().timeIntervalSince1970,
            "incidentID": activeIncidentID as Any
        ]

        database.child("liveLocation").childByAutoId().setValue(payload)
        if let activeIncidentID {
            database.child("incidentLocations").child(activeIncidentID).childByAutoId().setValue(payload)
        }

        appendEventToActiveIncident(
            type: .locationUpdate,
            message: "Live location shared with trusted contacts.",
            locationDescription: locationDescription
        ) { incident in
            incident.latestLocationDescription = locationDescription
        }

        print("📍 Location sent to cloud: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }

    // MARK: - Recording Upload
    func uploadRecording(_ fileURL: URL) {
        let fileName = "recording_\(Date().timeIntervalSince1970).m4a"
        let storageRef = storage.child("recordings").child(fileName)

        storageRef.putFile(from: fileURL, metadata: nil) { _, error in
            if let error {
                print("❌ Upload failed: \(error.localizedDescription)")
                return
            }

            print("✅ Recording uploaded successfully")
            storageRef.downloadURL { url, _ in
                guard let url else { return }
                print("📁 Recording URL: \(url)")
                self.saveRecordingReference(fileName, url: url.absoluteString)
            }
        }
    }

    // MARK: - Helpers
    private var activeIncidentID: String? {
        userDefaults.string(forKey: Self.activeIncidentIDKey)
    }

    private func getUserName() -> String {
        UserSessionManager.shared.displayName
    }

    private func currentUserID() -> String {
        UserSessionManager.shared.currentUserID
    }

    private func saveIncidentHistory(_ incidents: [IncidentRecord]) {
        if let encoded = try? JSONEncoder().encode(incidents) {
            userDefaults.set(encoded, forKey: Self.incidentHistoryKey)
        }
    }

    private func clearActiveIncident() {
        userDefaults.removeObject(forKey: Self.activeIncidentIDKey)
    }

    private func createIncident(for contacts: [EmergencyContact]) -> IncidentRecord {
        let now = Date()
        let incident = IncidentRecord(
            id: UUID().uuidString,
            ownerID: currentUserID(),
            ownerName: getUserName(),
            contactNames: contacts.map(\.name),
            contactIDs: contacts.compactMap(\.linkedUserID),
            createdAt: now,
            updatedAt: now,
            status: .active,
            latestLocationDescription: nil,
            recordingURLs: [],
            events: [
                IncidentEvent(
                    type: .emergencyAlert,
                    author: getUserName(),
                    message: "Emergency alert created and shared with \(contacts.count) trusted contact\(contacts.count == 1 ? "" : "s")."
                )
            ]
        )

        var incidents = loadIncidentHistory()
        incidents.removeAll { $0.id == incident.id }
        incidents.insert(incident, at: 0)
        saveIncidentHistory(incidents)
        userDefaults.set(incident.id, forKey: Self.activeIncidentIDKey)

        var incidentPayload: [String: Any] = [
            "ownerName": incident.ownerName,
            "contactNames": incident.contactNames,
            "participantIDs": participantIDMap(for: incident),
            "createdAt": incident.createdAt.timeIntervalSince1970,
            "updatedAt": incident.updatedAt.timeIntervalSince1970,
            "status": incident.status.rawValue
        ]
        if let contactIDs = incident.contactIDs {
            incidentPayload["contactIDs"] = contactIDs
        }
        if let ownerID = incident.ownerID {
            incidentPayload["ownerID"] = ownerID
        }
        database.child("incidents").child(incident.id).setValue(incidentPayload) { [weak self] error, _ in
            if let error {
                print("Incident create failed: \(error.localizedDescription)")
                return
            }
            self?.indexIncidentForParticipants(incident)
        }

        return incident
    }

    private func saveRecordingReference(_ fileName: String, url: String) {
        database.child("recordings").childByAutoId().setValue([
            "fileName": fileName,
            "url": url,
            "timestamp": Date().timeIntervalSince1970,
            "incidentID": activeIncidentID as Any
        ])

        if let activeIncidentID {
            database.child("incidentRecordings").child(activeIncidentID).childByAutoId().setValue([
                "fileName": fileName,
                "url": url,
                "timestamp": Date().timeIntervalSince1970
            ])
        }

        appendEventToActiveIncident(
            type: .recordingUploaded,
            message: "Emergency recording uploaded.",
            recordingURL: url
        ) { incident in
            incident.recordingURLs.append(url)
        }
    }

    private func appendEventToActiveIncident(
        type: IncidentEventType,
        message: String,
        locationDescription: String? = nil,
        recordingURL: String? = nil,
        mutate: ((inout IncidentRecord) -> Void)? = nil
    ) {
        guard let activeIncidentID else { return }
        let event = IncidentEvent(
            type: type,
            author: getUserName(),
            message: message,
            locationDescription: locationDescription,
            recordingURL: recordingURL
        )
        appendEventToIncident(withID: activeIncidentID, event: event, mutate: mutate)
    }

    private func appendEventToIncident(
        withID incidentID: String,
        event: IncidentEvent,
        mutate: ((inout IncidentRecord) -> Void)? = nil
    ) {
        var incidents = loadIncidentHistory()
        guard let index = incidents.firstIndex(where: { $0.id == incidentID }) else {
            appendRemoteEventToIncident(withID: incidentID, event: event)
            return
        }

        incidents[index].events.append(event)
        incidents[index].updatedAt = event.timestamp
        mutate?(&incidents[index])
        saveIncidentHistory(incidents)

        database.child("incidents").child(incidentID).updateChildValues([
            "updatedAt": incidents[index].updatedAt.timeIntervalSince1970,
            "status": incidents[index].status.rawValue,
            "latestLocationDescription": incidents[index].latestLocationDescription as Any,
            "recordingURLs": incidents[index].recordingURLs
        ])

        database.child("incidentEvents").child(incidentID).child(event.id.uuidString).setValue([
            "type": event.type.rawValue,
            "author": event.author,
            "timestamp": event.timestamp.timeIntervalSince1970,
            "message": event.message,
            "locationDescription": event.locationDescription as Any,
            "recordingURL": event.recordingURL as Any
        ])
    }

    private func appendRemoteEventToIncident(withID incidentID: String, event: IncidentEvent) {
        database.child("incidents").child(incidentID).updateChildValues([
            "updatedAt": event.timestamp.timeIntervalSince1970
        ])

        database.child("incidentEvents").child(incidentID).child(event.id.uuidString).setValue([
            "type": event.type.rawValue,
            "author": event.author,
            "timestamp": event.timestamp.timeIntervalSince1970,
            "message": event.message,
            "locationDescription": event.locationDescription as Any,
            "recordingURL": event.recordingURL as Any
        ])
    }

    private func deduplicatedContacts(from contacts: [EmergencyContact]) -> [EmergencyContact] {
        var seenContacts = Set<String>()
        return contacts.compactMap { contact in
            let trimmedName = contact.name.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedPhone = contact.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedLinkedUserID = contact.linkedUserID?.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty, !trimmedPhone.isEmpty else { return nil }

            let normalizedPhone = trimmedPhone
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "-", with: "")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
            let key = normalizedPhone.isEmpty ? trimmedName.lowercased() : normalizedPhone
            guard seenContacts.insert(key).inserted else { return nil }

            return EmergencyContact(
                id: contact.id,
                name: trimmedName,
                phoneNumber: trimmedPhone,
                linkedUserID: trimmedLinkedUserID?.isEmpty == true ? nil : trimmedLinkedUserID
            )
        }
    }

    private func syncConnections(for contacts: [EmergencyContact]) {
        let ownerID = currentUserID()
        guard ownerID != "unknown-user" else { return }

        let linkedContacts = contacts.compactMap { contact -> (EmergencyContact, String)? in
            guard let linkedUserID = contact.linkedUserID?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !linkedUserID.isEmpty else {
                return nil
            }
            return (contact, linkedUserID)
        }

        var ownerConnections: [String: Any] = [:]
        for (contact, linkedUserID) in linkedContacts {
            ownerConnections[linkedUserID] = [
                "name": contact.name,
                "phoneNumber": contact.phoneNumber,
                "linkedUserID": linkedUserID,
                "createdAt": Date().timeIntervalSince1970
            ]

            database.child("connections")
                .child(linkedUserID)
                .child(ownerID)
                .updateChildValues([
                    "name": getUserName(),
                    "linkedUserID": ownerID,
                    "createdAt": Date().timeIntervalSince1970
                ])
        }

        database.child("connections").child(ownerID).setValue(ownerConnections)
    }

    private func participantIDs(for incident: IncidentRecord) -> [String] {
        var ids = incident.contactIDs ?? []
        if let ownerID = incident.ownerID {
            ids.append(ownerID)
        }
        return Array(Set(ids)).filter { !$0.isEmpty && $0 != "unknown-user" }
    }

    private func participantIDMap(for incident: IncidentRecord) -> [String: Bool] {
        Dictionary(uniqueKeysWithValues: participantIDs(for: incident).map { ($0, true) })
    }

    private func indexIncidentForParticipants(_ incident: IncidentRecord) {
        for participantID in participantIDs(for: incident) {
            database.child("userIncidents").child(participantID).child(incident.id).setValue(true)
        }
    }

    private func fetchIncident(withID incidentID: String, completion: @escaping (IncidentRecord?) -> Void) {
        database.child("incidents").child(incidentID).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self,
                  let value = snapshot.value as? [String: Any],
                  let ownerName = value["ownerName"] as? String,
                  let createdAt = value["createdAt"] as? TimeInterval,
                  let updatedAt = value["updatedAt"] as? TimeInterval,
                  let statusValue = value["status"] as? String,
                  let status = IncidentStatus(rawValue: statusValue) else {
                completion(nil)
                return
            }

            let incident = IncidentRecord(
                id: incidentID,
                ownerID: value["ownerID"] as? String,
                ownerName: ownerName,
                contactNames: value["contactNames"] as? [String] ?? [],
                contactIDs: value["contactIDs"] as? [String] ?? [],
                createdAt: Date(timeIntervalSince1970: createdAt),
                updatedAt: Date(timeIntervalSince1970: updatedAt),
                status: status,
                latestLocationDescription: value["latestLocationDescription"] as? String,
                recordingURLs: value["recordingURLs"] as? [String] ?? [],
                events: []
            )
            self.fetchEvents(for: incident) { incidentWithEvents in
                completion(incidentWithEvents)
            }
        }
    }

    private func fetchSharedIncidents(from snapshot: DataSnapshot, completion: @escaping ([IncidentRecord]) -> Void) {
        let incidentIDs = snapshot.children.compactMap { child -> String? in
            (child as? DataSnapshot)?.key
        }

        guard !incidentIDs.isEmpty else {
            completion([])
            return
        }

        var fetched: [IncidentRecord] = []
        let group = DispatchGroup()

        for incidentID in incidentIDs {
            group.enter()
            fetchIncident(withID: incidentID) { incident in
                if let incident {
                    fetched.append(incident)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(fetched.sorted { $0.updatedAt > $1.updatedAt })
        }
    }

    private func fetchEvents(for incident: IncidentRecord, completion: @escaping (IncidentRecord) -> Void) {
        database.child("incidentEvents").child(incident.id).observeSingleEvent(of: .value) { snapshot in
            var events: [IncidentEvent] = []
            for child in snapshot.children {
                guard let eventSnapshot = child as? DataSnapshot,
                      let value = eventSnapshot.value as? [String: Any],
                      let typeValue = value["type"] as? String,
                      let type = IncidentEventType(rawValue: typeValue),
                      let author = value["author"] as? String,
                      let timestamp = value["timestamp"] as? TimeInterval,
                      let message = value["message"] as? String else {
                    continue
                }

                events.append(
                    IncidentEvent(
                        id: UUID(uuidString: eventSnapshot.key) ?? UUID(),
                        type: type,
                        author: author,
                        timestamp: Date(timeIntervalSince1970: timestamp),
                        message: message,
                        locationDescription: value["locationDescription"] as? String,
                        recordingURL: value["recordingURL"] as? String
                    )
                )
            }

            var incident = incident
            incident.events = events.sorted { $0.timestamp < $1.timestamp }
            completion(incident)
        }
    }

    private func sendEmergencyAlert(to contact: EmergencyContact, incidentID: String) {
        let message = """
        🚨 EMERGENCY ALERT 🚨

        \(getUserName()) needs help!
        Time: \(Date())
        """
        writeAlert(
            title: "📱 SENDING EMERGENCY ALERT",
            message: message,
            contact: contact,
            type: "emergency",
            incidentID: incidentID
        )
    }

    private func writeAlert(
        title: String,
        message: String,
        contact: EmergencyContact,
        type: String,
        incidentID: String?
    ) {
        print("""
        ================================
        \(title)
        TO: \(contact.name) (\(contact.phoneNumber))
        MESSAGE: \(message)
        ================================
        """)

        database.child("alerts").childByAutoId().setValue([
            "contactName": contact.name,
            "contactPhone": contact.phoneNumber,
            "message": message,
            "timestamp": Date().timeIntervalSince1970,
            "read": false,
            "type": type,
            "incidentID": incidentID as Any
        ])
    }
}
