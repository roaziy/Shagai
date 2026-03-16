import SwiftUI

struct StoryGameTutorial: View {
    @State private var showTutorial = false
    @State private var currentPage = 0
    private let totalPages = 7
    
    var body: some View {
        Color.clear
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showTutorial = true
                }
            }
            .sheet(isPresented: $showTutorial) {
                TutorialSheetContent(
                    currentPage: $currentPage, totalPages: totalPages, isPresented: $showTutorial
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .onDisappear {
                    SpeechService.shared.stop()
                }
            }
    }
    
    func reopenTutorial() {
        currentPage = 0
        showTutorial = true
    }
}

struct TutorialSheetContent: View {
    @Binding var currentPage: Int
    let totalPages: Int
    @Binding var isPresented: Bool
    var isFirstTime: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            TutorialHeader(
                currentPage: $currentPage,
                totalPages: totalPages,
                isPresented: $isPresented
            )
            
            ScrollView {
                Group {
                    switch currentPage {
                    case 0: TutorialPage1()
                    case 1: TutorialPage2()
                    case 2: TutorialPage3()
                    case 3: TutorialPage4()
                    case 4: TutorialPage5()
                    case 5: TutorialPage6()
                    case 6: TutorialPage7()
                    default: EmptyView()
                    }
                }
                .padding(.horizontal, 48)
                .padding(.bottom, 36)
            }
        }
    }
}

struct TutorialHeader: View {
    @Binding var currentPage: Int
    let totalPages: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation { currentPage -= 1 }
            }) {
                ZStack {
                    Circle()
                        .fill(Color(white: 0.92))
                        .frame(width: 42, height: 42)
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.gray)
                }
            }
            .opacity(currentPage > 0 ? 1 : 0)
            .disabled(currentPage == 0)
            
            Spacer()
            
            Text("Tutorial")
                .font(.system(size: 17, weight: .semibold))
            
            Spacer()
            
            Button(action: {
                if currentPage < totalPages - 1 {
                    withAnimation { currentPage += 1 }
                } else {
                    isPresented = false
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 42, height: 42)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 44)
    }
}

struct TutorialPage1: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Help Warrior and Queen to escape!")
                .font(.system(size: 24, weight: .medium))
                .multilineTextAlignment(.center)
            
            Image("scene9")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 350)
                .padding(.top, 30)
                .padding(.trailing, 30)
        }
        .padding(.top, 16)
        .onAppear {
            SpeechService.shared.speak("Help Warrior and Queen to escape!")
        }
    }
}

struct TutorialPage2: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(
                "This is a game of **Shagai Uraldaan** (Horse Race). You must reach the end of the 8-shagai track before the enemies catch you."
            )
            .font(.system(size: 18))
            .lineSpacing(2)
            .foregroundColor(.primary)
            .padding(.top, 16)
            
            Text("The **Golden Shagai** is you, and the **Dark Shagai** is the enemies.")
                .font(.system(size: 18))
                .lineSpacing(2)
                .foregroundColor(.primary)
                .padding(.top, 16)
            
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .center, spacing: 4) {
                    Text("You")
                        .font(.system(size: 16, weight: .bold))
                    Image("golden-shagai")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                }
                
                HStack(spacing: 4) {
                    ForEach(1...8, id: \.self) { i in
                        VStack(spacing: 2) {
                            Image("shagai-horse")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 46)
                            Text("\(i)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(i == 8 ? .red : .primary)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Image("enemy-shagai")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 41)
                    Text("Enemies")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.red)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 30)
        }
        .padding(.top, 16)
        .padding(.horizontal, 24)
        .onAppear {
            SpeechService.shared.speak(
                "This is a game of Shagai Uraldaan, Horse Race. You must reach the end of the 8 shagai track before the enemies catch you. The Golden Shagai is you, and the Dark Shagai is the enemies."
            )
        }
    }
}

struct TutorialPage3: View {
    private var useAltControls: Bool {
        UserDefaults.standard.bool(forKey: "accessibilityAltControls")
    }
    
    var body: some View {
        if useAltControls {
            altControlsPage3
        } else {
            arControlsPage3
        }
    }
    
