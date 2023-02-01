//
//  EnterPinView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 30.06.2021.
//

import SwiftUI
import LocalAuthentication

struct EnterPinView: View {
    @Binding var switcher: Views
    
    @State var pin: String = ""
    @State var text: String = "Введите пин"
    @State var pinInfo: [String] = []
    
    @State var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
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
            if isLoading {
                LoadingView()
            }
        }
        .onAppear {
            readPinInfoAsync()
        }
        .onChange(of: pin) { pin in
            if pin.count == 5 {
                if pin == GlobalObjs.userPin {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        switcher = .home
                    }
                } else {
                    text = "Введен неверный пин"
                }
            } else {
                text = "Введите пин"
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
    
    func readPinInfoAsync() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            readPinInfo()
            DispatchQueue.main.async {
                isLoading = false
            }
        }
    }
    
    func readPinInfo() {
        let filename: String = "pinInfo.txt"
        do {
            let docDirUrl =  try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileUrl = docDirUrl.appendingPathComponent(filename)
            
            do {
                let contentFromFile = try NSString(contentsOf: fileUrl, encoding: String.Encoding.utf8.rawValue)
                pinInfo = contentFromFile.components(separatedBy: "\n")
                print("EnterPinView.readPinInfo(): \(pinInfo)")
                GlobalObjs.email = pinInfo[0]
                GlobalObjs.userPin = pinInfo[1]
            } catch let error as NSError {
                print("EnterPinView.readPinInfo(): \(error)")
            }
            
        } catch let error as NSError {
            print("EnterPinView.readPinInfo(): \(error)")
        }
    }
}
