import AppIntents

struct TriggerSOSIntent: AppIntent {
    static var title: LocalizedStringResource = "Trigger SOS"
    static var description = IntentDescription("Activates SafeTap emergency mode, starts recording, and sends the emergency alert.")
    static var openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let activated = SOSManager.shared.activateSOS()
        let dialog = activated
            ? IntentDialog("SOS activated.")
            : IntentDialog("SOS is already active.")
        return .result(dialog: dialog)
    }
}

struct SafeTapAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: TriggerSOSIntent(),
            phrases: [
                "Trigger SOS in \(.applicationName)",
                "Start emergency mode in \(.applicationName)"
            ],
            shortTitle: "Trigger SOS",
            systemImageName: "sos"
        )
    }

    static var shortcutTileColor: ShortcutTileColor = .red
}
