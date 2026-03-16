import SwiftUI

struct AccessibilityView: View {
    @ObservedObject private var settings = AccessibilitySettings.shared
    
    var buttonTitle: String = "Back to Menu"
    var onDismiss: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Accessibility")
                .font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 24)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("VoiceOver Support")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    Spacer()
                    Toggle("", isOn: $settings.voiceOverEnabled)
                        .labelsHidden()
                        .tint(.green)
                }
                
                Text("Enable spoken descriptions for story panels to experience the narrative through audio.")
                    .font(.system(size: 13))
                    .foregroundColor(.black.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 24)
            .padding(.horizontal, 44)
            
            Divider()
                .padding(.horizontal, 44)
                .padding(.vertical, 14)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Alternative Controls")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    Spacer()
                    Toggle("", isOn: $settings.altControlsEnabled)
                        .labelsHidden()
                        .tint(.green)
                }
                
                Text("Play the entire journey using a keyboard or mouse. This is a vital option for those who prefer not to use hand-tracking features.")
                    .font(.system(size: 13))
                    .foregroundColor(.black.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 44)
            
            Spacer()
            
            CustomButton(
                title: buttonTitle,
                imageName: "continue-button",
                buttonSize: 68,
                textSize: 22
            ) {
                onDismiss()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 44)
            .padding(.top, 18)
        }
    }
}
