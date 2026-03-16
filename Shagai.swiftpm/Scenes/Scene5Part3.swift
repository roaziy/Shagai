import SwiftUI

struct Scene5Part3: View {
    var onContinue: () -> Void = {}
    @State private var showImage = false
    @State private var showHStack = false

    var body: some View {
        ZStack(alignment: .bottom) {
            PDFKitView(pdfName: "scene5-part3")
                .ignoresSafeArea()

            Image("scene5-part3-main")
                .resizable()
                .scaledToFill()
                .clipped()
                .opacity(showImage ? 1 : 0)

            HStack(alignment: .bottom) {
                Description(
                    title:
                        "The Warrior knelt and vowed: \"I will not stop until the Queen is safe.\"",
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
            .opacity(showHStack ? 1 : 0)
        }
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showImage = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showHStack = true
                }
                SpeechService.shared.speak(
                    "The Warrior knelt and vowed: I will not stop until the Queen is safe."
                )
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    Scene5Part3()
}
