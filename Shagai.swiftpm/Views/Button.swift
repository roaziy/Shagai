import SwiftUI

struct CustomButton: View {
    var title: String
    var imageName: String = "continue-button"
    var icon: String = ""
    var inactive: Bool = false
    var buttonSize: Int = 60
    var textSize: Int = 22
    
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            if !inactive { action() }
        }) {
            ZStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: CGFloat(buttonSize))
                
                HStack {
                    Text(title)
                        .font(.system(size: CGFloat(textSize), weight: .bold, design: .serif))
                        .foregroundColor(.black)
                    
                    if !icon.isEmpty {
                        Image(systemName: icon)
                            .foregroundColor(.black) 
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .opacity(inactive ? 0.2 : 1.0)
        .disabled(inactive)
    }
}
