// https://prafullkumar77.medium.com/swiftui-building-chips-with-autolayout-container-dbca53bbb848

import SwiftUI
struct ChipsContent: View {
    @ObservedObject var viewModel: TagsViewModel
    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return GeometryReader { geo in
            ZStack(alignment: .topLeading, content: {
                ForEach(viewModel.selectedTags) { chipsData in //loop to render all chips
                    Chips(title: chipsData.name, hexColor: chipsData.color, onTap: { })
                        .padding(.all, 5)
                        .alignmentGuide(.leading) { dimension in  //update leading width for available width
                            if (abs(width - dimension.width) > geo.size.width) {
                                width = 0
                                height -= dimension.height
                            }
                            
                            let result = width
                            if chipsData.id == viewModel.selectedTags.count - 1 {
                                width = 0
                            } else {
                                width -= dimension.width
                            }
                            return result
                        }
                        .alignmentGuide(.top) { dimension in //update chips height origin wrt past chip
                            let result = height
                            if chipsData.id == viewModel.selectedTags.count - 1 {
                                height = 0
                            }
                            return result
                        }
                }
            })
        }.padding(.all, 10)
    }
}
