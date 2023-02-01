//
//  MileageDetailView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 07.07.2021.
//

import SwiftUI

struct MileageDetailView: View {
    @State var tid: Int
    @State var nick: String
    
    @State var alertMessage: String = ""
    @State var mileage: String = ""
    @State var date: Date = Date()
    @State var mileages: [Mileage] = []
    
    @State var showAlert: Bool = false
    @State var isLoading: Bool = false
    @State var showFields: Bool = false
    
    var limitRange: ClosedRange<Date> {
        let fiftyYearsAgo = Calendar.current.date(byAdding: .year, value: -50, to: Date())!
        return fiftyYearsAgo...Date()
    }
    
    var body: some View {
        ZStack {
            VStack {
                if showFields {
                    DatePicker("", selection: $date, in: limitRange, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                    TextField("Пробег (до 9 знаков)", text: $mileage)
                        .keyboardType(.numberPad)
                        .padding([.leading, .trailing])
                        .padding([.bottom], 5)
                    Button {
                        UIApplication.shared.endEditing()
                        addMileageAsync()
                    } label: {
                        Text("Добавить")
                    }
                    .disabled(mileage.isEmpty)
                }
                if mileages.isEmpty {
                    Text("Здесь будет список записей о пробеге")
                        .foregroundColor(Color(UIColor.systemGray))
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(mileages, id: \.mid) { mileage in
                            HStack {
                                Text(mileage.date)
                                Spacer()
                                Text("\(mileage.mileage)")
                            }
                        }
                        .onDelete(perform: deleteMileageAsync)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            if isLoading {
                LoadingView()
            }
        }
        .navigationBarTitle(nick, displayMode: .inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    mileage = ""
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
            Alert(title: Text("Ошибка"), message: Text(alertMessage))
        }
        .onAppear {
            getMileageAsync()
        }
    }
    
    func getMileageAsync() {
        isLoading = true
        mileages = []
        DispatchQueue.global(qos: .userInitiated).async {
            getMileage(tid: String(tid))
            DispatchQueue.main.async {
                isLoading = false
            }
        }
    }
    
    func addMileageAsync() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            if isValidMileage(mileage: mileage) {
                addMileage(tid: String(tid), date: date, mileage: mileage)
            } else {
                alertMessage = "Введено некорректное значение"
                showAlert = true
            }
            DispatchQueue.main.async {
                if alertMessage == "" {
                    mileage = ""
                }
                isLoading = false
            }
        }
    }
    
    func deleteMileageAsync(at offsets: IndexSet) {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let index = offsets[offsets.startIndex]
            let mid = mileages[index].mid
            deleteMileage(mid: String(mid), tid: String(tid))
            DispatchQueue.main.async {
                if alertMessage == "" {
                    mileages.remove(at: index)
                }
                isLoading = false
            }
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
    
    func getMileage(tid: String) {
        let urlString = appURL + "?mission=get_mileage&tid=" + tid
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["get_mileage"] as! [[String : Any]]
                    print("MileageDetailView.getMileage(): \(info)")
                    if info.isEmpty {
                        // empty
                    } else if info[0]["server_error"] != nil {
                        alertMessage = "Ошибка сервера"
                        showAlert = true
                    } else {
                        alertMessage = ""
                        for el in info {
                            var date = el["date"] as! String
                            date = date.replacingOccurrences(of: "T", with: " ")
                            date.removeLast(3)
                            date = reverseDateTime(date: date)
                            
                            let mileage = Mileage(mid: el["mid"] as! Int, date: date, mileage: el["mileage"] as! Int)
                            mileages.append(mileage)
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
    
    func addMileage(tid: String, date: Date, mileage: String) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: date)
        let urlString = appURL + "?mission=add_mileage&tid=" + tid + "&date=" + dateString + "&mileage=" + mileage
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["add_mileage"] as! [String : Any]
                    print("MileageDetailView.addMileage(): \(info)")
                    if info["server_error"] != nil {
                        if info["err_code"] as! Int == 1062 {
                            alertMessage = "Запись с таким временем/пробегом уже есть"
                            showAlert = true
                        } else {
                            alertMessage = "Ошибка сервера"
                            showAlert = true
                        }
                    } else if info["mid"] == nil {
                        alertMessage = "Введены некорректные данные"
                        showAlert = true
                    } else {
                        alertMessage = ""
                        let date = reverseDateTime(date: dateString)
                        mileages.append(Mileage(mid: info["mid"] as! Int, date: date, mileage: info["mileage"] as! Int))
                        mileages.sort { $0.mileage > $1.mileage }
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
    
    func deleteMileage(mid: String, tid: String) {
        let urlString = appURL + "?mission=delete_mileage&mid=" + mid + "&tid=" + tid
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["delete_mileage"] as! [String : Any]
                    print("MileageDetailView.deleteMileage(): \(info)")
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
