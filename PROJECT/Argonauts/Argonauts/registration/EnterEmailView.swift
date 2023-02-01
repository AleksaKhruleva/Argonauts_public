//
//  EnterEmailView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 04.07.2021.
//

import SwiftUI

struct EnterEmailView: View {
    @Binding var switcher: Views
    
    @State var email: String = ""
    @State var alertMessage: String = ""
    
    @State var showAlert: Bool = false
    @State var isLoading: Bool = false
    @State var isValid: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.systemColor)
                    }
                    Spacer()
                }
                .padding([.leading, .trailing, .top])
                Spacer()
                Text("Регистрация")
                    .font(.title.weight(.semibold))
                    .frame(height: UIScreen.main.bounds.height / 8)
                Spacer()
                TextField("Email", text: $email, onEditingChanged: { _ in  }, onCommit: {
                    isValid = isValidEmail(email: email)
                    if isValid {
                        connectDeviceAsync()
                    } else {
                        alertMessage = "Введён некорректный email"
                        showAlert = true
                    }
                })
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                    .font(.title3)
                    .padding()
                Spacer()
                Button {
                    UIApplication.shared.endEditing()
                    isValid = isValidEmail(email: email)
                    if isValid {
                        connectDeviceAsync()
                    } else {
                        alertMessage = "Введён некорректный email"
                        showAlert = true
                    }
                } label: {
                    Text("Продолжить")
                        .font(.title2.weight(.semibold))
                        .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.height / 10, alignment: .center)
                        .background(Color.gray.opacity(email.isEmpty ? 0.1 : 0.3))
                        .cornerRadius(UIScreen.main.bounds.width * 0.05)
                }
                .disabled(email.isEmpty)
                Spacer()
                Spacer()
            }
            if isLoading {
                LoadingView()
            }
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Ошибка"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                alertMessage = ""
            })
        })
        .onAppear {
            email = GlobalObjs.email
        }
    }
    
    func connectDeviceAsync() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            GlobalObjs.codeConf = generatePassCode()
            connectDevice(email: email, code: GlobalObjs.codeConf)
            DispatchQueue.main.async {
                if alertMessage == "" {
                    GlobalObjs.email = email
                    switcher = .enterPassCode
                }
                isLoading = false
            }
        }
    }
    
    func connectDevice(email: String, code: String) {
        let urlString = appURL + "?mission=connect_device&email=" + email + "&code=" + code
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["connect_device"] as! [String : Any]
                    print("EnterEmailView.connectDevice(): \(info)")
                    if info["server_error"] != nil {
                        alertMessage = "Ошибка сервера"
                        showAlert = true
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
    
    func generatePassCode() -> String {
        let passCode = String(Int.random(in: 100000...999999))
        return passCode
    }
}
