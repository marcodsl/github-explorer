// Int+String.swift

import Foundation

extension Int {
    private static var formatter: NumberFormatter = {
        let formatter = NumberFormatter()

        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = "."

        return formatter
    }()

    var formattedValue: String {
        let number = NSNumber(value: self)
        return Self.formatter.string(from: number)!
    }
}
