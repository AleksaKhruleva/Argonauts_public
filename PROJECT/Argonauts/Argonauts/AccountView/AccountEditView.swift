//
//  AccountEditView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 16.07.2021.
//

import SwiftUI

struct AccountEditView: View {
    @State var nick: String
    @State var nickWas: String
    @Binding var showAccountEdit: Bool
    
    @State var alertMessage: String = ""
    
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                TextField("Имя", text: $nick)
                    .disableAutocorrection(true)
                    .font(.title3)
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
            }
            if isLoading {
                LoadingView()
            }
        }
        .navigationBarTitle("Детали", displayMode: .inline)
        .navigationBarItems(leading:
                                Button(action: {
                                    showAccountEdit = false
                                }, label: {
                                    Text("Отм.")
                                }),
                            trailing:
                                Button(action: {
                                    updateUserInfoAsync()
                                }, label: {
                                    Text("Готово")
                                })
                                .disabled(nick == nickWas)
                            )
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
    
    func updateUserInfoAsync() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            if isValidNick(nick: nick) {
                updateUserInfo(email: GlobalObjs.email, nick: nick)
            } else {
                alertMessage = "Введены некорректные данные"
                showAlert = true
            }
            DispatchQueue.main.async {
                if alertMessage == "" {
                    showAccountEdit = false
                }
                isLoading = false
            }
        }
    }
    
    func updateUserInfo(email: String, nick: String) {
        let urlString = appURL + "?mission=update_user_info&email=" + email + "&nick=" + nick
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["update_user_info"] as! [String : Any]
                    print("AccountEditView.updateUserInfo(): \(info)")
                    if info["server_error"] != nil {
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
