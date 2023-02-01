//
//  PinCirclesView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 18.10.2021.
//

import SwiftUI

struct PinCirclesView: View {
    var pin: String
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(0 ..< 5) { item in
                if item < pin.count {
                    Circle()
                        .frame(width: UIScreen.main.bounds.width / 15, height: UIScreen.main.bounds.height / 15)
                } else {
                    Circle()
                        .strokeBorder(lineWidth: 1.7)
                        .frame(width: UIScreen.main.bounds.width / 15, height: UIScreen.main.bounds.height / 15)
                }
            }
        }
        .frame(height: UIScreen.main.bounds.height / 8)
        .padding()
    }
}
