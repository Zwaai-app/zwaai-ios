import Foundation

extension DateFormatter {

    public static var relativeMedium: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.locale = Locale.autoupdatingCurrent
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    public static var shortTime: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    public static var shortNL: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
