import SwiftUI

struct LoreSheetContent: View {
    @Binding var currentPage: Int
    let totalPages: Int
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            LoreHeader(
                currentPage: $currentPage,
                totalPages: totalPages,
                isPresented: $isPresented
            )

            ScrollView {
                Group {
                    switch currentPage {
                    case 0: LorePage1()
                    default: EmptyView()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Lore Header
struct LoreHeader: View {
    @Binding var currentPage: Int
    let totalPages: Int
    @Binding var isPresented: Bool

    var body: some View {
        HStack {
            // Back button
            Button(action: {
                withAnimation { currentPage -= 1 }
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 42, height: 42)
            }
            .opacity(currentPage > 0 ? 1 : 0)
            .disabled(currentPage == 0)

            Spacer()

            Text("Lore")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.primary)

            Spacer()

            // Forward / Close button
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
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
}

// MARK: - Lore Page 1: The history of Shagai
struct LorePage1: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("The history of Shagai")
                .font(.system(size: 24, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .center)

            // Using Markdown for bolding makes the paragraph wrap cleanly as a single block
            Text(
                "**Shagai** are the anklebones of sheep or goats, central to **Mongolian culture** for centuries. For nomads of the steppe, these bones are **symbols** of luck, prosperity, and the bond between humans and livestock."
            )
            .font(.system(size: 18))
            .lineSpacing(2)
            .foregroundColor(.primary)
            .padding(.top, 16)

            // 2x2 grid of shagai images
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                Image("shagai-horse")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                Image("shagai-goat")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                Image("shagai-sheep")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                Image("shagai-camel")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .padding(.top, 8)
        .padding(.horizontal, 46)
        .onAppear {
            SpeechService.shared.speak(
                "The history of Shagai. Shagai are the anklebones of sheep or goats, central to Mongolian culture for centuries. For nomads of the steppe, these bones are symbols of luck, prosperity, and the bond between humans and livestock."
            )
        }
    }
}
