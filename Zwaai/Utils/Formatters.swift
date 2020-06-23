import Foundation

extension DateFormatter {

    static var relativeMedium: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()

    static var shortNL: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
