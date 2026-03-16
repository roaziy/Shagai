import SwiftUI

struct StoryGameMode: View {
    var onGameComplete: () -> Void = {}
    
    private var useAltControls: Bool {
        UserDefaults.standard.bool(forKey: "accessibilityAltControls")
    }
    
    @StateObject private var arViewModel = ARGameViewModel()
    
    @State private var showTutorial = false
    @State private var interactionEnabled = false
    @State private var tutorialPage = 0
    @State private var isFirstTime = true
    
    @State private var showARThrow = false
    @State private var cameraStarted = false
    @State private var throwResultReceived = false
    @State private var throwResultText = ""
    
    @State private var playerPosition = 0
    @State private var enemyPosition = 0
    @State private var isPlayerTurn = true
    @State private var turnLabel = "Your turn!"
    @State private var gameOver = false
    @State private var playerWon = false
    
    @State private var botHorse = 0
    @State private var botGoat = 0
    @State private var botSheep = 0
    @State private var botCamel = 0
    
    private let trackLength = 8
    
    var body: some View {
        ZStack {
            if !useAltControls && cameraStarted {
                ARGameView(viewModel: arViewModel)
                    .ignoresSafeArea()
                    .opacity(showARThrow ? 1 : 0)
                    .allowsHitTesting(showARThrow)
            }
            
            if showARThrow {
                if useAltControls {
                    AltThrowView(isStoryMode: true) { result in
                        showARThrow = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            handlePlayerThrow(result)
                        }
                    }
                } else {
                    throwOverlay
                }
            } else {
                gameUI
            }
        }
        .onAppear {
            arViewModel.isStoryMode = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                showTutorial = true
            }
        }
        .onChange(of: arViewModel.lastThrowResult) { _, result in
            guard let result = result, !throwResultReceived else { return }
            throwResultReceived = true
            throwResultText =
            "Horse: \(result.horse)  Camel: \(result.camel)  Sheep: \(result.sheep)  Goat: \(result.goat)"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showARThrow = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    handlePlayerThrow(result)
                }
            }
        }
        .sheet(
            isPresented: $showTutorial,
            onDismiss: {
                SpeechService.shared.stop()
                if !useAltControls && !cameraStarted {
                    cameraStarted = true
                }
                if !interactionEnabled {
                    interactionEnabled = true
                    isFirstTime = false
                }
                if isPlayerTurn && !gameOver && !showARThrow {
                    startPlayerTurn()
                }
            }
        ) {
            TutorialSheetContent(
                currentPage: $tutorialPage,
                totalPages: 7,
                isPresented: $showTutorial,
                isFirstTime: isFirstTime
            )
            .presentationDetents([.large])
            .presentationDragIndicator(isFirstTime ? .hidden : .visible)
            .interactiveDismissDisabled(isFirstTime)
        }
    }
    
    private var throwOverlay: some View {
        VStack {
            if throwResultReceived {
                HStack {
                    Spacer()
                    Button {
                        showARThrow = false
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 44, height: 44)
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(throwStatusLabel)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(throwStatusColor)
                        .shadow(color: .black, radius: 2)
                    
                    if !throwResultText.isEmpty {
                        Text(throwResultText)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2)
                    }
                }
                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .padding()
        }
    }
    
    private var throwStatusLabel: String {
        switch arViewModel.gameState {
        case .searching: return "Show your hand..."
        case .holding: return "Holding — open to throw!"
        case .throwing: return "Thrown! Waiting..."
        case .result: return "Result!"
        }
    }
    
    private var throwStatusColor: Color {
        switch arViewModel.gameState {
        case .searching: return .yellow
        case .holding: return .orange
        case .throwing: return .green
        case .result: return .cyan
        }
    }
    
    private var gameUI: some View {
        VStack {
            HStack {
                Spacer()
                TutorialButton {
                    tutorialPage = 0
                    showTutorial = true
                }
                .disabled(!interactionEnabled)
                .opacity(interactionEnabled ? 1 : 0.5)
            }
            .padding(.horizontal, 32)
            
            ZStack {
                Image("continue-button")
                    .resizable()
                    .scaledToFit()
                    .frame(height: gameOver ? 120 : 48)
                
                Text(turnLabel)
                    .font(.system(size: gameOver ? 32 : 20, weight: .bold, design: .serif))
                    .foregroundColor(.black)
            }
            .disabled(!interactionEnabled)
            .opacity(interactionEnabled ? 1 : 0.5)
            .padding(.top, 90)
            .padding(.bottom, 36)
            
            ShagaiPlayground(
                round: trackLength,
                playerPosition: playerPosition,
                enemyPosition: enemyPosition
            )
            .disabled(!interactionEnabled)
            .opacity(interactionEnabled ? 1 : 0.5)
            
            Spacer()
            
            HStack {
                ShagaiPlaygroundScore(
                    playerPosition: playerPosition,
                    enemyPosition: enemyPosition,
                    trackLength: trackLength
                )
                ShagaiPlaygroundEnemyThrow(
                    horse: botHorse,
                    goat: botGoat,
                    sheep: botSheep,
                    camel: botCamel
                )
            }
            .disabled(!interactionEnabled)
            .opacity(interactionEnabled ? 1 : 0.5)
            
            if gameOver && playerWon {
                CustomButton(
                    title: "Continue Story",
                    icon: "arrow.right",
                    action: { onGameComplete() }
                )
                .padding(.bottom, 8)
            }
            
            if gameOver && !playerWon {
                CustomButton(
                    title: "Try Again",
                    icon: "arrow.counterclockwise",
                    action: { resetGame() }
                )
                .padding(.bottom, 8)
            }
        }
        .padding(.vertical, 36)
    }
    
    private func startPlayerTurn() {
        isPlayerTurn = true
        turnLabel = "Your turn!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard !gameOver, !showTutorial else { return }
            
            if useAltControls {
                throwResultReceived = false
                throwResultText = ""
                showARThrow = true
            } else {
                arViewModel.resetForNextThrow()
                throwResultReceived = false
                throwResultText = ""
                showARThrow = true
            }
        }
    }
    
    private func handlePlayerThrow(_ result: ThrowResult) {
        stepPlayer(remaining: result.horse)
    }
    
    private func stepPlayer(remaining: Int) {
        if remaining > 0 && playerPosition < trackLength - 1 {
            withAnimation(.easeInOut(duration: 0.4)) {
                playerPosition += 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.stepPlayer(remaining: remaining - 1)
            }
        } else {
            if playerPosition >= trackLength - 1 {
                gameOver = true
                playerWon = true
                turnLabel = "Warrior & Queen escaped!"
                return
            }
            
            isPlayerTurn = false
            turnLabel = "Enemy turn..."
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                let botResult = generateBotThrow()
                botHorse = botResult.horse
                botGoat = botResult.goat
                botSheep = botResult.sheep
                botCamel = botResult.camel
                
                self.stepEnemy(remaining: botResult.horse)
            }
        }
    }
    
    private func stepEnemy(remaining: Int) {
        if remaining > 0 && enemyPosition < trackLength - 1 {
            withAnimation(.easeInOut(duration: 0.4)) {
                enemyPosition += 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.stepEnemy(remaining: remaining - 1)
            }
        } else {
            if enemyPosition >= trackLength - 1 {
                gameOver = true
                playerWon = false
                turnLabel = "Enemy captured you!"
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                startPlayerTurn()
            }
        }
    }
    
    private func resetGame() {
        withAnimation(.easeInOut(duration: 0.4)) {
            playerPosition = 0
            enemyPosition = 0
        }
        botHorse = 0
        botGoat = 0
        botSheep = 0
        botCamel = 0
        gameOver = false
        playerWon = false
        isPlayerTurn = true
        turnLabel = "Your turn!"
        startPlayerTurn()
    }
    
    private func generateBotThrow() -> ThrowResult {
        var result = ThrowResult()
        for _ in 0..<4 {
            switch Int.random(in: 0..<4) {
            case 0: result.horse += 1
            case 1: result.camel += 1
            case 2: result.sheep += 1
            default: result.goat += 1
            }
        }
        if result.horse > 1 {
            let excess = result.horse - 1
            result.horse = 1
            for _ in 0..<excess {
                switch Int.random(in: 0..<3) {
                case 0: result.camel += 1
                case 1: result.sheep += 1
                default: result.goat += 1
                }
            }
        }
        return result
    }
}

