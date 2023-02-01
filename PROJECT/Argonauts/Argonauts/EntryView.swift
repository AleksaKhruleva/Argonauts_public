//
//  EntryView.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 21.06.2021.
//

import SwiftUI

struct EntryView: View {
    @State var switcher: Views
    
    var body: some View {
        if switcher == .enterEmail {
            EnterEmailView(switcher: $switcher) // ввод email'a
        } else if switcher == .enterPassCode {
            EnterPassCodeView(switcher: $switcher) // ввода кода из письма
        } else if switcher == .setPin {
            SetPinView(switcher: $switcher) // ввода пина
        } else if switcher == .repeatPin {
            RepeatPinView(switcher: $switcher) // подтверждение пина
        } else if switcher == .createAccount {
            CreateAccountView(switcher: $switcher) // создание аккаунта
        } else if switcher == .addTransp {
            AddTranspView(switcher: $switcher) // добавление автомобиля
        } else if switcher == .home {
            HomeView(switcher: $switcher) // домашний экран
        } else if switcher == .enterPin {
            EnterPinView(switcher: $switcher) // ввод пин-кода
        }
    }
}
