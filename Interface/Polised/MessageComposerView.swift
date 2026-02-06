//
//  MessageComposerView.swift
//  Interface
//
//  Created by Harsh Sharma on 06/02/26.
//

import SwiftUI

struct MessageComposerView: View {
    private let message = """
    This is a message bubble. The height of this bubble should grow
    naturally based on the text length, without any fixed height.
    This is a message bubble. The height of this bubble should grow
    naturally based on the text length, without any fixed height.
    """

    var body: some View {
        MessageComposer(text: message, initialLikeCount: 0)
            .navigationTitle("Message Composer")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MessageComposerView()
    }
}
