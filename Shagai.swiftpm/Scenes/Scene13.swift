import SwiftUI

struct Scene13: View {
    var onStoryComplete: () -> Void = {}
    @State private var showLore = false
    @State private var lorePage = 0
    @State private var showHStack = false

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
            Image("scene12")
                .resizable()
                .scaledToFill()
                .clipped()

            HStack(alignment: .bottom) {
                Description(
                    title:
                        "They returned safely. The Khan and Queen reunited, and the Warrior's legend lived on forever.",
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
                        lorePage = 0
                        showLore = true
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
                    showHStack = true
                }
                SpeechService.shared.speak(
                    "They returned safely. The Khan and Queen reunited, and the Warrior's legend lived on forever."
                )
            }
        }
        .sheet(
            isPresented: $showLore,
            onDismiss: {
                SpeechService.shared.stop()
                onStoryComplete()
            }
        ) {
            LoreSheetContent(
                currentPage: $lorePage,
                totalPages: 1,
                isPresented: $showLore
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview(traits: .landscapeRight) {
    Scene13()
}