struct EnemyThrowItem: View {
    let imageName: String
    let count: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 58)
            Text(count)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(.black)
        }
    }
}

struct TutorialButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.74, blue: 0.26))
                    .frame(width: 54, height: 54)
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 3)
                    )
                
                Image(systemName: "questionmark")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
            }
        }
    }
}

struct ShagaiPlayground: View {
    var round: Int
    var playerPosition: Int = 0
    var enemyPosition: Int = 0
    @State private var cellWidth: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image("golden-shagai")
                .resizable()
                .scaledToFit()
                .frame(height: 56)
                .offset(x: CGFloat(min(playerPosition, max(round - 1, 0))) * cellWidth)
                .animation(.easeInOut(duration: 0.6), value: playerPosition)
            
            HStack(spacing: 0) {
                ForEach(0..<round, id: \.self) { _ in
                    Image("shagai-horse")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 72)
                }
            }
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear {
                        cellWidth = geo.size.width / CGFloat(max(round, 1))
                    }
                }
            )
            
            Image("enemy-shagai")
                .resizable()
                .scaledToFit()
                .frame(height: 56)
                .offset(x: CGFloat(min(enemyPosition, max(round - 1, 0))) * cellWidth)
                .animation(.easeInOut(duration: 0.6), value: enemyPosition)
        }
    }
}

struct ShagaiPlaygroundScore: View {
    var playerPosition: Int = 1
    var enemyPosition: Int = 1
    var trackLength: Int = 8
    
    var body: some View {
        VStack {
            ZStack {
                Image("continue-button")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 48)
                
                Text("Score:")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(.black)
            }
            ZStack {
                Image("Story-ScoreStats")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 128)
                
                HStack {
                    HStack {
                        Image("golden-shagai")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 58)
                        Text("\(playerPosition + 1)/\(trackLength)")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(.black)
                    }
                    HStack {
                        Image("enemy-shagai")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 58)
                        Text("\(enemyPosition + 1)/\(trackLength)")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

struct ShagaiPlaygroundEnemyThrow: View {
    var horse: Int = 0
    var goat: Int = 0
    var sheep: Int = 0
    var camel: Int = 0
    
    var body: some View {
        VStack {
            ZStack {
                Image("continue-button")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 48)
                
                Text("Enemy throw:")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(.black)
            }
            ZStack {
                Image("Story-ScoreStats")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 128)
                
                HStack {
                    EnemyThrowItem(imageName: "shagai-horse", count: "\(horse)")
                    EnemyThrowItem(imageName: "shagai-goat", count: "\(goat)")
                    EnemyThrowItem(imageName: "shagai-sheep", count: "\(sheep)")
                    EnemyThrowItem(imageName: "shagai-camel", count: "\(camel)")
                }
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    StoryGameMode()
}
