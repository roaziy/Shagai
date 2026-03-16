import SwiftUI

struct Scene7: View {
    var onContinue: () -> Void = {}
    @State private var showContent = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Image("clouds")
                .resizable()
                .scaledToFill()
                .clipped()

            // scene7 image and hstack fade-in after 2 seconds
            Image("scene7")
                .resizable()
                .scaledToFill()
                .clipped()
                .opacity(showContent ? 1 : 0)

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
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showContent = true
                }
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    Scene7()
}
