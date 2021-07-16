//
//  CommentsView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

struct CommentsView: View {
    @State var memory: Memory
    
    var body: some View {
        List(memory.comments) { comment in
            HStack {
                VStack(alignment: .leading) {
                    Text("\(comment.senderFirstName) wrote:")
                        .bold()
                    Text(comment.contents)
                }
                Spacer()
                Label("\(comment.numberOfLikes)", systemImage: comment.hasCurrentUserLiked ? "heart.fill" : "heart")
                    .onTapGesture {
                        print("")
                    }
                    
            }
        }.navigationBarTitle(Text("Comments"))
    }
}

struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView(memory: Memory.sample)
    }
}
