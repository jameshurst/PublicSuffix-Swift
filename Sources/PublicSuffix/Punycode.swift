import Foundation

// swiftlint:disable identifier_name
class Punycode {
    private static let base: UInt32 = 36
    private static let tMin: UInt32 = 1
    private static let tMax: UInt32 = 26
    private static let skew: UInt32 = 38
    private static let damp: UInt32 = 700
    private static let initialBias: UInt32 = 72
    private static let initialN: UInt32 = 0x80
    private static let delimiter = UnicodeScalar(0x2D)! // -

    private static func adapt(delta: UInt32, numberOfPoints: UInt32, isFirstTime: Bool) -> UInt32 {
        var delta = isFirstTime ? delta / damp : delta / 2
        delta += delta / numberOfPoints

        var k: UInt32 = 0
        while delta > ((base - tMin) * tMax) / 2 {
            delta /= base - tMin
            k += base
        }

        return k + (((base - tMin + 1) * delta) / (delta + skew))
    }

    // swiftlint:disable:next cyclomatic_complexity
    static func decode(_ input: String) -> String? {
        let inputScalars = input.unicodeScalars
        var scalars: [UnicodeScalar]
        var output: String

        if let index = inputScalars.lastIndex(of: delimiter) {
            if index > inputScalars.startIndex {
                scalars = Array(inputScalars[inputScalars.index(after: index)...])
            } else {
                scalars = Array(inputScalars)
            }

            output = String(inputScalars[..<index])
        } else {
            scalars = Array(inputScalars)
            output = String()
        }

        var codePoint = initialN
        var bias = initialBias
        var i: UInt32 = 0

        while !scalars.isEmpty {
            let previousI = i
            var weight: UInt32 = 1
            var k = base

            while true {
                guard !scalars.isEmpty else {
                    return nil // End of input before the end of this delta
                }

                let byte = scalars.removeFirst().value
                let digit: UInt32
                switch byte {
                case 0x30 ... 0x39:
                    digit = byte - 0x30 + 26
                case 0x41 ... 0x5A:
                    digit = byte - 0x41
                case 0x61 ... 0x7A:
                    digit = byte - 0x61
                default:
                    return nil
                }

                if digit > (UInt32.max - i) / weight {
                    return nil // Overflow
                }

                i += digit * weight
                let t = k <= bias ? tMin : (k >= bias + tMax ? tMax : k - bias)
                if digit < t {
                    break
                }

                if weight > UInt32.max / (base - t) {
                    return nil // Overflow
                }

                weight *= base - t
                k += base
            }

            let length = UInt32(output.count)
            bias = adapt(delta: i - previousI, numberOfPoints: length + 1, isFirstTime: previousI == 0)
            if i / (length + 1) > UInt32.max - codePoint {
                return nil // Overflow
            }

            codePoint += i / (length + 1)
            i %= length + 1

            guard let scalar = UnicodeScalar(codePoint) else {
                return nil
            }

            output.insert(Character(scalar), at: output.index(output.startIndex, offsetBy: Int(i)))
            i += 1
        }

        return output
    }
}
