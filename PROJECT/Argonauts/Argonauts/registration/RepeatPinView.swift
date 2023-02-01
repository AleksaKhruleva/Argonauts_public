//
//  RepeatPinView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 24.06.2021.
//

import SwiftUI
import LocalAuthentication

struct RepeatPinView: View {
    @Binding var switcher: Views
    
    @State var pinRepeat: String = ""
    @State var text: String = "Введите пин повторно"
    @State var alertMessage: String = ""
    
    @State var isLoading: Bool = false    
    @State var isExists: Bool = false
    @State var showAlert: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        switcher = .setPin
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
                PinCirclesView(pin: pinRepeat)
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
            .onChange(of: pinRepeat) { value in
                if value.count == 5 {
                    if value == GlobalObjs.userPin {
                        isEmailExistsAsync()
                    } else {
                        text = "Пин не совпадает"
                    }
                } else {
                   text = "Введите пин повторно"
                }
            }
            if isLoading {
                LoadingView()
            }
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Ошибка"), message: Text(alertMessage))
        })
    }
    
    func setPin(value: numPadButton) {
        if value == .del && pinRepeat.count > 0 {
            pinRepeat.removeLast()
        } else if value != .del && pinRepeat.count < 5 {
            pinRepeat.append(value.rawValue)
        }
    }
    
    func isEmailExistsAsync() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            isEmailExists(email: GlobalObjs.email)
            DispatchQueue.main.async {
                if isExists {
                    let textToWrite = GlobalObjs.email + "\n" + GlobalObjs.userPin
                    writeToDocDir(filename: "pinInfo", text: textToWrite)
                    switcher = .home
                } else if alertMessage == "" {
                    switcher = .createAccount
                }
                isLoading = false
            }
        }
    }
    
    func isEmailExists(email: String) {
        let urlString = appURL + "?mission=is_email_exists&email=" + email
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["user"] as! [String : Any]
                    print("RepeatPinView.isEmailExists(): \(info)")
                    if info["server_error"] != nil {
                        alertMessage = "Ошибка сервера"
                        showAlert = true
                    } else if info["no"] != nil {
                        alertMessage = ""
                        isExists = false
                    } else {
                        alertMessage = ""
                        isExists = true
                    }
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
                alertMessage = "Ошибка"
                showAlert = true
            }
        } else {
            alertMessage = "Ошибка"
            showAlert = true
        }
    }
}
