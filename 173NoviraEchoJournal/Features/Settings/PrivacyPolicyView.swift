//
//  PrivacyPolicyView.swift
//  173NoviraEchoJournal
//

import SwiftUI

enum PrivacyPolicyContent {
    static func loadMarkdown() -> String {
        guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
              let data = try? Data(contentsOf: url),
              let text = String(data: data, encoding: .utf8) else {
            return "# Privacy Policy\nContent unavailable."
        }
        return text
    }
}

struct PrivacyPolicyView: View {
    private let markdown: String
    private let attributed: AttributedString

    init(markdown: String = PrivacyPolicyContent.loadMarkdown()) {
        self.markdown = markdown
        if let parsed = try? AttributedString(
            markdown: markdown,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
        ) {
            attributed = parsed
        } else {
            attributed = AttributedString(markdown)
        }
    }

    var body: some View {
        ScrollView {
            Text(attributed)
                .font(.body)
                .foregroundStyle(Color.appTextPrimary)
                .tint(Color.appPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .appCardBackground(cornerRadius: 20, style: .standard, elevation: .listItem)
                .padding(16)
        }
        .scrollIndicators(.visible)
        .background(LayeredAppBackground())
    }
}
