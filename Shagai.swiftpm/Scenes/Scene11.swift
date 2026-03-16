import SwiftUI

struct Scene11: View {
    var onContinue: () -> Void = {}
    @State private var appeared = false

    @State private var showHStack = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                ZStack {
                    Image("clouds")
                        .resizable()
                        .scaledToFill()
                        .clipped()

                    Image("scene11")
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .offset(x: appeared ? 0 : -geo.size.width)
                        .animation(.easeOut(duration: 4), value: appeared)

                    Image("scene9")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 380)
                        .padding(.top, 100)
                        .padding(.trailing, 50)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .onAppear { appeared = true }

                HStack(alignment: .bottom) {
                    Description(
                        title:
                            "They raced toward home — but enemies came screaming in pursuit behind them.",
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showHStack = true
                    }
                    SpeechService.shared.speak(
                        "They raced toward home — but enemies came screaming in pursuit behind them."
                    )
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview(traits: .landscapeRight) {
    Scene11()
}
