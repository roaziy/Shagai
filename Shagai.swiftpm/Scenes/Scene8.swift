import SwiftUI

struct Scene8: View {
    var onContinue: () -> Void = {}
    @State private var showHStack = false
    @State private var fadeOutContent = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                PDFKitView(pdfName: "scene8-background")
                    .ignoresSafeArea()

                // scene8-main fades out when Continue pressed
                Image("scene8-main")
                    .resizable()
                    .scaledToFit()
                    .padding(.top, 100)
                    .frame(height: 550)
                    .opacity(fadeOutContent ? 0 : 1)
            }

            // HStack fades in after 2 seconds, fades out when Continue pressed
            HStack(alignment: .bottom) {
                Description(
                    title:
                        "Deep in enemy territory, the Warrior found the Queen. \"The Khan awaits — let's go,\" he whispered.",
                    buttonSize: 140,
                    textSize: 20
                )
                .fixedSize()

                Spacer()

                CustomButton(
                    title: "Continue",
                    icon: "arrow.right",
                    action: {
                        SpeechService.shared.stop()
                        // Fade out Description and scene8-main over 2 seconds, then advance
                        withAnimation(.easeInOut(duration: 2)) {
                            fadeOutContent = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                            onContinue()
                        }
                    }
                )
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
            .opacity(showHStack && !fadeOutContent ? 1 : 0)
        }
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showHStack = true
                }
                SpeechService.shared.speak(
                    "Deep in enemy territory, the Warrior found the Queen. The Khan awaits, let's go, he whispered."
                )
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    Scene8()
}
