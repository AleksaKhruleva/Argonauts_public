//
//  EnterPassCode.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 22.06.2021.
//

import SwiftUI

struct EnterPassCodeView: View {
    @Binding var switcher: Views
    
    @State var userCode: String = ""
    @State var text: String = "Ввeдите код"
    @State var alertMessage: String = ""
    
    @State var showAlert: Bool = false
    @State var isLoading: Bool = false
    
    @State private var timeRemaining = 60
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    GlobalObjs.enterCode = false
                    switcher = .enterEmail
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
                .frame(height: UIScreen.main.bounds.height / 8)
            TextField("Код", text: $userCode, onEditingChanged: { _ in  }, onCommit: {
                if userCode == GlobalObjs.codeConf {
                    GlobalObjs.enterCode = true
                    switcher = .setPin
                } else {
                    text = "Неверный код, попробуйте снова"
                }
            })
                .keyboardType(.numberPad)
                .font(.title3)
                .padding()
            Button {
                connectDeviceAsync()
                timeRemaining = 60
            } label: {
                if timeRemaining > 0 {
                    let minutes = String(format: "%02d", Int(timeRemaining / 60))
                    let seconds = String(format: "%02d", Int(timeRemaining % 60))
                    Text("Отправить код повторно\nчерез \(minutes):\(seconds)")
                } else {
                    Text("Отправить код повторно")
                }
            }
            .frame(height: UIScreen.main.bounds.height / 12)
            .disabled(timeRemaining > 0)
            Spacer()
            Button {
                if userCode == GlobalObjs.codeConf {
                    GlobalObjs.enterCode = true
                    switcher = .setPin
                } else {
                    text = "Неверный код, попробуйте снова"
                }
            } label: {
                Text("Продолжить")
                    .font(.title2.weight(.semibold))
                    .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.height / 10, alignment: .center)
                    .background(Color.gray.opacity(userCode.isEmpty || userCode.count < 6 ? 0.1 : 0.3))
                    .cornerRadius(UIScreen.main.bounds.width * 0.05)
            }
            .disabled(userCode.isEmpty || userCode.count < 6)
            Group {
                Spacer()
                Spacer()
            }
        }
        .onReceive(timer) { time in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            }
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Ошибка"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                alertMessage = ""
            })
        })
        .onAppear {
            if GlobalObjs.enterCode {
                userCode = GlobalObjs.codeConf
            }
        }
    }
    
    func connectDeviceAsync() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            GlobalObjs.codeConf = generatePassCode()
            connectDevice(email: GlobalObjs.email, code: GlobalObjs.codeConf)
            DispatchQueue.main.async {
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
