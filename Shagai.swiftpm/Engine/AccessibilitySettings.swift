import SwiftUI

final class AccessibilitySettings: ObservableObject {
    static let shared = AccessibilitySettings()

    @AppStorage("accessibilityVoiceOver") var voiceOverEnabled: Bool = false
    @AppStorage("accessibilityAltControls") var altControlsEnabled: Bool = false

    private init() {}
}
