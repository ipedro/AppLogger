import SwiftUI

struct LinkText: View {
    var data: String
    var alignment: TextAlignment = .leading

    var body: some View {
        let _ = Self._debugPrintChanges()
        Group {
            if let link = URL(string: data), link.scheme != .none {
                Text(data)
                    .underline()
                    .onTapGesture {
                        UIApplication.shared.open(link, options: [:], completionHandler: .none)
                    }
            } else {
                Text(data)
            }
        }
        .textSelection(.enabled)
        .multilineTextAlignment(alignment)
    }
}

#Preview {
    VStack {
        LinkText(data: "Some Link", alignment: .leading)
        LinkText(data: "https://google.com", alignment: .leading)
    }
}
