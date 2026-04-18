import Testing
@testable import Typofall

struct TFRefinementTests {
    
    @Test func refining() async throws {
        
        var text = TFText()
        let configuration = TFConfiguration()
        func expect(_ result: TFText) {
            #expect(result == TFRefinement.refining(text, using: configuration))
        }
        
        expect(.empty)
        
        text = TFText("a", annotation: .extra)
        expect(text)
        
        text = TFText("a", annotation: .missing)
        expect(text)
        
        text = TFText("a", annotation: .correct)
        expect(text)
        
        text = TFText("abc", annotation: .extra)
        expect(text)
        
        text = TFText("abc", annotation: .missing)
        expect(text)
        
        text = TFText("abc", annotation: .correct)
        expect(text)
        
        text = [.missing("a"), .correct("b"), .correct("c")]
        expect(text)
        
        text = [.correct("a"), .extra("a"), .correct("b")]
        expect(text)
        
        
        text = [.missing("1"), .correct("a"), .extra("a")]
        expect([.misspell("a", correct: "1"), .correct("a")])
        
        text = [.missing("1"), .correct("a"), .extra("a"), .extra("a")]
        expect([.misspell("a", correct: "1"), .correct("a"), .extra("a")])
        
        text = [.missing("1"), .missing("2"), .correct("a"), .extra("a"), .extra("a")]
        expect([.misspell("a", correct: "1"), .misspell("a", correct: "2"), .correct("a")])
        
        text = [.missing("1"), .correct("a"), .missing("2"), .extra("a")]
        expect([.misspell("a", correct: "1"), .correct("a"), .missing("2")])
        
        text = [.missing("1"), .correct("a"), .missing("2"), .extra("a"), .correct("b"), .extra("b")]
        expect([.misspell("a", correct: "1"), .correct("a"), .misspell("b", correct: "2"), .correct("b")])
        
        text = [.missing("1"), .missing("2"), .correct("a"), .correct("a"), .missing("3"), .missing("4"), .extra("a"), .correct("b"), .extra("b"), .extra("b")]
        expect([.misspell("a", correct: "1"), .missing("2"), .correct("a"), .correct("a"), .misspell("b", correct: "3"), .misspell("b", correct: "4"), .correct("b")])
        
        text = [.missing("1"), .missing("2"), .correct("A"), .extra("a"), .extra("A")]
        expect([.misspell("A", correct: "1"), .misspell("a", correct: "2"), .correct("A")])
        
        
        text = [.missing("1"), .extra("a")]
        expect([.misspell("a", correct: "1")])
        
        text = [.missing("1"), .missing("2"), .extra("a")]
        expect([.misspell("a", correct: "1"), .missing("2")])
        
        text = [.missing("1"), .extra("a"), .extra("b")]
        expect([.misspell("a", correct: "1"), .extra("b")])
        
        text = [.missing("1"), .extra("a"), .correct("a")]
        expect([.misspell("a", correct: "1"), .correct("a")])
        
        text = [.missing("1"), .extra("a"), .correct("a"), .extra("a")]
        expect([.misspell("a", correct: "1"), .correct("a"), .extra("a")])

        text = [.missing("1"), .missing("2"), .extra("a"), .extra("a"), .correct("a")]
        expect([.misspell("a", correct: "1"), .misspell("a", correct: "2"), .correct("a")])

        text = [.missing("1"), .extra("a"), .correct("a"), .missing("2")]
        expect([.misspell("a", correct: "1"), .correct("a"), .missing("2")])

        text = [.missing("1"), .extra("a"), .correct("a"), .missing("2"), .extra("b"), .correct("b")]
        expect([.misspell("a", correct: "1"), .correct("a"), .misspell("b", correct: "2"), .correct("b")])


        text = [.missing("1"), .missing("2"), .extra("a"), .correct("a"), .correct("a"), .missing("3"), .missing("4"), .extra("b"), .extra("b"), .correct("b")]
        expect([.misspell("a", correct: "1"), .missing("2"), .correct("a"), .correct("a"), .misspell("b", correct: "3"), .misspell("b", correct: "4"), .correct("b")])
        
        
        text = [.correct("H"), .missing("e"), .extra("a"), .correct("l"), .extra("o"), .correct("l"), .missing("o")]
        expect([.correct("H"), .misspell("a", correct: "e"), .correct("l"), .swapped("o", position: .left), .swapped("l", position: .right)])
        
    }
    
    
    @Test func checkExactCompliance() async throws {
        
        var text = TFText()
        var configuration = TFConfiguration()
        var result: Bool {
            return(TFRefinement.checkExactCompliance(for: text, to: configuration))
        }
        
        #expect(result == true)
        
        text = TFText("a", annotation: .extra)
        #expect(result == true)
        
        text = TFText("a", annotation: .missing)
        #expect(result == true)
        
        text = TFText("a", annotation: .correct)
        #expect(result == true)
        
        text = TFText("abc", annotation: .extra)
        #expect(result == true)
        
        text = TFText("abc", annotation: .missing)
        #expect(result == true)
        
        text = TFText("abc", annotation: .correct)
        #expect(result == true)
        
        text = [.missing("a"), .correct("b"), .correct("c")]
        #expect(result == true)
        
        text = [.correct("a"), .extra("a"), .correct("b")]
        #expect(result == true)
        
        
        configuration.requiredQuantityOfCorrectCharacters = .two
        
        text = [.correct("a"), .correct("b"), .extra("c")]
        #expect(result == true)
        
        text = [.swapped("b", position: .left), .swapped("c", position: .right), .extra("d")]
        #expect(result == true)
        
        text = [.correct("a"), .missing("b"), .extra("c")]
        #expect(result == false)
        
        text = [.correct("a"), .extra("c")]
        #expect(result == true)
        
        
        configuration.requiredQuantityOfCorrectCharacters = .high
        
        text = [.correct("a"), .correct("b"), .correct("c"), .missing("d")]
        #expect(result == true)
        
        text = [.correct("a"), .correct("b"), .missing("c"), .missing("d")]
        #expect(result == false)
        
        
        configuration = TFConfiguration()
        configuration.acceptableQuantityOfWrongCharacters = .two
        
        text = [.missing("a"), .correct("b"), .extra("c")]
        #expect(result == true)
        
        text = [.misspell("b", correct: "a"), .extra("c"), .correct("d")]
        #expect(result == true)
        
        text = [.misspell("b", correct: "a"), .extra("c"), .correct("d"), .extra("e")]
        #expect(result == false)
        
        text = [.swapped("a", position: .left), .swapped("b", position: .right), .swapped("c", position: .left), .swapped("d", position: .right)]
        #expect(result == true)
        
        
        configuration.requiredQuantityOfCorrectCharacters = .half
        configuration.acceptableQuantityOfWrongCharacters = .one
        
        text = [.correct("a"), .correct("b"), .missing("c")]
        #expect(result == true)
        
        text = [.correct("a"), .missing("b"), .extra("c")]
        #expect(result == false)
        
        text = [.correct("a"), .correct("b"), .extra("c"), .extra("d")]
        #expect(result == false)
        
        
        configuration.requiredQuantityOfCorrectCharacters = .all
        configuration.acceptableQuantityOfWrongCharacters = .zero
        
        text = .empty
        #expect(result == true)
        
    }
    
    
    @Test func addindMisspellChars() async throws {
        
        var text = TFText()
        var configuration = TFConfiguration()
        func expect(_ result: TFText) {
            #expect(result == TFRefinement.addingMisspellChars(to: text, with: configuration))
        }
        
        expect(.empty)
        
        text = TFText("a", annotation: .extra)
        expect(text)
        
        text = TFText("a", annotation: .missing)
        expect(text)
        
        text = TFText("a", annotation: .correct)
        expect(text)
        
        text = TFText("abc", annotation: .extra)
        expect(text)
        
        text = TFText("abc", annotation: .missing)
        expect(text)
        
        text = TFText("abc", annotation: .correct)
        expect(text)
        
        text = [.missing("a"), .correct("b"), .correct("c")]
        expect(text)
        
        text = [.correct("a"), .extra("a"), .correct("b")]
        expect(text)
        
        
        text = [.missing("1"), .extra("a")]
        expect([.misspell("a", correct: "1")])
        
        text = [.missing("1"), .missing("2"), .extra("a")]
        expect([.misspell("a", correct: "1"), .missing("2")])
        
        text = [.missing("1"), .extra("a"), .extra("b")]
        expect([.misspell("a", correct: "1"), .extra("b")])
        
        text = [.missing("1"), .extra("a"), .correct("a")]
        expect([.misspell("a", correct: "1"), .correct("a")])
        
        text = [.missing("1"), .extra("a"), .correct("a"), .extra("a")]
        expect([.misspell("a", correct: "1"), .correct("a"), .extra("a")])

        text = [.missing("1"), .missing("2"), .extra("a"), .extra("a"), .correct("a")]
        expect([.misspell("a", correct: "1"), .misspell("a", correct: "2"), .correct("a")])

        text = [.missing("1"), .extra("a"), .correct("a"), .missing("2")]
        expect([.misspell("a", correct: "1"), .correct("a"), .missing("2")])

        text = [.missing("1"), .extra("a"), .correct("a"), .missing("2"), .extra("b"), .correct("b")]
        expect([.misspell("a", correct: "1"), .correct("a"), .misspell("b", correct: "2"), .correct("b")])


        text = [.missing("1"), .missing("2"), .extra("a"), .correct("a"), .correct("a"), .missing("3"), .missing("4"), .extra("b"), .extra("b"), .correct("b")]
        expect([.misspell("a", correct: "1"), .missing("2"), .correct("a"), .correct("a"), .misspell("b", correct: "3"), .misspell("b", correct: "4"), .correct("b")])
        
        
        configuration.textCaseStrategy = .sensitive(.compared)
        
        text = [.missing("1"), .extra("a")]
        expect([.misspell("a", correct: "1")])
        
        text = [.missing("A"), .extra("b")]
        expect([.misspell("b", correct: "A", hasCorrectCase: false)])
        
        text = [.missing("a"), .extra("B")]
        expect([.misspell("B", correct: "a", hasCorrectCase: false)])
        
    }
    
    
    @Test func addingSwappedChars() async throws {
        
        var text = TFText()
        var configuration = TFConfiguration()
        func expect(_ result: TFText) {
            #expect(result == TFRefinement.addingSwappedChars(to: text, with: configuration))
        }
        
        expect(.empty)
        
        text = TFText("a", annotation: .extra)
        expect(text)
        
        text = TFText("a", annotation: .missing)
        expect(text)
        
        text = TFText("a", annotation: .correct)
        expect(text)
        
        text = TFText("abc", annotation: .extra)
        expect(text)
        
        text = TFText("abc", annotation: .missing)
        expect(text)
        
        text = TFText("abc", annotation: .correct)
        expect(text)
        
        text = [.missing("a"), .correct("b"), .correct("c")]
        expect(text)
        
        text = [.correct("a"), .extra("a"), .correct("b")]
        expect(text)
        
    
        text = [.extra("b"), .correct("a"), .missing("b")]
        expect([.swapped("b", position: .left), .swapped("a", position: .right)])
        
        text = [.extra("b"), .correct("a"), .missing("b"), .extra("d"), .correct("c"), .missing("d")]
        expect([.swapped("b", position: .left), .swapped("a", position: .right), .swapped("d", position: .left), .swapped("c", position: .right)])
        
        
        configuration.textCaseStrategy = .sensitive(.compared)
        
        text = [.extra("B"), .correct("A"), .missing("b")]
        expect([.swapped("B", position: .left, hasCorrectCase: false), .swapped("A", position: .right)])
        
    }
    
    
    @Test func preparing() async throws {
        
        var text = TFText()
        func expect(_ result: TFText) {
            #expect(result == TFRefinement.preparing(text))
        }
        
        expect(.empty)
        
        text = TFText("a", annotation: .extra)
        expect(text)
        
        text = TFText("a", annotation: .missing)
        expect(text)
        
        text = TFText("a", annotation: .correct)
        expect(text)
        
        text = TFText("abc", annotation: .extra)
        expect(text)
        
        text = TFText("abc", annotation: .missing)
        expect(text)
        
        text = TFText("abc", annotation: .correct)
        expect(text)
        
        text = [.missing("a"), .correct("b"), .correct("c")]
        expect(text)
        
        text = [.correct("a"), .extra("a"), .correct("b")]
        expect(text)
        
        
        text = [.missing("1"), .correct("a"), .extra("a")]
        expect([.missing("1"), .extra("a"), .correct("a")])
        
        text = [.missing("1"), .correct("a"), .extra("a"), .extra("a")]
        expect([.missing("1"), .extra("a"), .correct("a"), .extra("a")])
        
        text = [.missing("1"), .missing("2"), .correct("a"), .extra("a"), .extra("a")]
        expect([.missing("1"), .missing("2"), .extra("a"), .extra("a"), .correct("a")])
        
        text = [.missing("1"), .correct("a"), .extra("a"), .missing("2"), .extra("a")]
        expect([.missing("1"), .extra("a"), .correct("a"), .missing("2"), .extra("a")])
        
        text = [.missing("1"), .correct("a"), .missing("2"), .extra("a")]
        expect([.missing("1"), .extra("a"), .correct("a"), .missing("2")])
        
        text = [.missing("1"), .correct("a"), .missing("2"), .extra("a"), .correct("b"), .extra("b")]
        expect([.missing("1"), .extra("a"), .correct("a"), .missing("2"), .extra("b"), .correct("b")])
        
        
        text = [.missing("1"), .missing("2"), .correct("a"), .correct("a"), .missing("3"), .missing("4"), .extra("a"), .correct("b"), .extra("b"), .extra("b")]
        expect([.missing("1"), .missing("2"), .extra("a"), .correct("a"), .correct("a"), .missing("3"), .missing("4"), .extra("b"), .extra("b"), .correct("b")])
        
        
        text = [.missing("1"), .missing("2"), .correct("A"), .extra("a"), .extra("A")]
        expect([.missing("1"), .missing("2"), .extra("A"), .extra("a"), .correct("A")])
        
    }
    
}
