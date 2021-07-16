//
//  MemoryCell.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI
import URLImage

struct MemoryCell: View {
    var memory: Memory
    var shouldShowProfilePicture: Bool
    
    init(memory: Memory, shouldShowProfilePicture: Bool = true) {
        self.memory = memory
        self.shouldShowProfilePicture = shouldShowProfilePicture
    }
    
    var body: some View {
        //        HStack() {
        //            // TODO: These URLs are only the ending part and not complete
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
            if URL(string: memory.imageLink) != nil {
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
                // TODO: Make the image clipped to circle
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(memory.title)
                    .font(.system(size: 26, weight: .bold, design: .default))
                    .foregroundColor(.black)
                Text(memory.createdDate)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundColor(Color(red: 70/255, green: 70/255, blue: 70/255))
                HStack {
                    Text(memory.creatorUsername)
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.black)
                        .padding(.top, 8)
                }
            }.padding(20)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color(red: 247/255, green: 207/255, blue: 71/255))
        .opacity(0.8)
        .modifier(MemoryCardModifier())
        .padding(.all, 10)
    }
}

struct MemoryCell_Previews: PreviewProvider {
    static var previews: some View {
        MemoryCell(memory: Memory.sample)
    }
}

struct MemoryCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
    }
    
}
