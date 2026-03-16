import SwiftUI

struct Scene12: View {
    var onContinue: () -> Void = {}
    @State private var hasLeft = false
    @State private var hasExitedRight = false
    
    @State private var showButton = false

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
                        .offset(x: hasLeft ? -geo.size.width : 0)
                        .animation(.easeOut(duration: 15), value: hasLeft)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                hasLeft = true
                            }
                        }
                    
                    Image("scene9")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 380)
                        .padding(.top, 100)
                        .padding(.trailing, 50)
                        .offset(x: hasExitedRight ? geo.size.width : 0)
                        .animation(.easeOut(duration: 8), value: hasExitedRight)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                hasExitedRight = true
                            }
                        }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .onAppear { hasLeft = true }
                
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showButton = true
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview(traits: .landscapeRight) {
    Scene12()
}
