//
//  CreateAccount.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 25.06.2021.
//

import SwiftUI
import LocalAuthentication

struct CreateAccountView: View {
    @Binding var switcher: Views
    
    @State var nick: String = ""
    @State var alertMessage: String = ""
    
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text("Введите своё имя")
                    .font(.title.weight(.semibold))
                Spacer()
                TextField("Имя", text: $nick, onEditingChanged: { _ in }, onCommit: {
                    UIApplication.shared.endEditing()
                    if isValidNick(nick: nick) {
                        addUserAsync()
                    } else {
                        alertMessage = "Введено некорректное имя"
                        showAlert = true
                    }
                })
                    .font(.title3)
                    .disableAutocorrection(true)
                    .padding()
                HStack {
                    Text("Допустимые символы: A-Za-zА-Яа-я0-9_-")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding([.leading, .trailing])
                HStack {
                    Text("Длина: от 3 до 32 знаков")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding([.leading, .trailing])
                Spacer()
                Button {
                    UIApplication.shared.endEditing()
                    if isValidNick(nick: nick) {
                        addUserAsync()
                    } else {
                        alertMessage = "Введено некорректное имя"
                        showAlert = true
                    }
                } label: {
                    Text("Продолжить")
                        .font(.title2.weight(.semibold))
                        .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.height / 10, alignment: .center)
                        .background(Color.gray.opacity(nick.isEmpty ? 0.1 : 0.3))
                        .cornerRadius(UIScreen.main.bounds.width * 0.05)
                }
                .disabled(nick.isEmpty)
                Spacer()
            }
            if isLoading {
                LoadingView()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Ошибка"), message: Text(alertMessage))
        }
    }
    
    func isValidNick(nick: String) -> Bool {
        do {
            let regEx = "^[A-Za-zА-Яа-я0-9_-]{3,32}$"
            let regex = try NSRegularExpression(pattern: regEx)
            let nsString = nick as NSString
            let results = regex.matches(in: nick, range: NSRange(location: 0, length: nsString.length))
            if results.count != 1 {
                return false
            }
            return true
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    func addUserAsync() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            addUser(email: GlobalObjs.email, nick: nick)
            DispatchQueue.main.async {
                if alertMessage == "" {
                    let textToWrite = GlobalObjs.email + "\n" + GlobalObjs.userPin
                    writeToDocDir(filename: "pinInfo", text: textToWrite)
                    switcher = .addTransp
                }
                isLoading = false
            }
        }
    }
    
    func addUser(email: String, nick: String) {
        let urlString = appURL + "?mission=add_user&email=" + email + "&nick=" + nick
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let dop = json["new_user"] as! [String : Any]
                    print("CreateAccountView.addUser(): \(dop)")
                    if dop["server_error"] != nil {
                        alertMessage = "Ошибка сервера"
                        showAlert = true
                    } else {
                        alertMessage = ""
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
