import Foundation

/// A suffix list used to parse domain names.
public struct SuffixList {
    private let rules: [String: [Rule]]

    #if !NO_BUNDLED
        /// The default suffix list using bundled data.
        public static let `default`: SuffixList = {
            let url = Bundle.module.url(forResource: "public_suffix_list", withExtension: "dat")!
            let list = (try? Data(contentsOf: url)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
            return SuffixList(string: list)
        }()
    #endif

    /// Initializes a new suffix list.
    ///
    /// - Parameter string: The public suffix list data in the format used by publicsuffix.org.
    public init(string: String) {
        var rules = [String: [Rule]]()

        // The rules are split by newlines
        for line in string.split(separator: "\n") {
            // Strip comments or empty lines
            guard !line.hasPrefix("//"), !line.isEmpty else {
                continue
            }

            // Parse and store rules by TLD
            let rule = Rule(String(line))
            guard let tld = rule.labels.last else { continue }
            rules[tld, default: []].append(rule)
        }

        self.rules = rules
    }

    /// Parses a domain in to its components.
    ///
    /// - Parameter domain: The domain to parse.
    /// - Returns: The parsed domain components.
    public func parse(_ domain: String) -> DomainComponents? {
        // swiftlint:disable:previous cyclomatic_complexity

        // Fail to parse if domain has a leading dot
        guard !domain.hasPrefix(".") else {
            return nil
        }

        // Fail to parse if any labels are integers
        guard domain.split(separator: ".").map(String.init).compactMap(Int.init).isEmpty else {
            return nil
        }

        // Normalize the domain and split in to labels
        let domain = domain.lowercased()
        let labels = domain.split(separator: ".").map(String.init)

        // A valid domain needs more than one label
        guard labels.count > 1 else {
            return nil
        }

        // Look up the rules for the domain's TLD
        let tld = String(labels.last!)
        guard let rules = rules[tld] else {
            // This is an unknown TLD.
            let sld = labels[labels.count - 2]
            let domain = labels.suffix(2).joined(separator: ".")
            var subdomain: String?

            if labels.count > 2 {
                subdomain = labels.prefix(labels.count - 2).joined(separator: ".")
            }

            return .init(tld: tld, sld: sld, domain: domain, subdomain: subdomain, hasKnownTLD: false)
        }

        // Recreate the domain using punycode decoded labels
        let decodedDomain = labels
            .map { $0.hasPrefix("xn--") ? Punycode.decode(String($0.dropFirst(4))) ?? $0 : $0 }
            .joined(separator: ".")

        // Take the longest matching rule
        let longestRuleFirstSort = { (lhs: Rule, rhs: Rule) -> Bool in
            if lhs.isException, rhs.isException {
                return lhs.labels.count > rhs.labels.count
            }

            if lhs.isException {
                return true
            }

            if rhs.isException {
                return false
            }

            return lhs.labels.count > rhs.labels.count
        }

        guard let match = rules.filter({ $0.matches(decodedDomain) }).min(by: longestRuleFirstSort) else {
            return nil
        }

        // Exceptions don't include the leftmost label in the suffix
        let suffixLabelCount = match.isException ? match.labels.count - 1 : match.labels.count

        // The domain needs to have more labels than the number of suffix labels
        guard labels.count > suffixLabelCount else {
            return nil
        }

        let suffix = labels.suffix(suffixLabelCount).joined(separator: ".")
        let sld = labels[labels.count - suffixLabelCount - 1]
        let domainComponent = labels.suffix(suffixLabelCount + 1).joined(separator: ".")
        var subdomain: String?

        if labels.count > suffixLabelCount + 1 {
            subdomain = labels.prefix(labels.count - suffixLabelCount - 1).joined(separator: ".")
        }

        return .init(tld: suffix, sld: sld, domain: domainComponent, subdomain: subdomain, hasKnownTLD: true)
    }
}
