extension FrostflakeIdentifier {
    private static let _base58Alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    private static let _base58Characters = Array(_base58Alphabet) // Convert to array for direct indexing
    // ASCII value of 'z' is 122, so we create an array of size 123.
    private static let _base58AlphabetIndexByChar: [Int?] = {
        var indexes = [Int?](repeating: nil, count: Int(Character("z").asciiValue!) + 1) // 'z' is the highest ASCII character in the alphabet.
        for (index, char) in _base58Alphabet.utf8.enumerated() {
            indexes[Int(char)] = index
        }
        return indexes
    }()
    fileprivate static let _base: UInt64 = 58

    public var base58: String {
        var number = self
        var encodedChars: [Character] = [] // Use array to collect characters

        while number > 0 {
            let remainder = Int(number % Self._base)
            number /= Self._base
            encodedChars.append(Self._base58Characters[remainder]) // Append character to the array
        }

        return String(encodedChars.reversed()) // Create a string from the reversed array of characters
    }

    // Base58 Decoding
    public init? (base58: String) {
        self = 0

        for character in base58.utf8 {
            guard character < Self._base58AlphabetIndexByChar.count, let index = Self._base58AlphabetIndexByChar[Int(character)] else {
                return nil // Character not in Base58 alphabet or not a valid ASCII character
            }

            let (multiplied, overflowMult) = self.multipliedReportingOverflow(by: Self._base)
            if overflowMult {
                return nil // Overflow in multiplication
            }

            let (added, overflowAdd) = multiplied.addingReportingOverflow(UInt64(index))
            if overflowAdd {
                return nil // Overflow in addition
            }

            self = added
        }
    }
}
