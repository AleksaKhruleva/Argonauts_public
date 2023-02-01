//
//  HubView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 14.07.2021.
//

import SwiftUI

struct HubView: View {
    @State var showEngHourView: Bool = false
    @State var showMileageView: Bool = false
    @State var showNotificationView: Bool = false
    @State var showStatisticsView: Bool = false
    
    var body: some View {
        VStack {
            Group {
                NavigationLink(destination: EngHourView(), isActive: $showEngHourView, label: { EmptyView() })
                NavigationLink(destination: MileageView(), isActive: $showMileageView, label: { EmptyView() })
                NavigationLink(destination: NotificationView(), isActive: $showNotificationView, label: { EmptyView() })
                NavigationLink(destination: StatisticsView(), isActive: $showStatisticsView, label: { EmptyView() })
            }
            Spacer()
            Button(action: {
                showEngHourView = true
            }, label: {
                Text("Моточасы")
                    .font(.title2.weight(.medium))
                    .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.height / 8, alignment: .center)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.reverseColor)
                    .cornerRadius(UIScreen.main.bounds.width * 0.05)
            })
            Spacer()
            Button(action: {
                showMileageView = true
            }, label: {
                Text("Пробег")
                    .font(.title2.weight(.medium))
                    .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.height / 8, alignment: .center)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.reverseColor)
                    .cornerRadius(UIScreen.main.bounds.width * 0.05)
            })
            Spacer()
            Button(action: {
                showNotificationView = true
            }, label: {
                Text("Уведомления")
                    .font(.title2.weight(.medium))
                    .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.height / 8, alignment: .center)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.reverseColor)
                    .cornerRadius(UIScreen.main.bounds.width * 0.05)
            })
            Spacer()
            Button(action: {
                showStatisticsView = true
            }, label: {
                Text("Статистика")
                    .font(.title2.weight(.medium))
                    .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.height / 8, alignment: .center)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.reverseColor)
                    .cornerRadius(UIScreen.main.bounds.width * 0.05)
            })
            Spacer()
        }
    }
}
