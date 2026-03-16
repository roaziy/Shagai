import SwiftUI

struct AltThrowView: View {
    var isStoryMode: Bool = false
    var onResult: (ThrowResult) -> Void
    
    @State private var isHolding = false
    @State private var power: CGFloat = 0.0
    @State private var powerTimer: Timer?
    @State private var powerDirection: CGFloat = 1.0
    
    @State private var hasThrown = false
    @State private var throwResult: ThrowResult?
    @State private var showResult = false
    
    @State private var shagaiLanded = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            HStack(spacing: 0) {
                powerBar
                    .padding(.leading, 32)
                    .padding(.trailing, 16)
                
                VStack {
                    if showResult, let result = throwResult {
                        resultBanner(result)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    shagaiBoard
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    if !hasThrown {
                        throwButton
                            .padding(.bottom, 48)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer().frame(width: 48)
            }
        }
        .onDisappear {
            powerTimer?.invalidate()
        }
    }
    
    private var powerBar: some View {
        VStack(spacing: 4) {
            Text("Power")
                .font(.system(size: 14, weight: .bold, design: .serif))
                .foregroundColor(.white)
            
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 32, height: 220)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(powerColor)
                    .frame(width: 32, height: 220 * power)
                    .animation(.linear(duration: 0.05), value: power)
            }
            
            Text("\(Int(power * 100))%")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .monospacedDigit()
        }
    }
    
    private var powerColor: Color {
        if power < 0.3 { return .red }
        if power < 0.7 { return .yellow }
        return .green
    }
    
    private var shagaiBoard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.35, blue: 0.2),
                            Color(red: 0.45, green: 0.28, blue: 0.15),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 420, height: 260)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.35, green: 0.22, blue: 0.1), lineWidth: 4)
                )
            
            if shagaiLanded, let result = throwResult {
                landedShagai(result)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private func landedShagai(_ result: ThrowResult) -> some View {
        let pieces: [(String, String)] = [
            ("shagai-horse", "Horse"),
            ("shagai-camel", "Camel"),
            ("shagai-sheep", "Sheep"),
            ("shagai-goat", "Goat"),
        ]
        
        let counts = [result.horse, result.camel, result.sheep, result.goat]
        
        let positions: [CGSize] = [
            CGSize(width: -90, height: -50),
            CGSize(width: 70, height: -40),
            CGSize(width: -50, height: 50),
            CGSize(width: 100, height: 60),
        ]
        
        let rotations: [Double] = [-15, 20, -10, 25]
        
        return ZStack {
            ForEach(0..<4, id: \.self) { i in
                VStack(spacing: 2) {
                    Image(pieces[i].0)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 52)
                        .rotationEffect(.degrees(rotations[i]))
                    
                    if counts[i] > 0 {
                        Text("×\(counts[i])")
                            .font(.system(size: 16, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2)
                    }
                }
                .offset(positions[i])
            }
        }
    }
    
    private func resultBanner(_ result: ThrowResult) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Image("continue-button")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 48)
                
                Text("Your throw:")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(.black)
            }
            
            ZStack {
                Image("Story-ScoreStats")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                
                HStack(spacing: 12) {
                    throwResultItem(imageName: "shagai-horse", count: result.horse)
                    throwResultItem(imageName: "shagai-goat", count: result.goat)
                    throwResultItem(imageName: "shagai-sheep", count: result.sheep)
                    throwResultItem(imageName: "shagai-camel", count: result.camel)
                }
            }
        }
        .padding(.top, 16)
    }
    
    private func throwResultItem(imageName: String, count: Int) -> some View {
        HStack(spacing: 4) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 44)
            Text("\(count)")
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundColor(.black)
        }
    }
    
    private var throwButton: some View {
        ZStack {
            Image("continue-button")
                .resizable()
                .scaledToFit()
                .frame(height: 72)
            
            Text(isHolding ? "Release to Throw!" : "Hold the Throw")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(.black)
        }
        .scaleEffect(isHolding ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHolding)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isHolding && !hasThrown {
                        startHolding()
                    }
                }
                .onEnded { _ in
                    if isHolding && !hasThrown {
                        releaseThrow()
                    }
                }
        )
    }
    
    private func startHolding() {
        isHolding = true
        power = 0.0
        powerDirection = 1.0
        
        powerTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            DispatchQueue.main.async {
                power += powerDirection * 0.015
                if power >= 1.0 {
                    power = 1.0
                    powerDirection = -1.0
                } else if power <= 0.0 {
                    power = 0.0
                    powerDirection = 1.0
                }
            }
        }
    }
    
    private func releaseThrow() {
        isHolding = false
        powerTimer?.invalidate()
        powerTimer = nil
        hasThrown = true
        
        let result = generateThrow()
        throwResult = result
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            shagaiLanded = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showResult = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            onResult(result)
        }
    }
    
    private func generateThrow() -> ThrowResult {
        var result = ThrowResult()
        for _ in 0..<4 {
            switch Int.random(in: 0..<4) {
            case 0: result.horse += 1
            case 1: result.camel += 1
            case 2: result.sheep += 1
            default: result.goat += 1
            }
        }
        
        if isStoryMode {
            result = ThrowResult()
            result.horse = 2
            for _ in 2..<4 {
                switch Int.random(in: 0..<4) {
                case 0: result.horse += 1
                case 1: result.camel += 1
                case 2: result.sheep += 1
                default: result.goat += 1
                }
            }
        }
        
        return result
    }
}

#Preview(traits: .landscapeRight) {
    AltThrowView(isStoryMode: false) { result in
        print("Result: H\(result.horse) C\(result.camel) S\(result.sheep) G\(result.goat)")
    }
}