    private var altControlsPage3: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to Play?")
                .font(.system(size: 24, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .center)
            
            (Text("Hold the ")
             + Text("Throw button").bold()
             + Text(" to gather power, then ")
             + Text("release").bold()
             + Text(" to toss the Shagai onto the board!"))
            .font(.system(size: 18))
            .lineSpacing(2)
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("1. Hold The Button")
                        .font(.system(size: 16, weight: .bold))
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black)
                            .frame(height: 180)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.orange)
                            Text("Hold the Throw")
                                .font(.system(size: 16, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                VStack(spacing: 8) {
                    Text("2. Then release the button")
                        .font(.system(size: 16, weight: .bold))
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black)
                            .frame(height: 180)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.green)
                            Text("Release to Throw!")
                                .font(.system(size: 16, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding(.top, 16)
        .onAppear {
            SpeechService.shared.speak(
                "How to Play? Hold the Throw button to gather power, then release to toss the Shagai onto the board!"
            )
        }
    }
    
    private var arControlsPage3: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to Play?")
                .font(.system(size: 24, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .center)
            
            (Text("Place your hand in front of the camera and ")
             + Text("make a fist").bold() + Text(", then ")
             + Text("open your hand").bold() + Text(" to throw."))
            .font(.system(size: 18))
            .lineSpacing(2)
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("1. Make a Fist")
                        .font(.system(size: 16, weight: .bold))
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.95, green: 0.92, blue: 0.85))
                            .frame(height: 180)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "hand.raised.fingers.spread")
                                .font(.system(size: 52))
                                .foregroundColor(.orange)
                            Image(systemName: "arrow.down")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.secondary)
                            Image(systemName: "fist.fill")
                                .font(.system(size: 52))
                                .foregroundColor(.red)
                        }
                    }
                }
                
                VStack(spacing: 8) {
                    Text("2. Open to Throw")
                        .font(.system(size: 16, weight: .bold))
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.95, green: 0.92, blue: 0.85))
                            .frame(height: 180)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "fist.fill")
                                .font(.system(size: 52))
                                .foregroundColor(.red)
                            Image(systemName: "arrow.down")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.secondary)
                            Image(systemName: "hand.raised.fingers.spread")
                                .font(.system(size: 52))
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding(.top, 16)
        .onAppear {
            SpeechService.shared.speak(
                "How to Play? Place your hand in front of the camera and make a fist, then open your hand to throw."
            )
        }
    }
}

struct TutorialPage4: View {
    private var useAltControls: Bool {
        UserDefaults.standard.bool(forKey: "accessibilityAltControls")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to Play? – Movement")
                .font(.system(size: 24, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .center)
            
            if useAltControls {
                Text(
                    "When the finger is lifted, the \"Throw\" logic triggers, and the pieces are flung across the board to land on their specific sides (**Horse**, **Sheep**, **Goat**, **Camel**)."
                )
                .font(.system(size: 18))
                .lineSpacing(2)
                .foregroundColor(.primary)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
            }
            
            Text(
                "Your horse moves forward based on how many pieces land on the \"**Horse**\" side (flat side with a small indentation)."
            )
            .font(.system(size: 18))
            .lineSpacing(2)
            .foregroundColor(.primary)
            .padding(.horizontal, 32)
            .padding(.vertical, useAltControls ? 12 : 24)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 40) {
                ShagaiSideItem(imageName: "shagai-horse", label: "Horse", isCorrect: true)
                ShagaiSideItem(imageName: "shagai-goat", label: "Goat", isCorrect: false)
                ShagaiSideItem(imageName: "shagai-sheep", label: "Sheep", isCorrect: false)
                ShagaiSideItem(imageName: "shagai-camel", label: "Camel", isCorrect: false)
            }
            .padding(.horizontal, 48)
            .padding(.top, 24)
        }
        .padding(.top, 16)
        .onAppear {
            if useAltControls {
                SpeechService.shared.speak(
                    "When the finger is lifted, the Throw logic triggers, and the pieces are flung across the board to land on their specific sides: Horse, Sheep, Goat, Camel. Your horse moves forward based on how many pieces land on the Horse side."
                )
            } else {
                SpeechService.shared.speak(
                    "How to Play, Movement. Your horse moves forward based on how many pieces land on the Horse side, the flat side with a small indentation."
                )
            }
        }
    }
}

struct ShagaiSideItem: View {
    let imageName: String
    let label: String
    let isCorrect: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 72)
            
            HStack(spacing: 4) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? .green : .red)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 16, weight: .bold))
            }
        }
    }
}

struct TutorialPage5: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to Play? – Movement")
                .font(.system(size: 24, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(spacing: 4) {
                (Text("1").bold() + Text(" Horse = ") + Text("1").bold() + Text(" step forward."))
                (Text("4").bold() + Text(" Horses = ") + Text("4").bold() + Text(" steps forward."))
            }
            .font(.system(size: 18))
            .lineSpacing(2)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 24)
            
            Text("For example: You throw 3-Horse")
                .font(.system(size: 18))
                .lineSpacing(2)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
            
            TrackVisualization1(playerPosition: 3, enemyPosition: 0)
                .padding(.top, 18)
        }
        .padding(.top, 16)
        .onAppear {
            SpeechService.shared.speak(
                "1 Horse equals 1 step forward. 4 Horses equals 4 steps forward. For example, you throw 3 Horse."
            )
        }
    }
}

