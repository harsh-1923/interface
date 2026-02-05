//
//  PinchTriggerView.swift
//  Interface
//
//  Created by Harsh Sharma on 06/02/26.
//

import SwiftUI

struct PinchTriggerView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
        .navigationTitle("Pinch")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PinchTriggerView()
}
