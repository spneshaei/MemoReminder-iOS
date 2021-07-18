// Seyed Parsa Neshaei and https://prafullkumar77.medium.com/swiftui-building-chips-with-autolayout-container-dbca53bbb848

import SwiftUI

struct Chips: View {
    let title: String
    let hexColor: String
    let onTap: () -> Void
    @State var isSelected: Bool = true
    
    var color: Color {
        Color(hex: hexColor)
    }
    
    var textShouldBeLight: Bool {
        let (red, green, blue, _) = color.components
        if (red * 299 + green * 587 + blue * 114) / 1000 >= 125 {
            return false
        } else {
            return true
        }
    }
    
    var body: some View {
        Text(title)
            .foregroundColor(textShouldBeLight ? .black : .white) // TODO: This is wrong?
            .lineLimit(1)
            .padding(.all, 10)
            .foregroundColor(isSelected ? .white : .blue)
            .background(color)
            .cornerRadius(40)  //rounded Corner
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.blue, lineWidth: 1.5)
                
            ).onTapGesture {
                onTap()
//                isSelected.toggle() // toggle select - not selected
            }
    }
}
