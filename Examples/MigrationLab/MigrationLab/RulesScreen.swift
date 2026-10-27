import MigrationScanner
import SwiftUI

/// The rule catalog, searchable, with a detail page per rule.
struct RulesScreen: View {
    @Bindable var model: LabModel
    @State private var query = ""

    var body: some View {
        List {
            ForEach(RuleCategory.allCases, id: \.self) { category in
                let rules = RuleCatalog.rules(in: category).filter(matches)
                if !rules.isEmpty {
                    Section(category.title) {
                        ForEach(rules) { rule in
                            NavigationLink(value: rule.id) {
                                HStack(spacing: 12) {
                                    SeverityIcon(severity: rule.severity)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(rule.title).font(.subheadline)
                                        Text(rule.id).font(.caption.monospaced()).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("\(RuleCatalog.all.count) rules")
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Rule, API or identifier")
        .navigationDestination(for: String.self) { id in
            if let rule = RuleCatalog.rule(id: id) { RuleDetailView(rule: rule) }
        }
    }

    private func matches(_ rule: Rule) -> Bool {
        query.isEmpty || rule.title.localizedCaseInsensitiveContains(query) || rule.id.localizedCaseInsensitiveContains(query)
    }
}

struct RuleDetailView: View {
    let rule: Rule

    var body: some View {
        List {
            Section {
                LabeledContent("Severity", value: rule.severity.rawValue.capitalized)
                LabeledContent("Category", value: rule.category.title)
                LabeledContent("Identifier") { Text(rule.id).font(.callout.monospaced()) }
            }
            Section("Why") { Text(rule.message) }
            Section("Fix") { Text(rule.replacement) }
            Section("Based on") { Text(rule.evidence).font(.footnote) }
            Section {
                Link("Apple documentation", destination: rule.documentation)
            }
        }
        .navigationTitle(rule.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
