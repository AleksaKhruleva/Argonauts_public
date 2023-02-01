//
//  File.swift
//  Argonauts
//
//  Created by Aleksa Khruleva on 23.06.2021.
//

import Foundation
import SwiftUI
import UIKit
import LocalAuthentication

enum numPadButton: String {
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case zero = "0"

    case bio = "bio"
    case del = "delete.left"
    case dop = ""
}

enum Views: String {
    case enterEmail = "EnterEmailView"
    case enterPassCode = "EnterPassCodeView"
    case setPin = "SetPinView"
    case repeatPin = "RepeatPinView"
    case createAccount = "CreateAccountView"
    case addTransp = "AddTranspView"
    case home = "HomeView"
    case enterPin = "EnterPinView"
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

func writeToDocDir(filename: String, text: String) {
    let ext = "txt"
    let docDirUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let fileUrl = docDirUrl.appendingPathComponent(filename).appendingPathExtension(ext)

    do {
        try text.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
    } catch let error as NSError {
        print("writeToDocDir(): error \(error)")
    }
}

func isValidEmail(email: String) -> Bool {
    var isValid: Bool = true
    do {
        let emailRegEx =  "^[A-Z0-9a-z._-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let regex = try NSRegularExpression(pattern: emailRegEx)
        let nsString = email as NSString
        let results = regex.matches(in: email, range: NSRange(location: 0, length: nsString.length))
        if results.count != 1 { isValid = false }
    } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
        isValid = false
    }
    return isValid
}

func convertDateToString(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru")
    formatter.dateFormat = "yyyy-MM-dd"
    let str = formatter.string(from: date)
    return str
}

func reverseDateTime(date: String) -> String {
    let comp = date.replacingOccurrences(of: " ", with: "-").components(separatedBy: "-")
    let revDate = comp[3] + " " + comp[2] + "." + comp[1] + "." + comp[0]
    return revDate
}

func reverseDate(date: String) -> String {
    let comp = date.components(separatedBy: "-")
    let revDate = comp[2] + "." + comp[1] + "." + comp[0]
    return revDate
}

let butNotBio: [numPadButton] = [.one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .dop, .zero, .del]
let butWizBio: [numPadButton] = [.one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .bio, .zero, .del]

let appURL = "https://www.aleksa.site/????????????/wsgi"

struct GlobalObjs {
    static var email: String = ""
    static var codeConf: String = ""
    static var enterCode: Bool = false
    static var userPin: String = ""
    static var bioType: String = ""

}

class Transport: Identifiable {
    var tid: Int
    var nick: String
    var producted: Int?
    var mileage: Int?
    var engHours: Int?
    var diagDate: Date?
    var osagoDate: Date?
    var totalFuel: Double?
    var fuelDate: Date?

    init(tid: Int, nick: String, producted: Int?, mileage: Int?, engHours: Int?, diagDate: Date?, osagoDate: Date?, totalFuel: Double?, fuelDate: Date?) {
        self.tid = tid
        self.nick = nick
        self.producted = producted
        self.mileage = mileage
        self.engHours = engHours
        self.diagDate = diagDate
        self.osagoDate = osagoDate
        self.totalFuel = totalFuel
        self.fuelDate = fuelDate
    }
}

class Email {
    var eid: Int
    var email: String
    var send: Int

    init(eid: Int, email: String, send: Int) {
        self.eid = eid
        self.email = email
        self.send = send
    }
}

class Mileage {
    var mid: Int
    var date: String
    var mileage: Int

    init(mid: Int, date: String, mileage: Int) {
        self.mid = mid
        self.date = date
        self.mileage = mileage
    }
}

struct EngHour {
    var ehid: Int
    var date: String
    var engHour: Int
}

struct Fuel {
    var fid: Int
    var date: String
    var fuel: Double
    var mileage: Int?
    var fillBrand: String?
    var fuelBrand: String?
    var fuelCost: Double?
}

struct Service {
    var sid: Int
    var date: String
    var serType: String
    var mileage: Int?
    var matCost: Double?
    var wrkCost: Double?
}

struct Material {
    var maid: Int
    var matInfo: String
    var wrkType: String
    var matCost: Double?
    var wrkCost: Double?
}

class Notification {
    var nid: Int
    var tid: Int
    var type: String
    var mode: Int
    var date: String?
    var value1: Int?
    var value2: Int?
    var notification: String

    init(nid: Int, tid: Int, type: String, mode: Int, date: String?, value1: Int?, value2: Int?, notification: String) {
        self.nid = nid
        self.tid = tid
        self.type = type
        self.mode = mode
        self.date = date
        self.value1 = value1
        self.value2 = value2
        self.notification = notification
    }
}

struct Statistics {
    var id: Int
    var tid: Int

    var mo: String

    var fuelCnt: String
    var fuelSum: String
    var fuelMin: String
    var fuelMax: String
    var fuelAvg: String

    var mileageCnt: String
    var mileageSum: String
    var mileageMin: String
    var mileageMax: String
    var mileageAvg: String

    var fmSum: String
}

func feedbackSelect() {
    //    let impactLight = UIImpactFeedbackGenerator(style: .light)
    //    impactLight.impactOccurred()
    let selectionFeedback = UISelectionFeedbackGenerator()
    selectionFeedback.selectionChanged()
}

func feedbackError() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.error)
}

extension UITextField {
    @objc func doneButtonTapped(button: UIBarButtonItem) -> Void {
        self.resignFirstResponder()
    }
}
