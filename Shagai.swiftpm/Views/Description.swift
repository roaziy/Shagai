import SwiftUI

struct Description: View {
    var title: String
    var imageName: String = "Story-ScoreStats"
    var icon: String = ""
    var inactive: Bool = false
    var buttonSize: Int = 150
    var textSize: Int = 20
    
    var body: some View {
            ZStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: CGFloat(buttonSize))
                
                HStack {
                    Text(title)
                        .font(.system(size: CGFloat(textSize), weight: .bold, design: .serif))
                        .foregroundColor(.black)
                        .frame(width: 496)
                    
                    if !icon.isEmpty {
                        Image(systemName: icon)
                    }
                }
            }
        .buttonStyle(.plain)
        .opacity(inactive ? 0.2 : 1.0)
        .disabled(inactive)
    }
}
