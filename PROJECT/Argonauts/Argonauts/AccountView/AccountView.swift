//
//  AccountView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 29.06.2021.
//

import SwiftUI

struct AccountView: View {
    @Binding var switcher: Views
    @Binding var showAccountEdit: Bool
    @Binding var exitButTap: Bool
    
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    //    @State var showAccountEdit: Bool = false
    @State var showAccountEmail: Bool = false
    @State var fileRemoved: Bool = false
    
    @State var alertMessage: String = ""
    @State var nick: String = ""
    @State var selection: String? = nil
    
    @State var preferences: [String] = ["Почта"]
    
    var body: some View {
        ZStack {
            VStack {
                Text(nick)
                    .font(.title2.weight(.semibold))
                    .padding([.leading, .trailing])
                Text(GlobalObjs.email)
                    .font(.title2.weight(.semibold))
                    .padding([.leading, .trailing])
                List {
                    ForEach(preferences, id: \.self) { pref in
                        NavigationLink(pref, destination: AccountEmailView(email: GlobalObjs.email, switcher: $switcher))
                    }
                }
                .listStyle(PlainListStyle())
            }
            if isLoading {
                LoadingView()
            }
        }
        .onChange(of: exitButTap, perform: { newValue in
            if exitButTap == true {
                alertMessage = "Вы уверены, что хотите выйти из аккаунта?"
                showAlert = true
            }
        })
        .alert(isPresented: $showAlert) {
            if alertMessage == "Вы уверены, что хотите выйти из аккаунта?" {
                return Alert(title: Text("Выход"), message: Text(alertMessage), primaryButton: .destructive(Text("Выйти")) {
                    removePinFileAsync()
                    GlobalObjs.email = ""
                    GlobalObjs.codeConf = ""
                    GlobalObjs.enterCode = false
                }, secondaryButton: .cancel() {
                    exitButTap = false
                })
            } else {
                return Alert(title: Text("Ошибка"), message: Text(alertMessage))
            }
        }
        .fullScreenCover(isPresented: $showAccountEdit, content: {
            NavigationView {
                AccountEditView(nick: nick, nickWas: nick, showAccountEdit: $showAccountEdit)
            }
            .onDisappear {
                getUserInfoAsync()
            }
        })
        .onAppear {
            getUserInfoAsync()
        }
    }
    
    func removePinFileAsync() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            removePinFile()
            DispatchQueue.main.async {
                isLoading = false
                if fileRemoved {
                    GlobalObjs.email = ""
                    switcher = .enterEmail
                } else {
                    alertMessage = "Ошибка"
                    showAlert = true
                }
            }
        }
    }
    
    func removePinFile() {
        let filename = "pinInfo"
        let ext = "txt"
        let DocDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = DocDirURL.appendingPathComponent(filename).appendingPathExtension(ext)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            fileRemoved = true
        } catch let error as NSError {
            print(error)
            fileRemoved = false
        }
    }
    
    func getUserInfoAsync() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            getUserInfo(email: GlobalObjs.email)
            DispatchQueue.main.async {
                isLoading = false
            }
        }
    }
    
    func getUserInfo(email: String) {
        let urlString = appURL + "?mission=get_user_info&email=" + email
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["get_user_info"] as! [[String : Any]]
                    print(json)
                    print("AccountView.getUserInfo(): \(info)")
                    if info[0]["server_error"] != nil {
                        alertMessage = "Ошибка сервера"
                        showAlert = true
                    } else {
                        alertMessage = ""
                        nick = info[0]["nick"] as! String
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
