//
//  LoadingView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 01.11.2021.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        Rectangle()
            .fill(Color.systemColor.opacity(0.5))
            .allowsHitTesting(true)
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
    }
}
