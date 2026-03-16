import SwiftUI

struct Scene4: View {
    var onContinue: () -> Void = {}
    @State private var showKhan = false
    @State private var showButton = false

    var body: some View {
        ZStack(alignment: .bottom) {
            PDFKitView(pdfName: "scene4-background")
                .ignoresSafeArea()

            Image("scene4-khan")
                .resizable()
                .scaledToFill()
                .clipped()
                .opacity(showKhan ? 1 : 0)

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
            .opacity(showButton ? 1 : 0)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showKhan = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showButton = true
                }
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    Scene4()
}
