import SwiftUI

struct Scene1: View {
    var onContinue: () -> Void = {}
    @State private var showContent = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Image("clouds")
                .resizable()
                .scaledToFill()
                .clipped()
            Image("scene1-village")
                .resizable()
                .scaledToFit()
                .clipped()

            Image("scene1-main")
                .resizable()
                .scaledToFill()
                .clipped()
                .opacity(showContent ? 1 : 0)

            HStack(alignment: .bottom) {
                Description(
                    title:
                        "Long ago, a Khan and Queen ruled a peaceful kingdom on the steppe.",
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showContent = true
                }
                SpeechService.shared.speak(
                    "Long ago, a Khan and Queen ruled a peaceful kingdom on the steppe."
                )
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    Scene1()
}
