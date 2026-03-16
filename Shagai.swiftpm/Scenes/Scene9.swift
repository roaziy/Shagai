import SwiftUI

struct Scene9: View {
    var onComplete: () -> Void = {}
    @State private var appeared = false
    @State private var didAdvance = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("clouds")
                    .resizable()
                    .scaledToFill()
                    .clipped()
                
                Image("scene9")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 380)
                    .padding(.top, 100)
                    .padding(.trailing, 50)
                    .offset(x: appeared ? 0 : -geo.size.width)
                    .animation(.easeOut(duration: 3), value: appeared)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear {
                appeared = true
                // Auto-advance after the ride animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    if !didAdvance {
                        didAdvance = true
                        onComplete()
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview(traits: .landscapeRight) {
    Scene9()
}
