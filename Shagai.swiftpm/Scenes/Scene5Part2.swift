import SwiftUI

struct Scene5Part2: View {
    var onContinue: () -> Void = {}
    @State private var showContent = false

    var body: some View {
        ZStack(alignment: .bottom) {
            PDFKitView(pdfName: "scene5-part2")
                .ignoresSafeArea()

            Image("scene5-part2-shadow")
                .resizable()
                .scaledToFill()
                .clipped()
                .opacity(showContent ? 1 : 0)

            HStack(alignment: .bottom) {
                Description(
                    title:
                        "While others hesitated, one Warrior stepped forward, ready to ride.",
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
                    "While others hesitated, one Warrior stepped forward, ready to ride."
                )
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    Scene5Part2()
}
