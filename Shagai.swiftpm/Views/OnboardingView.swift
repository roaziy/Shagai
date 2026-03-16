import AVFoundation
import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var cameraPermissionDenied = false

    #if DEBUG
        @State private var currentPage: Int
        init(hasCompletedOnboarding: Binding<Bool>, startPage: Int = 0) {
            self._hasCompletedOnboarding = hasCompletedOnboarding
            self._currentPage = State(initialValue: startPage)
        }
    #else
        @State private var currentPage = 0
    #endif

    private let totalPages = 5

    var body: some View {
        ZStack {
            SteppePDF(pdfName: "steppe")

            ZStack {
                Image("menu")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 450)

                VStack(spacing: 0) {
                    // Golden shagai icon
                    Image("golden-shagai")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 55)
                        .padding(.top, 16)

                    // Page content (switches in place)
                    Group {
                        switch currentPage {
                        case 0: welcomePage
                        case 1: beforeJourneyPage
                        case 2: permissionPage
                        case 3: customizePage
                        case 4: readyPage
                        default: EmptyView()
                        }
                    }
                    .animation(.easeInOut(duration: 0.25), value: currentPage)
                }
                .frame(width: 380, height: 420)
            }
            
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(
                                index == currentPage
                                    ? Color.black.opacity(0.8) : Color.black.opacity(0.3)
                            )
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 162)
            }
        }
        .ignoresSafeArea()
    }

    private var welcomePage: some View {
        VStack {
            VStack(spacing: 4) {
                Text("Welcome to")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.black)
                    .padding(.top, 28)

                Divider()
                    .frame(width: 200)
                    .background(Color.black)
                    .padding(.vertical, 12)

                Text("Shagai: Adventure\nof The Warrior")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .italic()
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 4)

            Spacer()

            CustomButton(title: "Continue", textSize: 20) {
                withAnimation { currentPage = 1 }
            }
            .padding(.bottom, 4)
        }
    }

    private var beforeJourneyPage: some View {
        VStack {
            VStack(spacing: 4) {
                Text("Before the journey begins\u{2026}")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.black)
                    .padding(.top, 28)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 4)

            Spacer()

            Text(
                "To bring the ancient game of Shagai to life, this experience uses ARKit and Vision to track your hand movements in real-time."
            )
            .font(.system(size: 18, weight: .regular, design: .serif))
            .foregroundColor(.black)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 50)

            Spacer()

            CustomButton(title: "Continue", textSize: 20) {
                withAnimation { currentPage = 2 }
            }
            .padding(.bottom, 4)
        }
    }

    private var permissionPage: some View {
        VStack {
            Color.clear
                .frame(width: 0, height: 0)
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: UIApplication.willEnterForegroundNotification)
                ) { _ in
                    if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                        withAnimation {
                            cameraPermissionDenied = false
                            currentPage = 3
                        }
                    }
                }

            VStack(spacing: 4) {
                Text("Permission")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.black)
                    .padding(.top, 28)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 4)

            Spacer()

            if cameraPermissionDenied {
                Text(
                    "Camera access is required for hand tracking. Please enable it in Settings to continue."
                )
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundColor(.red.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
            } else {
                Text(
                    "Your privacy is a priority. Camera data is processed locally on your device for gesture recognition; no video or images are recorded or stored."
                )
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 50)
            }

            Spacer()

            if cameraPermissionDenied {
                CustomButton(title: "Open Settings", textSize: 18) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .padding(.bottom, 4)
            } else {
                CustomButton(title: "Enable Hand Tracking", textSize: 18) {
                    requestCameraPermission()
                }
                .padding(.bottom, 4)
            }
        }
    }

    private var customizePage: some View {
        AccessibilityView(
            buttonTitle: "Continue",
            onDismiss: {
                withAnimation { currentPage = 4 }
            })
    }

    // MARK: - Page 5: Ready

    private var readyPage: some View {
        VStack {
            VStack(spacing: 4) {
                // To keep the layout identical to Page 1, we split the text
                Text("You're Ready, Warrior!")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.black)
                    .padding(.top, 28)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 4)

            Spacer()

            Text("Your journey awaits. May the shagai land in your favor.")
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)

            Spacer()

            CustomButton(title: "Begin", textSize: 20) {
                withAnimation {
                    hasCompletedOnboarding = true
                }
            }
            .padding(.bottom, 4)
        }
    }

    private func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            withAnimation { currentPage = 3 }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        withAnimation { currentPage = 3 }
                    } else {
                        withAnimation { cameraPermissionDenied = true }
                    }
                }
            }
        case .denied, .restricted:
            withAnimation { cameraPermissionDenied = true }
        @unknown default:
            withAnimation { currentPage = 3 }
        }
    }
}

#Preview("Page 1 – Welcome", traits: .landscapeRight) {
    @Previewable @State var completed = false
    OnboardingView(hasCompletedOnboarding: $completed, startPage: 0)
}

#Preview("Page 2 – Before Journey", traits: .landscapeRight) {
    @Previewable @State var completed = false
    OnboardingView(hasCompletedOnboarding: $completed, startPage: 1)
}

#Preview("Page 3 – Permission", traits: .landscapeRight) {
    @Previewable @State var completed = false
    OnboardingView(hasCompletedOnboarding: $completed, startPage: 2)
}

#Preview("Page 4 – Customize", traits: .landscapeRight) {
    @Previewable @State var completed = false
    OnboardingView(hasCompletedOnboarding: $completed, startPage: 3)
}

#Preview("Page 5 – Ready", traits: .landscapeRight) {
    @Previewable @State var completed = false
    OnboardingView(hasCompletedOnboarding: $completed, startPage: 4)
}
