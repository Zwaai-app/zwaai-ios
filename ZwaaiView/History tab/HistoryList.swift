import SwiftUI
import ZwaaiLogic

struct HistoryList: View {
    @Binding var history: [HistoryItem]
    @Binding var allTimePersonZwaaiCount: UInt
    @Binding var allTimeSpaceZwaaiCount: UInt

    var body: some View {
        List {
            Section(header: PersonenHeader(count: allTimePersonZwaaiCount)) {
                ForEach(history.filter({$0.type == .person})) {item in
                    Text(verbatim: timestampString(item))
                        .accessibility(label: Text("\(timestampString(item)) gezwaaid met een persoon"))
                }
            }
            Section(header: SpacesHeader(count: allTimeSpaceZwaaiCount)) {
                ForEach(history.filter({ $0.type.isSpace })) { item in
                    SpaceRow(item: item)
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
        bundle: .zwaaiView,
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
        bundle: .zwaaiView,
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

private struct SpaceRow: View {
    let item: HistoryItem
    var space: CheckedInSpace { return self.item.type.space! }

    var body: some View {
        VStack(alignment: .leading) {
            Text(verbatim: timestampString(item))
                .accessibility(label: Text("\(timestampString(item)) gezwaaid bij ruimte \(space.name)"))
            HStack {
                Text("\(space.name)")
                if space.checkedOut != nil {
                    Text(verbatim: "|")
                    Text("uitgecheckt: \(DateFormatter.relativeMedium.string(from: space.checkedOut!).lowercased())")
                }
            }.font(.caption).padding([.top], 4)
        }
    }
}

private func timestampString(_ item: HistoryItem) -> String {
    return DateFormatter.relativeMedium.string(from: item.timestamp)
}
