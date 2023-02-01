//
//  TransportsView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 29.06.2021.
//

import SwiftUI

struct TransportsView: View {
    @Binding var showTranspAdd: Bool
    
    @State var alertMessage: String = ""
    @State var tid: Int = 0
    @State var nick: String = ""
    @State var transports: [Transport] = []
    
    @State var showTranspDetail: Bool = false
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                NavigationLink(destination: TranspDetailView(tid: tid, nick: nick), isActive: $showTranspDetail, label: { EmptyView() })
                List(transports) { transport in
                    Button(action: {
                        tid = transport.tid
                        nick = transport.nick
                        showTranspDetail = true
                    }, label: {
                        Text(transport.nick)
                    })
                }
                .listStyle(PlainListStyle())
            }
            if isLoading {
                LoadingView()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Ошибка"), message: Text(alertMessage))
        }
        .fullScreenCover(isPresented: $showTranspAdd) {
            NavigationView {
                TranspAddView(isPresented: $showTranspAdd)
            }
            .onDisappear {
                getTidTnickAsync()
            }
        }
        .onAppear {
            getTidTnickAsync()
        }
    }
    
    func getTidTnickAsync() {
        isLoading = true
        transports = []
        DispatchQueue.global(qos: .userInitiated).async {
            getTidTnick(email: GlobalObjs.email)
            DispatchQueue.main.async {
                isLoading = false
            }
        }
    }
    
    func getTidTnick(email: String) {
        let urlString = appURL + "?mission=get_tid_tnick&email=" + email
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: encodedUrl!)
        if let data = try? Data(contentsOf: url!) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let info = json["tid_nick"] as! [[String : Any]]
                    print("TransportsView.getTidTnick(): \(info)")
                    if info.isEmpty {
                        // empty
                    } else if info[0]["server_error"] != nil {
                        alertMessage = "Ошибка сервера"
                        showAlert = true
                    } else {
                        alertMessage = ""
                        for el in info {
                            let transport = Transport(tid: el["tid"] as! Int, nick: el["nick"] as! String, producted: nil, mileage: nil, engHours: nil, diagDate: nil, osagoDate: nil, totalFuel: nil, fuelDate: nil)
                            transports.append(transport)
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

