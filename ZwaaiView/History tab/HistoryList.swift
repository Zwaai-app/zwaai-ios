import SwiftUI
import ZwaaiLogic

enum PickerFilter: Int {
    case persons = 1
    case spaces = 2
}

struct HistoryList: View {
    @Binding var personItems: [HistoryItem]
    @Binding var spaceItems: [HistoryItem]
    @Binding var allTimePersonZwaaiCount: UInt
    @Binding var allTimeSpaceZwaaiCount: UInt
    @State var pickerValue: PickerFilter = .persons

    var body: some View {
        List {
            Section(header: header, footer: footer) {
                ForEach(selectedItems()) {item in
                    if item.type.isPerson {
                        Text(verbatim: timestampString(item))
                            .accessibility(label: Text("\(timestampString(item)) gezwaaid met een persoon"))
                    } else {
                        SpaceRow(item: item)
                    }
                }
            }
        }
    }

    var header: some View {
        Picker(selection: $pickerValue, label: Text("Filter op:")) {
            Text("Personen").tag(PickerFilter.persons)
            Text("Ruimtes").tag(PickerFilter.spaces)
        }.pickerStyle(SegmentedPickerStyle())
    }

    var footer: some View {
        Text("Totaal aantal gescand sinds de app in gebruik genomen is: ")
            + (pickerValue == .persons
                ? Text("\(allTimePersonZwaaiCount) personen")
                : Text("\(allTimeSpaceZwaaiCount) ruimtes"))
    }

    func selectedItems() -> [HistoryItem] {
        pickerValue == .persons ? personItems : spaceItems
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

#if DEBUG
struct HistoryList_Previews: PreviewProvider {
    static var previews: some View {
        let space = CheckedInSpace(name: "Test", description: "Test", autoCheckout: nil)
        let personItems: [HistoryItem]
            = (0..<16).map { _ in HistoryItem(id: UUID(), timestamp: Date(), type: .person, random: Random()) }
        let spaceItems: [HistoryItem]
            = (0..<16).map { _ in HistoryItem(id: UUID(), timestamp: Date(), type: .space(space: space), random: Random()) }

        return HistoryList(
            personItems: .constant(personItems),
            spaceItems: .constant(spaceItems),
            allTimePersonZwaaiCount: .constant(0),
            allTimeSpaceZwaaiCount: .constant(0))
    }
}
#endif
