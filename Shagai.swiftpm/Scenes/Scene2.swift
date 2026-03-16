import SwiftUI

struct Scene2: View {
    var onContinue: () -> Void = {}
    @State private var showContent = false

    @State private var showEnemies = false
    @State private var showHStack = false

    var body: some View {
        ZStack(alignment: .bottom) {
            PDFKitView(pdfName: "scene2-background")
                .ignoresSafeArea()

            Image("scene2-sun")
                .resizable()
                .scaledToFill()
                .clipped()

            Image("scene2-mountain")
                .resizable()
                .scaledToFill()
                .clipped()

            Image("scene2-enemies")
                .resizable()
                .scaledToFill()
                .clipped()
                .opacity(showEnemies ? 1 : 0)

            HStack(alignment: .bottom) {
                Description(
                    title:
                        "But peace didn't last. A cold wind blew from the west, and shadows began to stir.",
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showEnemies = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showHStack = true
                }
                SpeechService.shared.speak(
                    "But peace didn't last. A cold wind blew from the west, and shadows began to stir."
                )
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    Scene2()
}
