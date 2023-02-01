//
//  ServiceDetailView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 14.07.2021.
//

import SwiftUI

struct ServiceDetailView: View {
    @State var tid: Int
    @State var nick: String
    
    @State var alertMessage: String = ""
    @State var date: Date = Date()
    @State var serType: String = "Ремонт"
    @State var mileage: String = ""
    @State var matCost: String = ""
    @State var wrkCost: String = ""
    @State var sid: Int = 0
    @State var services: [Service] = []
    
    @State var showAlert: Bool = false
    @State var isLoading: Bool = false
    @State var showFields: Bool = false
    @State var showServiceMaterial: Bool = false
    
    var body: some View {
        ZStack {
            NavigationLink(destination: ServiceMaterialView(sid: sid), isActive: $showServiceMaterial, label: { EmptyView() })
            VStack {
                if showFields {
                    ScrollView(showsIndicators: false) {
                        DatePicker("", selection: $date, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                        Picker("", selection: $serType) {
                            Text("Ремонт").tag("Ремонт")
                            Text("Тех. обслуживание").tag("Тех. обслуживание")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .labelsHidden()
                        .padding([.leading, .trailing])
                        TextField("Пробег (до 9 знаков)", text: $mileage)
                            .keyboardType(.numberPad)
                            .padding([.leading, .trailing])
                        TextField("Стоимость материалов (доп)", text: $matCost)
                            .keyboardType(.decimalPad)
                            .padding([.leading, .trailing])
                        HStack {
                            Text("Длина: до 9 знаков перед запятой, до 2 знаков после запятой")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding([.leading, .trailing])
                        TextField("Стоимость работ (доп)", text: $wrkCost)
                            .keyboardType(.decimalPad)
                            .padding([.leading, .trailing])
                        HStack {
                            Text("Длина: до 9 знаков перед запятой, до 2 знаков после запятой")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding([.leading, .trailing])
                        .padding([.bottom], 5)
                        Button {
                            UIApplication.shared.endEditing()
                            addServiceAsync()
                        } label: {
                            Text("Добавить")
                        }
                        .disabled(mileage.isEmpty)
                        .padding([.bottom], 70)
                    }
                    .frame(height: UIScreen.main.bounds.height / 1.5)
                    Spacer()
                }
                if services.isEmpty {
                    Text("Здесь будет список записей о сервисных работах")
                        .foregroundColor(Color(UIColor.systemGray))
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(services, id: \.sid) { service in
                            Button(action: {
                                sid = service.sid
                                showServiceMaterial = true
                            }, label: {
                                RowService(service: service)
                            })
                        }
                        .onDelete(perform: deleteServiceAsync)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            if isLoading {
                LoadingView()
            }
        }
        .navigationBarTitle(nick, displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            mileage = ""
            matCost = ""
            wrkCost = ""
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
            getServiceAsync()
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
    
    func isValid(value: String) -> Bool {
        do {
            let regEx = "(^[0-9]{1,9}$)|(^[0-9]{1,9}[',']{1}[0-9]{1,2}$)"
            let regex = try NSRegularExpression(pattern: regEx)
            let nsString = value as NSString
            let results = regex.matches(in: value, range: NSRange(location: 0, length: nsString.length))
            if results.count != 1 {
                return false
            }
            return true
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
        
    }
    
    func canAddService() -> Bool {
        if isValidMileage(mileage: mileage) {
            if matCost.isEmpty == true && wrkCost.isEmpty == true {
                return true
            } else if matCost.isEmpty == false && wrkCost.isEmpty == true {
                if isValid(value: matCost) {
                    return true
                }
            } else if matCost.isEmpty == true && wrkCost.isEmpty == false {
                if isValid(value: wrkCost) {
                    return true
                }
            } else if matCost.isEmpty == false && wrkCost.isEmpty == false {
                if isValid(value: matCost) && isValid(value: wrkCost) {
                    return true
                }
            }
        }
        return false
    }
    
    func getServiceAsync() {
        isLoading = true
        services = []
        DispatchQueue.global(qos: .userInitiated).async {
            getService(tid: String(tid))
            DispatchQueue.main.async {
                isLoading = false
            }
        }
    }
    
    func addServiceAsync() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            if canAddService() {
                addService(tid: String(tid), date: date, serType: serType, mileage: mileage, matCost: matCost.replacingOccurrences(of: ",", with: "."), wrkCost: wrkCost.replacingOccurrences(of: ",", with: "."))
            } else {
                alertMessage = "Введены некорректные данные"
                showAlert = true
            }
            DispatchQueue.main.async {
                if alertMessage == "" {
                    mileage = ""
                    matCost = ""
                    wrkCost = ""
                }
                isLoading = false
            }
        }
    }
    
    func deleteServiceAsync(at offsets: IndexSet) {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let index = offsets[offsets.startIndex]
            let sid = services[index].sid
            deleteService(sid: String(sid), tid: String(tid))
            DispatchQueue.main.async {
                if alertMessage == "" {
                    services.remove(at: index)
                }
                isLoading = false
            }
        }
    }
    
    func getService(tid: String) {
        let urlString = appURL + "?mission=get_service&tid=" + tid
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["get_service"] as! [[String : Any]]
                    print("ServiceDetailView.getService(): \(info)")
                    if info.isEmpty {
                        // empty
                    } else if info[0]["server_error"] != nil {
                        alertMessage = "Ошибка сервера"
                        showAlert = true
                    } else {
                        for el in info {
                            var date = el["date"] as! String
                            date = date.replacingOccurrences(of: "T", with: " ")
                            date.removeLast(3)
                            
                            let service = Service(sid: el["sid"] as! Int, date: date, serType: el["ser_type"] as! String, mileage: el["mileage"] as? Int, matCost: el["mat_cost"] as? Double, wrkCost: el["wrk_cost"] as? Double)
                            services.append(service)
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
    
    func addService(tid: String, date: Date, serType: String, mileage: String, matCost: String, wrkCost: String) {
        print(mileage, matCost, wrkCost)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: date)
        let urlString = appURL + "?mission=add_service&tid=" + tid + "&date=" + dateString + "&ser_type=" + serType + "&mileage=" + mileage + "&mat_cost=" + matCost + "&wrk_cost=" + wrkCost
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["add_service"] as! [String : Any]
                    print("ServiceDetailView.addService(): \(info)")
                    if info["server_error"] != nil {
                        if info["err_code"] as! Int == 1062 {
                            alertMessage = "Запись с таким временем/пробегом уже есть"
                            showAlert = true
                        } else {
                            alertMessage = "Ошибка сервера"
                            showAlert = true
                        }
                    } else if info["sid"] == nil {
                        alertMessage = "Введены некорректные данные"
                        showAlert = true
                    } else {
                        let service = Service(sid: info["sid"] as! Int, date: info["date"] as! String, serType: info["ser_type"] as! String, mileage: info["mileage"] as? Int, matCost: info["mat_cost"] as? Double, wrkCost: info["wrk_cost"] as? Double)
                        services.append(service)
                        services.sort { $0.date > $1.date }
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
    
    func deleteService(sid: String, tid: String) {
        let urlString = appURL + "?mission=delete_service&sid=" + sid + "&tid=" + tid
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["delete_service"] as! [String : Any]
                    print("ServiceDetailView.deleteService(): \(info)")
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
}
