import SwiftUI

struct Scene5Part1: View {
    var onContinue: () -> Void = {}
    @State private var showContent = false

    var body: some View {
        ZStack(alignment: .bottom) {
            PDFKitView(pdfName: "scene5-part1")
                .ignoresSafeArea()

            HStack(alignment: .bottom) {
                Description(
                    title:
                        "The Khan called for his bravest warriors: \"My Queen is gone! Who will rescue her?\"",
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
                        onContinue()
                    }
                )
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
            .opacity(showContent ? 1 : 0)
        }
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showContent = true
                }
                SpeechService.shared.speak(
                    "The Khan called for his bravest warriors: My Queen is gone! Who will rescue her?"
                )
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    Scene5Part1()
}
