// https://prafullkumar77.medium.com/swiftui-building-chips-with-autolayout-container-dbca53bbb848

import SwiftUI

struct ChipsContent: View {
    @State var selectedTags: [Tag]
    @State var onTap: (Int) -> Void
    
    var body: some View {
        return ScrollView(.horizontal) {
            HStack {
                ForEach(selectedTags) { tag in
                    Chips(id: tag.id, title: tag.name, hexColor: tag.color, onTap: onTap)
                        .padding(.all, 5)
                }
                Spacer()
            }
        }
    }
}

struct OldChipsContent: View {
    @State var selectedTags: [Tag]
    @State var onTap: (Int) -> Void
    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return GeometryReader { geo in
            ZStack(alignment: .topLeading, content: {
                ForEach(selectedTags) { chipsData in //loop to render all chips
                    Chips(id: chipsData.id, title: chipsData.name, hexColor: chipsData.color, onTap: onTap)
                        .padding(.all, 5)
                        .alignmentGuide(.leading) { dimension in  //update leading width for available width
                            if (abs(width - dimension.width) > geo.size.width) {
                                width = 0
                                height -= dimension.height
                            }
                            
                            let result = width
                            if chipsData.id == selectedTags.count - 1 {
                                width = 0
                            } else {
                                width -= dimension.width
                            }
                            return result
                        }
                        .alignmentGuide(.top) { dimension in //update chips height origin wrt past chip
                            let result = height
                            if chipsData.id == selectedTags.count - 1 {
                                height = 0
                            }
                            return result
                        }
                }
            })
        }.padding(.all, 10)
    }
}
