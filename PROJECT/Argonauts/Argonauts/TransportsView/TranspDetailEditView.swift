//
//  TranspInfoEditView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 01.07.2021.
//

import SwiftUI

struct TranspDetailEditView: View {
    @Binding var isPresented: Bool
    @State var tid: String
    @State var nick: String
    @State var producted: String
    @State var diagDate: Date
    @State var osagoDate: Date
    @State var diagDateStr: String
    @State var osagoDateStr: String
    @State var keys: [String] = ["Ник", "Год выпуска", "Пробег", "Моточасы", "Дата диагностической карты", "Дата ОСАГО"]
    @State var diagDateChanged: Bool
    @State var osagoDateChanged: Bool
    
    @State var alertMessage: String = ""
    @State var nickWas: String = ""
    @State var productedWas: String = ""
    @State var diagDateWas: Date = Date()
    @State var osagoDateWas: Date = Date()
    @State var diagDateChangedWas: Bool = false
    @State var osagoDateChangedWas: Bool = false
    
    @State var showAlert: Bool = false
    @State var isLoading: Bool = false
    
    var limitRange: ClosedRange<Date> {
        let fiftyYearsAgo = Calendar.current.date(byAdding: .year, value: -50, to: Date())!
        
        return fiftyYearsAgo...Date()
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                Divider()
                HStack {
                    Text(keys[0])
                        .fontWeight(.semibold)
                        .padding([.leading])
                    TextField(keys[0], text: $nick)
                        .multilineTextAlignment(.trailing)
                        .disableAutocorrection(true)
                        .padding([.trailing])
                }
                Divider()
                HStack {
                    Text(keys[1])
                        .fontWeight(.semibold)
                        .padding([.leading])
                    TextField(keys[1], text: $producted)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .padding([.trailing])
                }
                Divider()
                HStack {
                    Text(keys[4])
                        .fontWeight(.semibold)
                        .padding([.leading])
                    Spacer()
                    Toggle("", isOn: $diagDateChanged)
                        .labelsHidden()
                        .padding([.trailing])
//                        .disabled(diagDateChangedWas)
                }
                DatePicker("", selection: $diagDate, in: limitRange, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .disabled(!diagDateChanged)
                Divider()
                HStack {
                    Text(keys[5])
                        .fontWeight(.semibold)
                        .padding([.leading])
                    Spacer()
                    Toggle("", isOn: $osagoDateChanged)
                        .labelsHidden()
                        .padding([.trailing])
//                        .disabled(osagoDateChangedWas)
                }
                DatePicker("", selection: $osagoDate, in: limitRange, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .disabled(!osagoDateChanged)
            }
            if isLoading {
                LoadingView()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Ошибка"), message: Text(alertMessage))
        }
        .navigationBarTitle("Детали", displayMode: .inline)
        .navigationBarItems(
            leading:
                Button(action: {
                    isPresented = false
                }, label: {
                    Text("Отм.")
                }),
            trailing:
                Button(action: {
                    updateTranspInfoAsync()
                }, label: {
                    Text("Сохр.")
                })
                .disabled(nickWas == nick && productedWas == producted && (diagDateChangedWas == diagDateChanged && diagDateWas == diagDate) && (osagoDateChangedWas == osagoDateChanged && osagoDateWas == osagoDate))
        )
        .onAppear {
            nickWas = nick
            productedWas = producted
            diagDateWas = diagDate
            osagoDateWas = osagoDate
            diagDateChangedWas = diagDateChanged
            osagoDateChangedWas = osagoDateChanged
        }
    }
    
    func updateTranspInfoAsync() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let isValidYear = isValidYear(year: producted)
            let isValidNick = isValidNick(nick: nick)
            if (isValidYear || producted == "") && isValidNick {
                diagDateStr = ""
                osagoDateStr = ""
                if diagDateChanged == true {
                    diagDateStr = convertDateToString(date: diagDate)
                }
                if osagoDateChanged == true {
                    osagoDateStr = convertDateToString(date: osagoDate)
                }
                updateTranspInfo(tid: tid, nick: nick, producted: producted, diagDate: diagDateStr, osagoDate: osagoDateStr)
                if alertMessage == "" {
                    if diagDateChanged {
                        addNotification(tid: String(tid), dataType: "D", mode: "1", date: diagDate, value1: "", value2: "", notification: "Истекает срок действия диагностической карты")
                    }
                    if osagoDateChanged {
                        addNotification(tid: String(tid), dataType: "D", mode: "2", date: osagoDate, value1: "", value2: "", notification: "Истекает срок действия полиса ОСАГО")
                    }
                }
            } else {
                alertMessage = "Введены некорректные данные"
                showAlert = true
            }
            DispatchQueue.main.async {
                if alertMessage == "" {
                    isPresented = false
                }
                isLoading = false
            }
        }
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
    
    func updateTranspInfo(tid: String, nick: String, producted: String, diagDate: String, osagoDate: String) {
        let urlString = appURL + "?mission=update_transp_info&tid=" + tid + "&nick=" + nick + "&producted=" + producted + "&diag_date=" + diagDate + "&osago_date=" + osagoDate
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["update_transp_info"] as! [String : Any]
                    print("TranspDetailEdit.updateTranspInfo(): \(info)")
                    
                    if info["server_error"] != nil {
                        if info["err_code"] as! Int == 1062 {
                            alertMessage = "Транспортное средство с таким ником уже есть"
                            showAlert = true
                        } else {
                            alertMessage = "Ошибка сервера"
                            showAlert = true
                        }
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
