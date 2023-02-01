//
//  HomeView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 25.06.2021.
//

import SwiftUI

struct HomeView: View {
    @Binding var switcher: Views
    @State var selection: String = "Заправка"
    
    @State var showTranspAdd: Bool = false
    @State var showAccountEdit: Bool = false
    @State var exitButTap: Bool = false
    
    var body: some View {
        NavigationView {
            TabView(selection: $selection) {
                TransportsView(showTranspAdd: $showTranspAdd)
                    .tabItem {
                        Label("Транспорт", systemImage: "car.fill")
                    }
                    .tag("Транспорт")
                
                HubView()
                    .tabItem {
                        Label("Центр", systemImage: "square.grid.2x2.fill")
                    }
                    .tag("Центр")
                
                ServiceView()
                    .tabItem {
                        Label("Сервис", systemImage: "wrench.and.screwdriver.fill")
                    }
                    .tag("Сервис")
                
                FuelView()
                    .tabItem {
                        Label("Заправка", systemImage: "drop.fill")
                    }
                    .tag("Заправка")
                
                AccountView(switcher: $switcher, showAccountEdit: $showAccountEdit, exitButTap: $exitButTap)
                    .tabItem {
                        Label("Аккаунт", systemImage: "person.fill")
                    }
                    .tag("Аккаунт")
            }
            .navigationTitle(selection)
            .navigationBarItems(leading: Button(action: {
                switch selection {
                case "Аккаунт":
                    exitButTap = true
                default:
                    print("none")
                }
            }, label: {
                switch selection {
                case "Аккаунт":
                    Text("Выйти")
                        .font(.title3)
                default:
                    Text("")
                }
            }), trailing: Button(action: {
                switch selection {
                case "Транспорт":
                    showTranspAdd = true
                case "Аккаунт":
                    showAccountEdit = true
                default:
                    print("none")
                }
            }, label: {
                switch selection {
                case "Транспорт":
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                case "Аккаунт":
                    Text("Изм.")
                        .font(.title3)
                default:
                    Text("")
                }
            }))
        }
    }
}
