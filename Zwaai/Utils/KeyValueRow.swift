import SwiftUI

struct KeyValueRow: View {
    var label: Text
    var value: String

    var body: some View {
        HStack {
            label
            Spacer()
            Text(verbatim: value)
        }
    }
}