struct TutorialPage6: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to Play? – Movement")
                .font(.system(size: 24, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(
                "After your turn, the **enemies** will throw! If their piece (the **dark** shagai) reaches **the end** first, the level will **restart**."
            )
            .font(.system(size: 18))
            .lineSpacing(2)
            .foregroundColor(.primary)
            .padding(.vertical, 24)
            
            Text("For example: Enemies throw 4-Horse")
                .font(.system(size: 18))
                .lineSpacing(2)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
            
            TrackVisualization2(playerPosition: 3, enemyPosition: 4)
                .padding(.top, 18)
        }
        .padding(.top, 16)
        .onAppear {
            SpeechService.shared.speak(
                "After your turn, the enemies will throw! If their piece, the dark shagai, reaches the end first, the level will restart. For example, enemies throw 4 Horse."
            )
        }
    }
}

struct TutorialPage7: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Ride!")
                .font(.system(size: 24, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .center)
            
            Image("scene9")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 350)
                .padding(.trailing, 30)
        }
        .padding(.top, 16)
        .onAppear {
            SpeechService.shared.speak("Ride!")
        }
    }
}

struct TrackVisualization1: View {
    let playerPosition: Int
    let enemyPosition: Int
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack {
                VStack(spacing: 4) {
                    Text("You")
                        .font(.system(size: 16, weight: .bold))
                        .opacity(0)
                    Image("golden-shagai")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 46)
                }
                .opacity(0.2)
                VStack(spacing: 4) {
                    Text("You")
                        .font(.system(size: 16, weight: .bold))
                        .opacity(0)
                    Image("golden-shagai")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 46)
                }
                .opacity(0.2)
                VStack(spacing: 4) {
                    Text("You")
                        .font(.system(size: 16, weight: .bold))
                    Image("golden-shagai")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 46)
                }
                Spacer()
            }
            
            HStack(spacing: 4) {
                ForEach(1...8, id: \.self) { i in
                    VStack(spacing: 2) {
                        Image("shagai-horse")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 46)
                        Text("\(i)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(i == 8 ? .red : .primary)
                    }
                }
            }
            
            if enemyPosition > 0 {
                HStack {
                    ForEach(1...8, id: \.self) { i in
                        if i == enemyPosition {
                            VStack(alignment: .leading, spacing: 4) {
                                Image("enemy-shagai")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 43)
                                Text("Enemies")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.red)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .padding(.leading, 4)
                            }
                            .padding(.leading, 8)
                        } else {
                            Color.clear.frame(height: 43)
                        }
                    }
                }
            } else {
                VStack(spacing: 4) {
                    Image("enemy-shagai")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 43)
                    Text("Enemies")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct TrackVisualization2: View {
    let playerPosition: Int
    let enemyPosition: Int
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack {
                VStack(spacing: 4) {
                    Text("You")
                        .font(.system(size: 16, weight: .bold))
                        .opacity(0)
                    Image("golden-shagai")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 46)
                }
                .opacity(0)
                VStack(spacing: 4) {
                    Text("You")
                        .font(.system(size: 16, weight: .bold))
                        .opacity(0)
                    Image("golden-shagai")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 46)
                }
                .opacity(0)
                VStack(spacing: 4) {
                    Text("You")
                        .font(.system(size: 16, weight: .bold))
                    Image("golden-shagai")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 46)
                }
                Spacer()
            }
            
            HStack(spacing: 4) {
                ForEach(1...8, id: \.self) { i in
                    VStack(spacing: 2) {
                        Image("shagai-horse")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 46)
                        Text("\(i)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(i == 8 ? .red : .primary)
                    }
                }
            }
            
            if enemyPosition > 0 {
                HStack {
                    ForEach(1...8, id: \.self) { i in
                        if i == enemyPosition {
                            VStack(alignment: .leading, spacing: 4) {
                                Image("enemy-shagai")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 43)
                                    .padding(.leading, 4)
                                Text("Enemies")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.red)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .padding(.leading, 4)
                            }
                        } else {
                            Color.clear.frame(height: 43)
                        }
                    }
                }
            } else {
                VStack(spacing: 4) {
                    Image("enemy-shagai")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 43)
                    Text("Enemies")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview(traits: .landscapeRight) {
    StoryGameTutorial()
}
