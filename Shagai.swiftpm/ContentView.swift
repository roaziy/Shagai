import SwiftUI

enum GamePhase {
    case mainMenu
    case scene1, scene2, scene3, scene4
    case scene5part1, scene5part2, scene5part3
    case scene6
    case scene7
    case scene8, scene9, scene10, scene11
    case storyGameMode
    case scene12, scene13
    case endlessGameMode
}

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasCompletedStory") private var hasCompletedStory = false
    
    @State private var phase: GamePhase = .mainMenu
    @State private var steppeAlignTop = false
    @State private var contentOpacity: Double = 1.0
    @State private var showSteppe: Bool = true
    
    private static func needsSteppe(_ phase: GamePhase) -> Bool {
        switch phase {
        case .mainMenu, .scene1, .scene7, .scene9, .scene11,
                .storyGameMode, .scene12, .scene13, .endlessGameMode:
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isPortrait = geometry.size.height > geometry.size.width
            
            ZStack {
                if !hasCompletedOnboarding {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                } else {
                    if showSteppe {
                        SteppePDF(pdfName: "steppe", alignment: steppeAlignTop ? .top : .bottom)
                            .transition(.opacity)
                    }
                    
                    contentForPhase()
                        .id(phase)
                        .transition(.opacity)
                        .opacity(contentOpacity)
                        .disabled(isPortrait)
                }
                
                if isPortrait {
                    ZStack {
                        Color.black.opacity(0.9)
                            .ignoresSafeArea()
                        VStack(spacing: 18) {
                            Image(systemName: "ipad.landscape")
                                .font(.system(size: 150))
                                .foregroundColor(.white)
                            Text("Please rotate your iPad to landscape mode\u{2026}")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(true)
                }
            }
            .disabled(isPortrait)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func contentForPhase() -> some View {
        switch phase {
        case .mainMenu:
            HStack {
                MainMenu(
                    Endless: hasCompletedStory,
                    onStoryMode: { startStoryMode() },
                    onEndlessMode: { startEndlessMode() }
                )
                Spacer()
                Image("menu-warrior")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 230)
            }
            .padding(.leading, 80)
            .padding(.trailing, 100)
            
        case .scene1:
            Scene1(onContinue: { transitionTo(.scene2) })
        case .scene2:
            Scene2(onContinue: { transitionTo(.scene3) })
        case .scene3:
            Scene3(onContinue: { transitionTo(.scene4) })
        case .scene4:
            Scene4(onContinue: { transitionTo(.scene5part1) })
        case .scene5part1:
            Scene5Part1(onContinue: { transitionTo(.scene5part2) })
        case .scene5part2:
            Scene5Part2(onContinue: { transitionTo(.scene5part3) })
        case .scene5part3:
            Scene5Part3(onContinue: { transitionTo(.scene6) })
        case .scene6:
            Scene6(onContinue: { transitionTo(.scene7) })
        case .scene7:
            Scene7(onContinue: { transitionTo(.scene8) })
        case .scene8:
            Scene8(onContinue: { transitionTo(.scene9) })
        case .scene9:
            Scene9(onComplete: { transitionTo(.scene10) })
        case .scene10:
            Scene10(onContinue: { transitionTo(.scene11) })
        case .scene11:
            Scene11(onContinue: { transitionToGame() })
        case .storyGameMode:
            StoryGameMode(onGameComplete: { transitionFromGame() })
        case .scene12:
            Scene12(onContinue: { transitionTo(.scene13) })
        case .scene13:
            Scene13(onStoryComplete: { completeStory() })
        case .endlessGameMode:
            EndlessGameMode(onExit: { exitEndless() })
        }
    }
    
    private func transitionTo(_ newPhase: GamePhase) {
        withAnimation(.easeInOut(duration: 0.45)) {
            phase = newPhase
            showSteppe = Self.needsSteppe(newPhase)
        }
    }
    
    private func transitionWithSteppe(to newPhase: GamePhase, alignTop: Bool) {
        withAnimation(.easeInOut(duration: 0.5)) {
            contentOpacity = 0
            showSteppe = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 1.2)) {
                steppeAlignTop = alignTop
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            phase = newPhase
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                contentOpacity = 1
            }
        }
    }
    
    private func startStoryMode() {
        transitionWithSteppe(to: .scene1, alignTop: true)
    }
    
    private func transitionToGame() {
        transitionWithSteppe(to: .storyGameMode, alignTop: false)
    }
    
    private func transitionFromGame() {
        transitionWithSteppe(to: .scene12, alignTop: true)
    }
    
    private func completeStory() {
        hasCompletedStory = true
        transitionWithSteppe(to: .mainMenu, alignTop: false)
    }
    
    private func startEndlessMode() {
        transitionTo(.endlessGameMode)
    }
    
    private func exitEndless() {
        transitionTo(.mainMenu)
    }
}

#Preview(traits: .landscapeRight) {
    ContentView()
}
