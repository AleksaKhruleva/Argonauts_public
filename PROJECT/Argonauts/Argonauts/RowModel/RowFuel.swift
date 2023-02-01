//
//  RowFuel.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 29.07.2021.
//

import SwiftUI

struct RowFuel: View {
    @State var fuel: Fuel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Дата:")
                    .fontWeight(.semibold)
                Text(reverseDateTime(date: fuel.date))
            }
            HStack {
                Text("Топливо:")
                    .fontWeight(.semibold)
                Text(String(format: "%.2f", fuel.fuel).replacingOccurrences(of: ".", with: ","))
            }
            if let mileage = fuel.mileage {
                HStack {
                    Text("Пробег:")
                        .fontWeight(.semibold)
                    Text(String(describing: mileage))
                }
            }
            if let fillBrand = fuel.fillBrand {
                HStack {
                    Text("Бренд заправки:")
                        .fontWeight(.semibold)
                    Text(fillBrand)
                }
            }
            if let fuelBrand = fuel.fuelBrand {
                HStack {
                    Text("Марка топлива:")
                        .fontWeight(.semibold)
                    Text(fuelBrand)
                }
            }
            if let fuelCost = fuel.fuelCost {
                HStack {
                    Text("Стоимость 1 литра:")
                        .fontWeight(.semibold)
                    Text(String(format: "%.2f", fuelCost).replacingOccurrences(of: ".", with: ","))
                }
            }
        }
    }
}

struct RowFuel_Previews: PreviewProvider {
    static var previews: some View {
        RowFuel(fuel: Fuel(fid: 0, date: "2020-01-02 20:00", fuel: 123.12, mileage: 200, fillBrand: "Газпром", fuelBrand: "A-96", fuelCost: 49.89))
    }
}
