import Testing
@testable import Typofall

struct TFOriginTests {
    
    @Test func text() async throws {
        
        var inputString = String()
        var idealString = String()
        var configuration = TFConfiguration()
        var result: TFText {
            return TFOrigin.text(comparing: inputString, against: idealString, using: configuration)
        }
        
        #expect(result == .empty)
        
        inputString = "a"; idealString = ""
        #expect(result == TFText(inputString, annotation: .extra))
        
        inputString = ""; idealString = "a"
        #expect(result == TFText(idealString, annotation: .missing))
        
        inputString = "abc"; idealString = ""
        #expect(result == TFText(inputString, annotation: .extra))
        
        inputString = ""; idealString = "abc"
        #expect(result == TFText(idealString, annotation: .missing))
        
        inputString = "abc"; idealString = "abc"
        #expect(result == TFText(inputString, annotation: .correct))
        
        inputString = "abc"; idealString = "12"
        #expect(result == TFText(inputString, annotation: .extra))
        
        
        inputString = "aa"; idealString = "a"
        #expect(result == [.correct("a"), .extra("a")])
        
        inputString = "a--b"; idealString = "A+B"
        #expect(result == [.correct("a"), .missing("+"), .extra("-"), .extra("-"), .correct("b")])
        
        inputString = "ab-cd"; idealString = "abcd"
        #expect(result == [.correct("a"), .correct("b"), .extra("-"), .correct("c"), .correct("d")])
        
        inputString = "ab"; idealString = "a+b"
        #expect(result == [.correct("a"), .missing("+"), .correct("b")])
        
        
        configuration.textCaseStrategy = .sensitive(.compared)
        
        inputString = "b--a"; idealString = "A+B"
        #expect(result == [.extra("b"), .extra("-"), .extra("-"), .correct("a", hasCorrectCase: false), .missing("+"), .missing("B")])
        
        
        configuration.textCaseStrategy = .insensitive(.capitalized)
        
        inputString = "hola"; idealString = "hello"
        #expect(result == [.correct("H"), .missing("e"), .extra("o"), .correct("l"), .missing("l"), .missing("o"), .extra("a")])
        
        inputString = "hello world"; idealString = "Hello World"
        #expect(result == TFText("Hello World", annotation: .correct))
        
        
        configuration = TFConfiguration()
        configuration.textNormalizations = [.trimmingWhitespace]
        
        inputString = "  abc  "; idealString = "abc"
        #expect(result == TFText("abc", annotation: .correct))
        
        inputString = "   "; idealString = "abc"
        #expect(result == TFText(idealString, annotation: .missing))
        
        inputString = "abc"; idealString = "   "
        #expect(result == TFText(inputString, annotation: .extra))
        
        
        configuration.textNormalizations = [.collapsingWhitespace]
        inputString = "a   b   c"; idealString = "a b c"
        #expect(result == TFText("a b c", annotation: .correct))
        
        configuration.requiredQuantityOfCorrectCharacters = .all
        inputString = "abc"; idealString = "def"
        #expect(result == TFText("abc", annotation: .extra))
        
    }
    
    
    @Test func addingMissingChars() async throws {
        
        var inputString = String()
        var idealString = String()
        var configuration = TFConfiguration()
        var result: TFText {
            let basis = TFAlgebra.basis(diffing: inputString, against: idealString)
            let wrongText = TFText(inputString, .extra, configuration.textCaseStrategy.transformation)
            let wrongAndCorrectText = TFOrigin.addingCorrectChars(to: wrongText, relyingOn: idealString, basedOn: basis, conformingTo: configuration)
            return TFOrigin.addingMissingChars(to: wrongAndCorrectText, relyingOn: idealString, basedOn: basis, conformingTo: configuration)
        }
        
        inputString = "a"; idealString = "a"
        #expect(result == [.correct("a")])
        
        inputString = "a-b-c"; idealString = "+abc+"
        #expect(result == [.missing("+"), .correct("a"), .extra("-"), .correct("b"), .extra("-"), .correct("c"), .missing("+")])
        
        inputString = "--a"; idealString = "a"
        #expect(result == [.extra("-"), .extra("-"), .correct("a")])
        
        inputString = "--a"; idealString = "+a"
        #expect(result == [.missing("+"), .extra("-"), .extra("-"), .correct("a")])
        
        inputString = "--a"; idealString = "a+"
        #expect(result == [.extra("-"), .extra("-"), .correct("a"), .missing("+")])
        
        inputString = "a--b"; idealString = "a+b"
        #expect(result == [.correct("a"), .missing("+"), .extra("-"), .extra("-"), .correct("b")])
        
        inputString = "b--a"; idealString = "a+b"
        #expect(result == [.extra("b"), .extra("-"), .extra("-"), .correct("a"), .missing("+"), .missing("b")])
        
        
        configuration.textCaseStrategy = .sensitive(.compared)
        
        inputString = "a--b"; idealString = "A+B"
        #expect(result == [.correct("a", hasCorrectCase: false), .missing("+"), .extra("-"), .extra("-"), .correct("b", hasCorrectCase: false)])
        
    }
    
    
    @Test func addingCorrectChars() async throws {
        
        var inputString = String()
        var idealString = String()
        var configuration = TFConfiguration()
        var result: TFText {
            let basis = TFAlgebra.basis(diffing: inputString, against: idealString)
            let wrongText = TFText(inputString, .extra, configuration.textCaseStrategy.transformation)
            return TFOrigin.addingCorrectChars(to: wrongText, relyingOn: idealString, basedOn: basis, conformingTo: configuration)
        }
        
        
        inputString = "a"; idealString = "a"
        #expect(result == [.correct("a")])
        
        inputString = "a-b-c"; idealString = "+abc+"
        #expect(result == [.correct("a"), .extra("-"), .correct("b"), .extra("-"), .correct("c")])
        
        inputString = "--a"; idealString = "a"
        #expect(result == [.extra("-"), .extra("-"), .correct("a")])
        
        inputString = "--a"; idealString = "+a"
        #expect(result == [.extra("-"), .extra("-"), .correct("a")])
        
        inputString = "--a"; idealString = "a+"
        #expect(result == [.extra("-"), .extra("-"), .correct("a")])
        
        inputString = "a--b"; idealString = "a+b"
        #expect(result == [.correct("a"), .extra("-"), .extra("-"), .correct("b")])
        
        inputString = "b--a"; idealString = "a+b"
        #expect(result == [.extra("b"), .extra("-"), .extra("-"), .correct("a")])
        
        
        configuration.textCaseStrategy = .sensitive(.compared)
        
        inputString = "a"; idealString = "A"
        #expect(result == [.correct("a", hasCorrectCase: false)])
        
        inputString = "A"; idealString = "a"
        #expect(result == [.correct("A", hasCorrectCase: false)])
        
        inputString = "a--b"; idealString = "A+B"
        #expect(result == [.correct("a", hasCorrectCase: false), .extra("-"), .extra("-"), .correct("b", hasCorrectCase: false)])
        
    }
    
    
    @Test func checkQuickCompliance() async throws {
        
        var inputString = String()
        var idealString = String()
        var configuration = TFConfiguration()
        var result: Bool {
            return TFOrigin.checkQuickCompliance(for: inputString, relyingOn: idealString, to: configuration)
        }
        
        inputString = "abc"; idealString = "123"
        #expect(result == false)
        
        inputString = "abacaba"; idealString = "12345c"
        #expect(result == true)
        
        
        // `.requiredQuantityOfCorrectCharacters`
        
        inputString = "---a"; idealString = "a+++"
        
        configuration.requiredQuantityOfCorrectCharacters = .low
        #expect(result == true)
        configuration.requiredQuantityOfCorrectCharacters = .one
        #expect(result == true)
        
        configuration.requiredQuantityOfCorrectCharacters = .half
        #expect(result == false)
        configuration.requiredQuantityOfCorrectCharacters = .two
        #expect(result == false)
        
        inputString = "--aa"; idealString = "aa++"
        
        configuration.requiredQuantityOfCorrectCharacters = .half
        #expect(result == true)
        configuration.requiredQuantityOfCorrectCharacters = .two
        #expect(result == true)
        
        configuration.requiredQuantityOfCorrectCharacters = .high
        #expect(result == false)
        configuration.requiredQuantityOfCorrectCharacters = .three
        #expect(result == false)
        
        inputString = "-aaa"; idealString = "aaa+"
        
        configuration.requiredQuantityOfCorrectCharacters = .high
        #expect(result == true)
        configuration.requiredQuantityOfCorrectCharacters = .three
        #expect(result == true)
        
        configuration.requiredQuantityOfCorrectCharacters = .all
        #expect(result == false)
        configuration.requiredQuantityOfCorrectCharacters = .number(4)
        #expect(result == false)
        
        inputString = "aaaa"; idealString = "aaaa"
        
        configuration.requiredQuantityOfCorrectCharacters = .all
        #expect(result == true)
        configuration.requiredQuantityOfCorrectCharacters = .number(5)
        #expect(result == true)
        
        inputString = "a123"; idealString = "65a4"
        configuration.requiredQuantityOfCorrectCharacters = .low
        #expect(result == true)
        configuration.requiredQuantityOfCorrectCharacters = .one
        #expect(result == true)
        
        inputString = "a12b"; idealString = "b3a4"
        configuration.requiredQuantityOfCorrectCharacters = .half
        #expect(result == true)
        configuration.requiredQuantityOfCorrectCharacters = .two
        #expect(result == true)
        
        inputString = "ac2b"; idealString = "b3ac"
        configuration.requiredQuantityOfCorrectCharacters = .high
        #expect(result == true)
        configuration.requiredQuantityOfCorrectCharacters = .three
        #expect(result == true)
        
        inputString = "acbd"; idealString = "dcab"
        configuration.requiredQuantityOfCorrectCharacters = .all
        #expect(result == true)
        configuration.requiredQuantityOfCorrectCharacters = .number(4)
        #expect(result == true)
        
        inputString = "0b94837a61"; idealString = "1234567890"
        configuration.requiredQuantityOfCorrectCharacters = .coefficient(0.8)
        #expect(result == true)
        configuration.requiredQuantityOfCorrectCharacters = .number(8)
        #expect(result == true)
        
        
        // `.acceptableQuantityOfWrongCharacters`
        configuration = TFConfiguration()
        
        inputString = "a"; idealString = "a+++"
        
        configuration.acceptableQuantityOfWrongCharacters = .high
        #expect(result == true)
        configuration.acceptableQuantityOfWrongCharacters = .three
        #expect(result == true)
        
        configuration.acceptableQuantityOfWrongCharacters = .half
        #expect(result == false)
        configuration.acceptableQuantityOfWrongCharacters = .two
        #expect(result == false)
        
        inputString = "--aa"; idealString = "aa++"
        
        configuration.acceptableQuantityOfWrongCharacters = .half
        #expect(result == true)
        configuration.acceptableQuantityOfWrongCharacters = .two
        #expect(result == true)
        
        configuration.acceptableQuantityOfWrongCharacters = .low
        #expect(result == false)
        configuration.acceptableQuantityOfWrongCharacters = .one
        #expect(result == false)
        
        inputString = "-aaa"; idealString = "aaa+"
        
        configuration.acceptableQuantityOfWrongCharacters = .low
        #expect(result == true)
        configuration.acceptableQuantityOfWrongCharacters = .one
        #expect(result == true)
        
        configuration.acceptableQuantityOfWrongCharacters = .coefficient(0.0)
        #expect(result == false)
        configuration.acceptableQuantityOfWrongCharacters = .zero
        #expect(result == false)
        
        inputString = "aaaa"; idealString = "aaaa"
        
        configuration.acceptableQuantityOfWrongCharacters = .coefficient(0.0)
        #expect(result == true)
        configuration.acceptableQuantityOfWrongCharacters = .zero
        #expect(result == true)
        
        
        // both
        configuration = TFConfiguration()
        
        inputString = "ab--"; idealString = "abcd"
        
        configuration.requiredQuantityOfCorrectCharacters = .half
        configuration.acceptableQuantityOfWrongCharacters = .two
        #expect(result == true)
        
        configuration.requiredQuantityOfCorrectCharacters = .half
        configuration.acceptableQuantityOfWrongCharacters = .one
        #expect(result == false)
        
        configuration.requiredQuantityOfCorrectCharacters = .high
        configuration.acceptableQuantityOfWrongCharacters = .two
        #expect(result == false)
        
    }
    
}
