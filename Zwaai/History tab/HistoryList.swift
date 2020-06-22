import SwiftUI

struct HistoryList: View {
    @Binding var history: [HistoryItem]
    @Binding var allTimePersonZwaaiCount: UInt
    @Binding var allTimeRoomZwaaiCount: UInt

    var dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()

    var body: some View {
        List {
            Section(header: PersonenHeader(count: allTimePersonZwaaiCount)) {
                ForEach(history.filter({$0.type == .person})) {item in
                    Text(self.dateFormatter.string(from: item.timestamp))
                }
            }
            Section(header: RoomsHeader(count: allTimeRoomZwaaiCount)) {
                ForEach(history.filter({$0.type == .room})) {item in
                    Text(self.dateFormatter.string(from: item.timestamp))
                }
            }
        }
    }
}

private struct PersonenHeader: View {
    let count: UInt
    let formatString = NSLocalizedString(
        "Gezwaaid met %d personen",
        tableName: "HistoryList",
        comment: "Header of persons section in history list")

    var body: some View {
        HStack {
            Image(systemName: "person.fill")
            Text(verbatim: String.localizedStringWithFormat(formatString, count))
                .font(.subheadline)
        }
    }
}

private struct RoomsHeader: View {
    let count: UInt
    let formatString = NSLocalizedString(
        "Gezwaaid bij %d ruimtes",
        tableName: "HistoryList",
        comment: "Header of rooms section in history list")

    var body: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
            Text(verbatim: String.localizedStringWithFormat(formatString, count))
            .font(.subheadline)
        }
    }
}
