import MigrationScanner
import SwiftUI

/// Paste Swift code and see what the scanner reports, as you type.
struct ScannerScreen: View {
    @Bindable var model: LabModel

    var body: some View {
        let report = model.report
        List {
            Section {
                TextEditor(text: $model.source)
                    .font(.system(.footnote, design: .monospaced))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .frame(height: 170)
            } header: {
                Text("Swift source")
            } footer: {
                Text("Edit the code; the findings update as you type.")
            }
            Section {
                ForEach(report.findings, id: \.self) { finding in
                    if let rule = finding.rule {
                        NavigationLink(value: rule.id) {
                            FindingRow(finding: finding, rule: rule)
                        }
                    }
                }
            } header: {
                Text(summary(of: report))
            }
        }
        .navigationTitle("Scanner")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Clear", systemImage: "trash") { model.source = "" }
                Button("Load sample", systemImage: "arrow.counterclockwise") { model.source = LegacySample.source }
            }
        }
        .navigationDestination(for: String.self) { id in
            if let rule = RuleCatalog.rule(id: id) { RuleDetailView(rule: rule) }
        }
    }

    private func summary(of report: ScanReport) -> String {
        let errors = report.count(of: .error)
        let warnings = report.count(of: .warning)
        let info = report.count(of: .info)
        return "\(errors) \(errors == 1 ? "error" : "errors") · \(warnings) \(warnings == 1 ? "warning" : "warnings") · \(info) info"
    }
}

struct FindingRow: View {
    let finding: Finding
    let rule: Rule

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            SeverityIcon(severity: finding.severity)
            VStack(alignment: .leading, spacing: 4) {
                Text(rule.title).font(.subheadline.weight(.semibold))
                if let location = finding.location {
                    Text("Line \(location.line):\(location.column) · \(rule.id)")
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
                Text(rule.replacement).font(.footnote).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct SeverityIcon: View {
    let severity: Severity

    var body: some View {
        switch severity {
        case .error:
            Image(systemName: "xmark.octagon.fill").foregroundStyle(.red).accessibilityLabel("Error")
        case .warning:
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange).accessibilityLabel("Warning")
        case .info:
            Image(systemName: "info.circle.fill").foregroundStyle(.blue).accessibilityLabel("Info")
        }
    }
}
