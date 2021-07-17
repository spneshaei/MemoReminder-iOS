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
    
    var memory: Memory
    var shouldShowProfilePicture: Bool
    
    init(memory: Memory, shouldShowProfilePicture: Bool = true) {
        self.memory = memory
        self.shouldShowProfilePicture = shouldShowProfilePicture
    }
    
    var body: some View {
        //        HStack() {
        //            if #available(iOS 15.0, *) {
        //                if !memory.creatorProfilePictureURL.isEmpty {
        //                    AsyncImage(url: URL(string: memory.creatorProfilePictureURL)!)
        //                }
        //            } else {
        //                // Fallback on earlier versions
        //            }
        //            VStack(alignment: .leading, spacing: 5) {
        //                Text(memory.title)
        //                    .font(.title2)
        //                Text("\(memory.creatorUsername) - \(memory.createdDate)")
        //                    .font(.body)
        //            }.padding()
        //            Spacer()
        //        }.padding()
        HStack(alignment: .center) {
            if shouldShowProfilePicture && URL(string: memory.imageLink) != nil {
                URLImage(URL(string: memory.imageLink)!) { urlImage in
                    urlImage.resizable()
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .padding(.all, 20)
                //                AsyncImage(url: URL(string: memory.imageLink)) { asyncImage in
                ////                    image.resizable()
                //                    asyncImage.resizable()
                //                }
                //                    .aspectRatio(contentMode: .fit)
                //                    .frame(width: 50)
                //                    .padding(.all, 20)
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
        .background(isDarkMode ? Color.orange : Color(red: 247/255, green: 207/255, blue: 71/255))

        .opacity(0.8)
        .modifier(MemoryCardModifier())
        .padding(.all, 10)
    }
}

struct MemoryCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            MemoryCell(memory: Memory.sample)
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
