import Foundation
import Combine
import FirebaseAuth
import FirebaseDatabase

struct AppUserProfile: Codable, Equatable {
    var userID: String
    var displayName: String
    var createdAt: Date
}

@MainActor
final class UserSessionManager: ObservableObject {
    static let shared = UserSessionManager()

    @Published private(set) var profile: AppUserProfile?
    @Published private(set) var isLoading = false
    @Published private(set) var authError: String?

    private static let databaseURL = "https://safetap-2b38b-default-rtdb.asia-southeast1.firebasedatabase.app/"
    private static let profileKey = "appUserProfile"

    private let database = Database.database(url: databaseURL).reference()
    private let userDefaults = UserDefaults.standard
    private var hasConfigured = false

    private init() {
        loadCachedProfile()
    }

    var requiresProfileSetup: Bool {
        guard let profile else { return true }
        return profile.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var displayName: String {
        let trimmed = profile?.displayName.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "SafeTap User" : trimmed
    }

    var currentUserID: String {
        profile?.userID ?? "unknown-user"
    }

    func configureIfNeeded() {
        guard !hasConfigured else { return }
        hasConfigured = true
        isLoading = true

        let completeSignIn: (User?) -> Void = { [weak self] user in
            let resolvedID = user?.uid ?? UUID().uuidString
            Task { @MainActor [weak self] in
                guard let self else { return }
                let cachedName = self.profile?.displayName ?? ""
                self.profile = AppUserProfile(
                    userID: resolvedID,
                    displayName: cachedName,
                    createdAt: self.profile?.createdAt ?? Date()
                )
                self.persistProfile()
                self.syncProfileToDatabase()
                self.isLoading = false
            }
        }

        if let currentUser = Auth.auth().currentUser {
            completeSignIn(currentUser)
            return
        }

        Auth.auth().signInAnonymously { [weak self] result, error in
            if let error {
                Task { @MainActor [weak self] in
                    self?.authError = error.localizedDescription
                    self?.isLoading = false
                }
                return
            }

            completeSignIn(result?.user)
        }
    }

    func updateDisplayName(_ displayName: String) {
        guard var profile else { return }
        profile.displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.profile = profile
        persistProfile()
        syncProfileToDatabase()
    }

    private func loadCachedProfile() {
        guard let data = userDefaults.data(forKey: Self.profileKey),
              let profile = try? JSONDecoder().decode(AppUserProfile.self, from: data) else {
            return
        }

        self.profile = profile
    }

    private func persistProfile() {
        guard let profile, let data = try? JSONEncoder().encode(profile) else { return }
        userDefaults.set(data, forKey: Self.profileKey)
    }

    private func syncProfileToDatabase() {
        guard let profile else { return }
        database.child("users").child(profile.userID).setValue([
            "displayName": profile.displayName,
            "createdAt": profile.createdAt.timeIntervalSince1970,
            "updatedAt": Date().timeIntervalSince1970
        ])
    }
}
