//
//  SetPinView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 23.06.2021.
//

import SwiftUI

struct SetPinView: View {
    @Binding var switcher: Views
    
    @State var pin: String = ""
    @State var text: String = "Введите пин"
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    switcher = .enterPassCode
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.title2.weight(.semibold))
                }
                Spacer()
            }
            .padding([.leading, .trailing, .top])
            Spacer()
            Text(text)
                .font(.title.weight(.semibold))
                .multilineTextAlignment(.center)
            PinCirclesView(pin: pin)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 17) {
                ForEach(butNotBio, id: \.self) { value in
                    Button {
                        setPin(value: value)
                    } label: {
                        if value == .del {
                            Image(systemName: value.rawValue)
                                .font(.title)
                                .foregroundColor(.reverseColor)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .circular)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 7)
                                )
                                .frame(width: UIScreen.main.bounds.width / 4.5, height: UIScreen.main.bounds.width / 8)
                        } else if value.rawValue != "" {
                            Text(value.rawValue)
                                .font(.title)
                                .foregroundColor(.reverseColor)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .circular)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 7)
                                )
                                .frame(width: UIScreen.main.bounds.width / 4.5, height: UIScreen.main.bounds.width / 8)
                        }
                    }
                }
            }
            .padding()
            Spacer()
        }
        .onChange(of: pin) { pin in
            if pin.count == 5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    GlobalObjs.userPin = pin
                    switcher = .repeatPin
                }
            }
        }
    }
    
    func setPin(value: numPadButton) {
        if value == .del && pin.count > 0 {
            pin.removeLast()
        } else if value != .del && pin.count < 5 {
            pin.append(value.rawValue)
        }
    }
}
