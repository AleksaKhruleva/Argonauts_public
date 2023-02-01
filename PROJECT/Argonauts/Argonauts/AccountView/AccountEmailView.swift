//
//  EmailView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 20.07.2021.
//

import SwiftUI

struct AccountEmailView: View {
    @State var email: String
    @Binding var switcher: Views
    
    @State var alertMessage: String = ""
    @State var send: Int = -1
    @State var selectedEmail: String = ""
    @State var newEmail: String = ""
    @State var code: String = ""
    @State var sentCode: String = ""
    @State var emails: [Email] = []
    
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State var showFields: Bool = false
    @State var codeSent: Bool = false
    @State var fileRemoved: Bool = false
    
    @State private var timeRemaining = 60
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            VStack {
                if showFields {
                    TextField("Email", text: $newEmail, onEditingChanged: { _ in  }, onCommit: {
                        if isValidEmail(email: newEmail) {
                            connectDeviceAsync()
                            codeSent = true
                        } else {
                            alertMessage = "Введён некорректный email"
                            showAlert = true
                        }
                    })
                        .font(.title3)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .padding([.leading, .trailing, .top])
                    if codeSent {
                        TextField("Код", text: $code)
                            .font(.title3)
                            .keyboardType(.numberPad)
                            .padding([.leading, .trailing, .top])
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
                        .frame(height: UIScreen.main.bounds.height / 10)
                        .disabled(timeRemaining > 0)
                        Button(action: {
                            if code == sentCode {
                                addEmailAsync()
                            } else {
                                alertMessage = "Неверный код, попробуйте снова"
                                showAlert = true
                            }
                        }, label: {
                            Text("Подтвердить")
                                .font(.title3.weight(.semibold))
                        })
                            .disabled(code.isEmpty)
                    } else {
                        Button(action: {
                            if isValidEmail(email: newEmail) {
                                connectDeviceAsync()
                                codeSent = true
                                timeRemaining = 60
                            } else {
                                alertMessage = "Введён некорректный email"
                                showAlert = true
                            }
                        }, label: {
                            Text("Продолжить")
                                .font(.title3.weight(.semibold))
                        })
                            .disabled(newEmail.isEmpty)
                    }
                }
                List {
                    ForEach(emails, id: \.eid) { email in
                        HStack {
                            Text(email.email)
                            Spacer()
                            Button(action: {
                                selectedEmail = email.email
                                if email.send == 0 {
                                    send = 1
                                } else {
                                    send = 0
                                }
                                changeEmailSendAsync()
                            }, label: {
                                Image(systemName: email.send == 0 ? "envelope" : "envelope.fill")
                                    .font(.title3)
                            })
                                .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .onDelete(perform: deleteEmailAsync)
                }
            }
            .listStyle(PlainListStyle())
            if isLoading {
                LoadingView()
            }
        }
        .onReceive(timer) { time in
            if self.timeRemaining > 0 && codeSent == true {
                self.timeRemaining -= 1
            }
        }
        .navigationBarTitle("Почта", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            newEmail = ""
            codeSent = false
            showFields.toggle()
        }, label: {
            if showFields {
                Image(systemName: "minus")
                    .font(.title2.weight(.semibold))
            } else {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
            }
        }))
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Ошибка"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                alertMessage = ""
            })
        }
        .onAppear {
            getEmailAsync()
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
    
    func getEmailAsync() {
        isLoading = true
        emails = []
        DispatchQueue.global(qos: .userInitiated).async {
            getEmail(email: email)
            DispatchQueue.main.async {
                isLoading = false
            }
        }
    }
    
    func addEmailAsync() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            addEmail(email: email, newEmail: newEmail)
            DispatchQueue.main.async {
                if alertMessage == "" {
                    codeSent = false
                    newEmail = ""
                    code = ""
                } else if alertMessage == "Такая почта уже есть в базе" {
                    codeSent = false
                    code = ""
                }
                isLoading = false
            }
        }
    }
    
    func deleteEmailAsync(at offsets: IndexSet) {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let index = offsets[offsets.startIndex]
            email = emails[index].email
            deleteEmail(email: email)
            if alertMessage == "" && email == GlobalObjs.email {
                removePinFile()
            }
            DispatchQueue.main.async {
                if alertMessage == "" {
                    if fileRemoved {
                        emails.remove(at: index)
                        GlobalObjs.email = ""
                        GlobalObjs.codeConf = ""
                        GlobalObjs.enterCode = false
                        switcher = .enterEmail
                    } else {
                        emails.remove(at: index)
                    }
                }
                isLoading = false
            }
        }
    }
    
    func connectDeviceAsync() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            sentCode = generatePassCode()
            connectDevice(email: newEmail, code: sentCode)
            DispatchQueue.main.async {
                if alertMessage == "" {
                    codeSent = true
                }
                isLoading = false
            }
        }
    }
    
    func changeEmailSendAsync() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            changeEmailSend(email: selectedEmail, send: String(send))
            emails = []
            getEmail(email: GlobalObjs.email)
            DispatchQueue.main.async {
                isLoading = false
            }
        }
    }
    
    func changeEmailSend(email: String, send: String) {
        let urlString = appURL + "?mission=change_email_send&email=" + email + "&send=" + send
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["change_email_send"] as! [String : Any]
                    print("AccountEmailView.update(): \(info)")
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
    
    func getEmail(email: String) {
        let urlString = appURL + "?mission=get_email&email=" + email
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["get_email"] as! [[String : Any]]
                    print("AccountEmailView.getUserEmail(): \(info)")
                    if info[0]["server_error"] != nil {
                        alertMessage = "Ошибка сервера"
                        showAlert = true
                    } else {
                        for el in info {
                            emails.append(Email(eid: el["eid"] as! Int, email: el["email"] as! String, send: el["send"] as! Int))
                        }
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
    
    func addEmail(email: String, newEmail: String) {
        let urlString = appURL + "?mission=add_email&email=" + email + "&new_email=" + newEmail
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["add_email"] as! [String : Any]
                    print("AccountEmailView.addEmail(): \(info)")
                    if info["server_error"] != nil {
                        if info["err_code"] as! Int == 1062 {
                            alertMessage = "Такая почта уже есть в базе"
                        } else {
                            alertMessage = "Ошибка сервера"
                        }
                        showAlert = true
                    } else {
                        emails.append(Email(eid: info["eid"] as! Int, email: info["new_email"] as! String, send: info["send"] as! Int))
                        print(info["send"] as! Int)
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
    
    func deleteEmail(email: String) {
        let urlString = appURL + "?mission=delete_email&email=" + email
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["delete_email"] as! [String : Any]
                    print("AccountEmailView.deleteEmail(): \(info)")
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
    
    func connectDevice(email: String, code: String) {
        let urlString = appURL + "?mission=connect_device&email=" + email + "&code=" + code
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let dop = json["connect_device"] as! [String : Any]
                    print("EnterEmailView.connectDevice(): \(dop)")
                    if dop["server_error"] != nil {
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
