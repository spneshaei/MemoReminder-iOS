//
//  MemoryCell.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI
import URLImage

struct MemoryCell: View {
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool { colorScheme == .dark }
    
    @State var seeComments = false
    
    var memory: Memory
    var shouldShowProfilePicture: Bool
    
    init(memory: Memory, shouldShowProfilePicture: Bool = true) {
        self.memory = memory
        self.shouldShowProfilePicture = shouldShowProfilePicture
    }
    
    var body: some View {
        HStack(alignment: .center) {
            if shouldShowProfilePicture && URL(string: memory.imageLink) != nil {
                AsyncImage(url: URL(string: memory.imageLink)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Color.purple.opacity(0)
                }
                .frame(width: 50)
                .padding()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(memory.title)
                        .font(.system(size: 26, weight: .bold, design: .default))
                        .foregroundColor(.black)
                    
                    Text("\(memory.creatorFirstName) \(Text("- \(memory.createdDateFormatted)").font(.system(size: 16, weight: .bold, design: .default)).foregroundColor(Color(red: 70/255, green: 70/255, blue: 70/255)))")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.black)
                }
                Spacer()
                Label("\(Text("\(memory.numberOfLikes)").bold())", systemImage: memory.hasCurrentUserLiked ? "heart.fill" : "heart")
                    .foregroundColor(.black)
            }.padding(16)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(isDarkMode ? Color(red: 231/255, green: 133/255, blue: 54/255) : Color(red: 247/255, green: 207/255, blue: 71/255))
        .listRowBackground(isDarkMode ? Color.black : Color.white)
        .modifier(MemoryCardModifier())
        .padding(.all, 10)
        .accessibility(hint: Text("Open memory \(memory.title)"))
    }
}

struct MemoryCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MemoryCell(memory: Memory.sample)
                .preferredColorScheme(.dark)
        }
    }
}

struct MemoryCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
    }
    
}
