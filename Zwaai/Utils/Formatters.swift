import Foundation

extension DateFormatter {

    static var relativeMedium: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.locale = Locale.autoupdatingCurrent
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    static var shortTime: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    static var shortNL: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
