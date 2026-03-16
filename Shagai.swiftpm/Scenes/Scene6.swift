import SwiftUI

struct Scene6: View {
    var onContinue: () -> Void = {}
    @State private var progress: [CGFloat] = [0, 0, 0, 0]
    @State private var showHStack = false

    // (image, final X from center, final Y from center, delay)
    private let shagais: [(String, CGFloat, CGFloat, Double)] = [
        ("shine-shagai-horse", -20, -65, 0.0),
        ("shine-shagai-goat", 30, 20, 0.2),
        ("shine-shagai-sheep", -65, 45, 0.4),
        ("shine-shagai-camel", -5, 125, 0.6),
    ]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            // Top hand is roughly at -30% of height from center
            let startX: CGFloat = w * 0.02
            let startY: CGFloat = -h * 0.23

            ZStack(alignment: .bottom) {
                ZStack {
                    PDFKitView(pdfName: "scene6-background")
                        .ignoresSafeArea()

                    ForEach(shagais.indices, id: \.self) { i in
                        let (name, endX, endY, _) = shagais[i]
                        let t = progress[i]

                        Image(name)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 138)
                            .offset(
                                x: startX + (endX - startX) * t,
                                y: startY + (endY - startY) * t
                            )
                            .opacity(Double(t == 0 ? 0 : 1))
                    }
                }
                .frame(width: w, height: h)
                .onAppear {
                    for i in shagais.indices {
                        let delay = shagais[i].3
                        withAnimation(.easeOut(duration: 0.8).delay(delay)) {
                            progress[i] = 1
                        }
                    }
                    // HStack fades in after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            showHStack = true
                        }
                        SpeechService.shared.speak(
                            "The Khan gave him the Sky Shagais — ancestral bones that make a horse gallop faster than an arrow."
                        )
                    }
                }

                HStack(alignment: .bottom) {
                    Description(
                        title:
                            "The Khan handed him the \"Sky Shagais\". \"These are a treasure imbued with the spirit of ancestors. If you cast it, your steed will gallop faster than an arrow.\"",
                        buttonSize: 150,
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
        }
        .ignoresSafeArea()
    }
}

#Preview(traits: .landscapeRight) {
    Scene6()
}
