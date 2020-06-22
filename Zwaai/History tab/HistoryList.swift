import SwiftUI

struct HistoryList: View {
    @Binding var history: [HistoryItem]

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
            Section(header: PersonenHeader()) {
                ForEach(history.filter({$0.type == .person})) {item in
                    Text(self.dateFormatter.string(from: item.timestamp))
                }
            }
            Section(header: RoomsHeader()) {
                ForEach(history.filter({$0.type == .room})) {item in
                    Text(self.dateFormatter.string(from: item.timestamp))
                }
            }
        }
    }
}

private struct PersonenHeader: View {
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
            Text("Gezwaaid met personen").font(.subheadline)
        }
    }
}

private struct RoomsHeader: View {
    var body: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
            Text("Gezwaaid bij ruimtes").font(.subheadline)
        }
    }
}
