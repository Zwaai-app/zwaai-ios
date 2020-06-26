import SwiftUI

struct HistoryList: View {
    @Binding var history: [HistoryItem]
    @Binding var allTimePersonZwaaiCount: UInt
    @Binding var allTimeSpaceZwaaiCount: UInt

    var body: some View {
        List {
            Section(header: PersonenHeader(count: allTimePersonZwaaiCount)) {
                ForEach(history.filter({$0.type == .person})) {item in
                    Text(verbatim: self.timestampString(item))
                        .accessibility(label: Text("\(self.timestampString(item)) gezwaaid met een persoon"))
                }
            }
            Section(header: SpacesHeader(count: allTimeSpaceZwaaiCount)) {
                ForEach(history.filter({ $0.type.isSpace })) {item in
                    Text(verbatim: self.timestampString(item))
                        .accessibility(label: Text("\(self.timestampString(item)) gezwaaid bij een ruimte"))
                }
            }
        }
    }

    func timestampString(_ item: HistoryItem) -> String {
        return DateFormatter.relativeMedium.string(from: item.timestamp)
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
                .accessibility(hidden: true)
            Text(verbatim: String.localizedStringWithFormat(formatString, count))
                .font(.subheadline)
        }.accessibility(addTraits: .isHeader)
    }
}

private struct SpacesHeader: View {
    let count: UInt
    let formatString = NSLocalizedString(
        "Gezwaaid bij %d ruimtes",
        tableName: "HistoryList",
        comment: "Header of spaces section in history list")

    var body: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
                .accessibility(hidden: true)
            Text(verbatim: String.localizedStringWithFormat(formatString, count))
                .font(.subheadline)
        }.accessibility(addTraits: .isHeader)
    }
}
