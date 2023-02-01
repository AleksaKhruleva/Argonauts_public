//
//  TranspAddView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 03.07.2021.
//

import SwiftUI

struct TranspAddView: View {
    @Binding var isPresented: Bool
    
    @State var alertMessage: String = ""
    @State var tid: Int = 0
    @State var nick: String = ""
    @State var producted: String = ""
    @State var mileage: String = ""
    @State var engHour: String = ""
    @State var diagDate: Date = Date()
    @State var osagoDate: Date = Date()
    
    @State var showAlert: Bool = false
    @State var isLoading: Bool = false
    @State var showTranspAddNot: Bool = false
    
    @State var isOn4: Bool = false
    @State var isOn5: Bool = false
    
    var limitRange: ClosedRange<Date> {
        let fiftyYearsAgo = Calendar.current.date(byAdding: .year, value: -50, to: Date())!
        return fiftyYearsAgo...Date()
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                Text("Обязательное поле")
                    .font(.title2.weight(.semibold))
                TextField("Ник", text: $nick)
                    .font(.title3)
                    .disableAutocorrection(true)
                    .padding([.leading, .trailing])
                HStack {
                    Text("Рекомендуем использовать регистрационный номер")
                        .font(.system(size: 12))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding([.leading, .trailing])
                .padding([.bottom], 5)
                HStack {
                    Text("Допустимые символы: A-Za-zА-Яа-я0-9_-")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding([.leading, .trailing])
                HStack {
                    Text("Длина: от 1 до 16 знаков")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding([.leading, .trailing])
                .padding([.bottom], 10)
                Group {
                    Text("Дополнительные поля")
                        .font(.title2.weight(.semibold))
                    TextField("Год выпуска (4 знака)", text: $producted)
                        .font(.title3)
                        .keyboardType(.numberPad)
                        .padding([.leading, .trailing])
                    TextField("Текущий пробег (до 9 знаков)", text: $mileage)
                        .font(.title3)
                        .keyboardType(.numberPad)
                        .padding([.leading, .trailing])
                    TextField("Моточасы (до 9 знаков)", text: $engHour)
                        .font(.title3)
                        .keyboardType(.numberPad)
                        .padding([.leading, .trailing])
                    HStack {
                        Text("Дата диагностической карты")
                            .font(.title3)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Toggle("", isOn: $isOn4)
                            .labelsHidden()
                    }
                    .padding([.leading, .trailing])
                    DatePicker("", selection: $diagDate, in: limitRange, displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .disabled(!isOn4)
                    HStack {
                        Text("Дата ОСАГО")
                            .font(.title3)
                        Spacer()
                        Toggle("", isOn: $isOn5)
                            .labelsHidden()
                    }
                    .padding([.leading, .trailing])
                    DatePicker("", selection: $osagoDate, in: limitRange, displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .disabled(!isOn5)
                }
            }
            if isLoading {
                LoadingView()
            }
        }
        .alert(isPresented: $showAlert) {
            if alertMessage == "Добавить уведомления?" {
                return Alert(title: Text("Уведомления"), message: Text(alertMessage), primaryButton: .default(Text("Позже")) {
                    isPresented = false
                }, secondaryButton: .default(Text("Добавить")) {
                    showTranspAddNot = true
                })
            } else {
                return Alert(title: Text("Ошибка"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    alertMessage = ""
                })
            }
        }
        .fullScreenCover(isPresented: $showTranspAddNot, content: {
            NavigationView {
                TranspAddNotification(tid: tid, nick: nick, isPresented: $isPresented, showTranspAddNot: $showTranspAddNot)
            }
        })
        .navigationBarTitle("Добавление", displayMode: .inline)
        .navigationBarItems(
            leading:
                Button(action: {
                    isPresented = false
                }, label: {
                    Text("Отм.")
                }),
            trailing:
                Button(action: {
                    addTranspAsync()
                }, label: {
                    Text("Доб.")
                })
                .disabled(nick.isEmpty)
        )
    }
    
    func isValidNick(nick: String) -> Bool {
        do {
            let regEx = "^[A-Za-zА-Яа-я0-9_-]{1,16}$"
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
    
    func isValidYear(year: String) -> Bool {
        do {
            let yearRegEx =  "^[1-9]{1}[0-9]{3}$"
            let regex = try NSRegularExpression(pattern: yearRegEx)
            let nsString = year as NSString
            let results = regex.matches(in: year, range: NSRange(location: 0, length: nsString.length))
            if results.count != 1 {
                return false
            }
            return true
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    func isValidMileage(mileage: String) -> Bool {
        do {
            let regEx = "^[0-9]{1,9}$"
            let regex = try NSRegularExpression(pattern: regEx)
            let nsString = mileage as NSString
            let results = regex.matches(in: mileage, range: NSRange(location: 0, length: nsString.length))
            if results.count != 1 {
                return false
            }
            return true
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    func isValidEngHour(engHour: String) -> Bool {
        do {
            let regEx = "^[0-9]{1,9}$"
            let regex = try NSRegularExpression(pattern: regEx)
            let nsString = engHour as NSString
            let results = regex.matches(in: engHour, range: NSRange(location: 0, length: nsString.length))
            if results.count != 1 {
                return false
            }
            return true
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    func canAddTransp() -> Bool {
        if isValidNick(nick: nick) {
            if producted.isEmpty || isValidYear(year: producted) {
                if mileage.isEmpty || isValidMileage(mileage: mileage) {
                    if engHour.isEmpty || isValidEngHour(engHour: engHour) {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func addTranspAsync() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            if canAddTransp() {
                addTransp(email: GlobalObjs.email, nick: nick, producted: producted, mileage: mileage, engHour: engHour, diagDate: diagDate, osagoDate: osagoDate)
            } else {
                alertMessage = "Введены некорректные данные"
                showAlert = true
            }
            DispatchQueue.main.async {
                if alertMessage == "" {
                    alertMessage = "Добавить уведомления?"
                    showAlert = true
                }
                isLoading = false
            }
        }
    }
    
    func addNotification(tid: String, dataType: String, mode: String, date: Date, value1: String, value2: String, notification: String) {
        var dateComponent = DateComponents()
        dateComponent.day = 335
        let dateExp = Calendar.current.date(byAdding: dateComponent, to: date)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru")
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: dateExp ?? Date())
        
        let urlString = appURL + "?mission=add_notification&tid=" + tid + "&type=" + dataType + "&mode=" + mode + "&date=" + dateString + "&notification=" + notification
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["add_notification"] as! [String : Any]
                    print("ServiceMaterialView.addNotification(): \(info)")
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
    
    func addTransp(email: String, nick: String, producted: String, mileage: String, engHour: String, diagDate: Date, osagoDate: Date) {
        var diagDateStr = ""
        var osagoDateStr = ""
        if isOn4 {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru")
            formatter.dateFormat = "YYYY-MM-dd"
            diagDateStr = formatter.string(from: diagDate)
        }
        if isOn5 {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru")
            formatter.dateFormat = "YYYY-MM-dd"
            osagoDateStr = formatter.string(from: osagoDate)
        }
        let urlString = appURL + "?mission=add_transp&email=" + email + "&nick=" + nick + "&producted=" + producted + "&mileage=" + mileage + "&eng_hour=" + engHour + "&diag_date=" + diagDateStr + "&osago_date=" + osagoDateStr
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["add_transp"] as! [String : Any]
                    print("TranspAddView.addTransp(): \(info)")
                    if info["server_error"] != nil {
                        if info["err_code"] as! Int == 1062 {
                            alertMessage = "Транспортное средство с таким ником уже есть"
                        } else {
                            alertMessage = "Ошибка сервера, попробуйте ещё раз позже"
                        }
                        showAlert = true
                    } else {
                        if info["mileage"] != nil {
                            let dop = info["mileage"] as! [String : Any]
                            if dop["server_error"] != nil {
                                alertMessage = "Ошибка сервера"
                            }
                        }
                        if info["eng_hour"] != nil {
                            let dop = info["eng_hour"] as! [String : Any]
                            if dop["server_error"] != nil {
                                alertMessage = "Ошибка сервера"
                            }
                        }
                        if alertMessage != "" {
                            showAlert = true
                        } else {
                            tid = info["tid"] as! Int
                            if isOn4 {
                                addNotification(tid: String(tid), dataType: "D", mode: "1", date: diagDate, value1: "", value2: "", notification: "Истекает срок действия диагностической карты")
                            }
                            if isOn5 {
                                addNotification(tid: String(tid), dataType: "D", mode: "2", date: osagoDate, value1: "", value2: "", notification: "Истекает срок действия полиса ОСАГО")
                            }
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
}
