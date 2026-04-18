import Testing
@testable import Typofall

struct TFAlgebraTests {
    
    @Test func basis() async throws {
        
        var inputString = String()
        var idealString = String()
        var basis: TFBasis {
            return TFAlgebra.basis(diffing: inputString, against: idealString)
        }
        
        #expect(basis == TFBasis([], [], []))
        
        inputString = ""; idealString = "ab"
        #expect(basis == TFBasis(sourceSequence: [0, 1], sequence: [], subsequence: []))
        
        inputString = "ab"; idealString = ""
        #expect(basis == TFBasis(sourceSequence: [], sequence: [nil, nil], subsequence: []))
        
        inputString = "ab"; idealString = "ab"
        #expect(basis == TFBasis(sourceSequence: [0, 1], sequence: [0, 1], subsequence: [0, 1]))
        
        inputString = "ab"; idealString = "cd"
        #expect(basis == TFBasis(sourceSequence: [0, 1], sequence: [nil, nil], subsequence: []))
        
        inputString = "Ab"; idealString = "aB"
        #expect(basis == TFBasis(sourceSequence: [0, 1], sequence: [0, 1], subsequence: [0, 1]))
            
        inputString = "bac"; idealString = "abc"
        #expect(basis == TFBasis(
            sourceSequence: [0, 1, 2],
            sequence:       [1, 0, 2],
            subsequence:    [   0, 2]
        ))
        
        inputString = "3a1cb2"; idealString = "abc123"
        #expect(basis == TFBasis(
            sourceSequence: [0, 1, 2, 3, 4, 5],
            sequence:       [5, 0, 3, 2, 1, 4],
            subsequence:    [   0,       1, 4]
        ))
        
        inputString = "abc"; idealString = "AaBb"
        #expect(basis == TFBasis(
            sourceSequence: [0, 1, 2, 3],
            sequence:       [0, 2, nil ],
            subsequence:    [0, 2      ]
        ))
        
        inputString = "aaaa1bbbb"; idealString = "aaaa2bbbb"
        #expect(basis == TFBasis(
            sourceSequence: [0, 1, 2, 3,  4,  5, 6, 7, 8],
            sequence:       [0, 1, 2, 3, nil, 5, 6, 7, 8],
            subsequence:    [0, 1, 2, 3,      5, 6, 7, 8]
        ))
        
        inputString = "abbc"; idealString = "abbbc"
        #expect(basis == TFBasis(
            sourceSequence: [0, 1, 2, 3, 4],
            sequence:       [0, 1, 2,    4],
            subsequence:    [0, 1, 2,    4]
        ))
        
        inputString = "abc"; idealString = "abcdef"
        #expect(basis == TFBasis(
            sourceSequence: [0, 1, 2, 3, 4, 5],
            sequence:       [0, 1, 2         ],
            subsequence:    [0, 1, 2         ]
        ))
        
        inputString = "def"; idealString = "abcdef"
        #expect(basis == TFBasis(
            sourceSequence: [0, 1, 2, 3, 4, 5],
            sequence:       [         3, 4, 5],
            subsequence:    [         3, 4, 5]
        ))
        
        inputString = "abXcd"; idealString = "abYcd"
        #expect(basis == TFBasis(
            sourceSequence: [0, 1,  2,  3, 4],
            sequence:       [0, 1, nil, 3, 4],
            subsequence:    [0, 1,      3, 4]
        ))
        
        inputString = "abXcdefg"; idealString = "abYcd"
        #expect(basis == TFBasis(
            sourceSequence: [0, 1,  2,  3, 4               ],
            sequence:       [0, 1, nil, 3, 4, nil, nil, nil],
            subsequence:    [0, 1,      3, 4               ]
        ))
        
    }
    
    
    @Test func bestDyad() async throws {
        
        var dyads = [TFDyad]()
        var bestDyad: TFDyad {
            return TFAlgebra.bestDyad(among: dyads)
        }
        
        dyads = []
        #expect(bestDyad == TFDyad())
        
        dyads = [
            TFDyad(sequence: [0, 1, 2], subsequence: [0, 1, 2])
        ]
        #expect(bestDyad == dyads[0])
        
        dyads = [
            TFDyad(sequence: [1, 4, 2], subsequence: [1, 2]), // best
            TFDyad(sequence: [1, 4, 3], subsequence: [1, 3])
        ]
        #expect(bestDyad == dyads[0])
        
        dyads = [
            TFDyad(sequence: [nil, 1], subsequence: [1]), // best
            TFDyad(sequence: [nil, 2], subsequence: [2])
        ]
        #expect(bestDyad == dyads[0])
        
        dyads = [
            TFDyad(sequence: [nil, 1, 5, 6], subsequence: [1, 5, 6]),
            TFDyad(sequence: [nil, 2, 4, 5], subsequence: [2, 4, 5]),
            TFDyad(sequence: [nil, 0, 2, 7], subsequence: [0, 2, 7]), // best
            TFDyad(sequence: [nil, 1, 2, 6], subsequence: [1, 2, 6]),
            TFDyad(sequence: [nil, 2, 3, 5], subsequence: [2, 3, 5])
        ]
        #expect(bestDyad == dyads[2])
        
    }
    
    
    @Test func dyads() async throws {
        
        var sequences = [TFOptionalSequence]()
        var dyads: [TFDyad] {
            return TFAlgebra.dyads(from: sequences)
        }
        
        sequences = []
        #expect(dyads == [])
        
        sequences = [ [nil] ]
        #expect(dyads == [
            TFDyad(sequence: [nil], subsequence: [])
        ])
        
        sequences = [ [0, 1, 2] ]
        #expect(dyads == [
            TFDyad(sequence: [0, 1, 2], subsequence: [0, 1, 2])
        ])
        
        sequences = [ [0, 2, 1], [0, 2, 3] ]
        #expect(dyads == [
            TFDyad(sequence: [0, 2, 3], subsequence: [0, 2, 3])
        ])
        
        sequences = [ [1, nil, 2], [1, nil, 3] ]
        #expect(dyads == [
            TFDyad(sequence: [1, nil, 2], subsequence: [1, 2]),
            TFDyad(sequence: [1, nil, 3], subsequence: [1, 3])
        ])
        
        sequences = [ [nil, 2, 0, 4, nil], [nil, 2, 3, 4, nil] ]
        #expect(dyads == [
            TFDyad(sequence: [nil, 2, 3, 4, nil], subsequence: [2, 3, 4])
        ])
        
        sequences = [ [nil, 1, 2, 4, 1], [nil, 1, 2, 4, 3], [nil, 3, 2, 4, 3] ]
        #expect(dyads == [
            TFDyad(sequence: [nil, 1, 2, 4, 1], subsequence: [1, 2, 4]),
            TFDyad(sequence: [nil, 1, 2, 4, 3], subsequence: [1, 2, 3])
        ])
        
        sequences = [ [0, 1, 1, 2], [0, 1, 2, 3] ]
        #expect(dyads == [
            TFDyad(sequence: [0, 1, 2, 3], subsequence: [0, 1, 2, 3])
        ])
        
    }
    
    
    @Test func sequences() async throws {
        
        var inputString = String()
        var idealString = String()
        var sequences: [TFOptionalSequence] {
            return TFAlgebra.sequences(diffing: inputString, against: idealString)
        }
        
        inputString = ""; idealString = ""
        #expect(sequences == [[]])
        
        inputString = ""; idealString = "abc"
        #expect(sequences == [[]])
        
        inputString = "abc"; idealString = ""
        #expect(sequences == [ [nil, nil, nil] ])
        
        inputString = "abc"; idealString = "def"
        #expect(sequences == [ [nil, nil, nil] ])
        
        inputString = "abc"; idealString = "abc"
        #expect(sequences == [ [0, 1, 2] ])
        
        inputString = "yy"; idealString = "ay"
        #expect(sequences == [ [1, 1] ])
        
        inputString = "abcd"; idealString = "dcba"
        #expect(sequences == [ [3, 2, 1, 0] ])
        
        inputString = "abac"; idealString = "caba"
        #expect(sequences == [ [1, 2, 1, 0], [1, 2, 3, 0], [3, 2, 3, 0] ])
        
        inputString = "aa"; idealString = "aa"
        #expect(sequences == [ [0, 1] ])
        
        inputString = "aaaaa"; idealString = "aaaaa"
        #expect(sequences == [ [0, 1, 2, 3, 4] ])
        
        inputString = "3aaa12"; idealString = "12aaa3"
        #expect(sequences == [ [5, 2, 3, 4, 0, 1] ])
        
        inputString = "2aaa1a"; idealString = "1aaaa2"
        #expect(sequences == [ [5, 1, 2, 3, 0, 3], [5, 1, 2, 3, 0, 4] ])
        
        inputString = "gotob"; idealString = "robot"
        #expect(sequences == [
            [nil, 1, 4, 1, 2],
            [nil, 1, 4, 3, 2],
            [nil, 3, 4, 3, 2]
        ])
        
        inputString = "caba"; idealString = "acab"
        #expect(sequences == [
            [1, 0, 3, 0],
            [1, 0, 3, 2],
            [1, 2, 3, 2]
        ])
        
        inputString = "caaaba"; idealString = "baaaac"
        #expect(sequences == [
            [5, 1, 2, 3, 0, 3],
            [5, 1, 2, 3, 0, 4]
        ])
        
        inputString = "aa"; idealString = "aaa"
        #expect(sequences == [ [0, 1] ])
        
        inputString = "abcdef"; idealString = "bdf"
        #expect(sequences == [ [nil, 0, nil, 1, nil, 2] ])
        
    }
    
    
    @Test func commonCharactersCount() async throws {
        
        var text1 = String()
        var text2 = String()
        var count: Int {
            return TFAlgebra.commonCharactersCount(between: text1, and: text2)
        }
        
        text1 = ""; text2 = ""
        #expect(count == 0)
        
        text1 = "aaabbb"; text2 = "bbbaaa"
        #expect(count == 6)
        
        text1 = ""; text2 = "abc"
        #expect(count == 0)
        
        text1 = "abc"; text2 = ""
        #expect(count == 0)
        
        text1 = "abc"; text2 = "abc"
        #expect(count == 3)
        
        text1 = "abc"; text2 = "cba"
        #expect(count == 3)
        
        text1 = "ab$c!"; text2 = "ba$c?"
        #expect(count == 4)
        
        text1 = "#$%"; text2 = "$@#"
        #expect(count == 2)
        
        text1 = "aabbcc"; text2 = "abc"
        #expect(count == 3)
        
        text1 = "abc"; text2 = "aaabbbccc"
        #expect(count == 3)
        
        text1 = "xyz"; text2 = "abc"
        #expect(count == 0)
        
    }
    
    
    @Test func characterIndices() async throws {
        
        var string = String()
        var dict: [Character: [Int]] {
            return TFAlgebra.characterIndices(of: string)
        }
        
        string = ""
        #expect(dict == [:])
        
        string = "7"
        #expect(dict == ["7": [0]])
        
        string = ":::::"
        #expect(dict == [":": [0, 1, 2, 3, 4]])
        
        string = " 1 3"
        #expect(dict == [" ": [0, 2], "1": [1], "3": [3]])
        
        string = "abc"
        #expect(dict == ["a": [0], "b": [1], "c": [2]])
        
        string = "abcabc"
        #expect(dict == ["a": [0, 3], "b": [1, 4], "c": [2, 5]])
        
        string = "1!,@1"
        #expect(dict == ["1": [0, 4], "!": [1], ",": [2], "@": [3]])
        
    }
    
    
    @Test func lis() async throws {
        
        var sequence = TFSequence()
        var subsequence: TFSubsequence {
            return TFAlgebra.lis(of: sequence)
        }
        
        sequence = []
        #expect(subsequence == [])
        
        sequence = [1]
        #expect(subsequence == [1])

        sequence = [1, 0]
        #expect(subsequence == [0])
        
        sequence = [2, 2, 2, 2]
        #expect(subsequence == [2])

        sequence = [1, 3, 2, 3]
        #expect(subsequence == [1, 2, 3])
        
        sequence = [1, 0, 2, 1, 3]
        #expect(subsequence == [0, 1, 3])
        
        sequence = [3, 1, 4, 2, 5]
        #expect(subsequence == [1, 2, 5])
        
        sequence = [5, 4, 3, 2, 1]
        #expect(subsequence == [1])
        
        sequence = [2, 1, 4, 3, 6, 5]
        #expect(subsequence == [1, 3, 5])
        
        sequence = [2, 6, 0, 8, 1, 3, 1]
        #expect(subsequence == [0, 1, 3])
        
        sequence = [0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7, 15]
        #expect(subsequence == [0, 2, 6, 9, 11, 15])
        
    }
    
}
