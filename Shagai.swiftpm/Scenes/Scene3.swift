import SwiftUI

struct Scene3: View {
    var onContinue: () -> Void = {}

    @State private var showEnemies = false
    @State private var showPart1 = true
    @State private var showPart2 = false
    @State private var showMain = false

    var body: some View {
        ZStack(alignment: .bottom) {
            PDFKitView(pdfName: "scene3-background")
                .ignoresSafeArea()

            ZStack {
                Image("scene3-ger1")
                    .resizable()
                    .scaledToFill()
                    .clipped()

                Image("scene3-enemies")
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .opacity(showEnemies ? 1 : 0)
            }
            .opacity(showPart1 ? 1 : 0)
            
            Image("scene3-ger2")
                .resizable()
                .scaledToFill()
                .clipped()
                .opacity(showPart2 ? 1 : 0)

            Image("scene3-main")
                .resizable()
                .scaledToFill()
                .clipped()
                .opacity(showMain ? 1 : 0)

            HStack(alignment: .bottom) {
                Spacer()
                CustomButton(
                    title: "Continue",
                    icon: "arrow.right",
                    action: {
                        onContinue()
                    }
                )
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
            .opacity(showMain ? 1 : 0)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showEnemies = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 1.2)) {
                    showPart1 = false
                    showPart2 = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showMain = true
                }
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    Scene3()
}
