import Foundation

struct Rule: Equatable {
    let labels: [String]
    let isException: Bool

    init(_ string: String) {
        if string.hasPrefix("!") {
            isException = true
            labels = string.dropFirst().split(separator: ".").map(String.init)
        } else {
            isException = false
            labels = string.split(separator: ".").map(String.init)
        }
    }

    func matches(_ input: String) -> Bool {
        // Split the input in to its labels
        let inputLabels = input.components(separatedBy: ".")

        // The input needs at least as many labels as the rule has
        guard inputLabels.count >= labels.count else {
            return false
        }

        // The input matches the rule if the input labels has the rule labels as a suffix
        return inputLabels.reversed().starts(with: labels.reversed(), by: { inputLabel, label in
            // A rule label always matches if its a wildcard
            label == "*" ? true : inputLabel == label
        })
    }
}
