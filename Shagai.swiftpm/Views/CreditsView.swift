//
//  CreditsView.swift
//  Beta Shagai
//
//  Created by roaziy on 2/28/26.
//

import SwiftUI

// Inner scroll content — rendered inside MainMenu's existing parchment ZStack.
struct CreditsView: View {
    var onBack: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("Credits")
                .font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 24)

            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Created & Developed by")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    Text("Erkhemtur (roaziy) Altan-Ochir")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
                Spacer()
                Image("dev-profile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            }
            .padding(.top, 28)
            .padding(.horizontal, 44)

            Divider()
                .padding(.horizontal, 44)
                .padding(.vertical, 12)

            Text(
                "Deeply inspired by the heritage of the Mongolian Empire and the traditional game of Shagai."
            )
            .font(.system(size: 14))
            .foregroundColor(.black)
            .padding(.horizontal, 44)

            Divider()
                .padding(.horizontal, 44)
                .padding(.vertical, 14)

            (Text("Built with ")
                + Text("SwiftUI, ARKit, RealityKit").bold()
                + Text(" and ")
                + Text("Vision").bold()
                + Text(" for real-time hand-tracking interactions. All illustrations were ")
                + Text("Designed").underline()
                + Text(" and ")
                + Text("illustrated").italic().underline()
                + Text(" entirely in ")
                + Text("Figma").bold()
                + Text("."))
                .font(.system(size: 14))
                .foregroundColor(.black)
                .padding(.horizontal, 44)

            Spacer()

            CustomButton(
                title: "Back to Menu",
                imageName: "continue-button",
                buttonSize: 68,
                textSize: 22
            ) {
                onBack()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 44)
        }
    }
}
