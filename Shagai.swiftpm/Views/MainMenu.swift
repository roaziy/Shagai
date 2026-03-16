import SwiftUI

struct MainMenu: View {
    var Endless: Bool = false
    var onStoryMode: () -> Void = {}
    var onEndlessMode: () -> Void = {}

    @State private var showCredits = false
    @State private var showAccessibility = false

    var body: some View {
        ZStack {
            Image("menu")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 450)

            if showCredits {
                CreditsView(onBack: {
                    withAnimation(.easeInOut(duration: 0.25)) { showCredits = false }
                })
                .frame(width: 400, height: 460)
                .transition(.opacity)
            } else if showAccessibility {
                AccessibilityView(
                    buttonTitle: "Back to Menu",
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.25)) { showAccessibility = false }
                    }
                )
                .frame(width: 400, height: 460)
                .transition(.opacity)
            } else {
                VStack {
                    HStack {
                        Image("golden-shagai")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 65)
                        Text("Shagai: Adventure of The Warrior")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(.black)
                            .padding(.leading, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    Spacer()

                    VStack {
                        CustomButton(
                            title: "Story Mode", imageName: "menu-button", buttonSize: 72,
                            textSize: 24
                        ) {
                            onStoryMode()
                        }
                        if Endless {
                            CustomButton(
                                title: "Endless Mode", imageName: "menu-button", buttonSize: 72,
                                textSize: 24
                            ) {
                                onEndlessMode()
                            }
                        } else {
                            CustomButton(
                                title: "Endless Mode", imageName: "menu-button", inactive: true,
                                buttonSize: 72, textSize: 24
                            ) {}
                        }
                        CustomButton(
                            title: "Accessibility", imageName: "menu-button", buttonSize: 72,
                            textSize: 24
                        ) {
                            withAnimation(.easeInOut(duration: 0.25)) { showAccessibility = true }
                        }
                        CustomButton(
                            title: "Credits", imageName: "menu-button", buttonSize: 72, textSize: 24
                        ) {
                            withAnimation(.easeInOut(duration: 0.25)) { showCredits = true }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 4)
                }
                .frame(width: 400, height: 460)
                .transition(.opacity)
            }
        }
    }
}
