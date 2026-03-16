import SwiftUI

struct Scene10: View {
    var onContinue: () -> Void = {}
    @State private var showMain = false
    @State private var showHStack = false

    var body: some View {
        ZStack(alignment: .bottom) {
            PDFKitView(pdfName: "scene10-background")
                .ignoresSafeArea()

            Image("scene10-main")
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
            .opacity(showHStack ? 1 : 0)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showMain = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showHStack = true
                }
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    Scene10()
}
