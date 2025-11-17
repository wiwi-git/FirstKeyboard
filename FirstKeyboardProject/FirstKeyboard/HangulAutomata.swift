enum HangulStatus {
    case start //s0
    case chosung //s1
    case joongsung, dJoongsung //s2,s3
    case jongsung, dJongsung //s4, s5
    case endOne, endTwo //s6,s7
}

//입력된 키의 종류 판별 정의
enum HangulCHKind {
    case consonant //자음
    case vowel  //모음
}

//키 입력마다 쌓이는 입력 스택 정의
struct InpStack {
    var curhanst: HangulStatus //상태
    var key: UInt32 //방금 입력된 키 코드
    var charCode: String //조합된 코드
    var chKind: HangulCHKind // 입력된 키가 자음인지 모임인지
}

final class HangulAutomata {
    
    var buffer: [String] = []
    
    var inpStack: [InpStack] = []
    
    var currentHangulState: HangulStatus?
    
    private var chKind = HangulCHKind.vowel
    
    private var charCode: String = ""
    private var oldKey: UInt32 = 0
    private var oldChKind: HangulCHKind?
    private var keyCode: UInt32 = 0
    
    private var chosungTable: [String] = ["ㄱ","ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    
    private var joongsungTable: [String] = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"]
    
    private var jongsungTable: [String] = [" ", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ","ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    
    private var dJoongTable: [[String]] = [
        ["ㅗ","ㅏ","ㅘ"],
        ["ㅗ","ㅐ","ㅙ"],
        ["ㅗ","ㅣ","ㅚ"],
        ["ㅜ","ㅓ","ㅝ"],
        ["ㅜ","ㅔ","ㅞ"],
        ["ㅜ","ㅣ","ㅟ"],
        ["ㅡ","ㅣ","ㅢ"],
        ["ㅏ","ㅣ","ㅐ"],
        ["ㅓ","ㅣ","ㅔ"],
        ["ㅕ","ㅣ","ㅖ"],
        ["ㅑ","ㅣ","ㅒ"],
        ["ㅘ","ㅣ","ㅙ"]
    ]
    
    private var dJongTable: [[String]] = [
        ["ㄱ","ㅅ","ㄳ"],
        ["ㄴ","ㅈ","ㄵ"],
        ["ㄴ","ㅎ","ㄶ"],
        ["ㄹ","ㄱ","ㄺ"],
        ["ㄹ","ㅁ","ㄻ"],
        ["ㄹ","ㅂ","ㄼ"],
        ["ㄹ","ㅅ","ㄽ"],
        ["ㄹ","ㅌ","ㄾ"],
        ["ㄹ","ㅍ","ㄿ"],
        ["ㄹ","ㅎ","ㅀ"],
        ["ㅂ","ㅅ","ㅄ"]
    ]
    
    private func joongsungPair() -> Bool {
        for i in 0..<dJoongTable.count {
            if dJoongTable[i][0] == joongsungTable[Int(oldKey)] && dJoongTable[i][1] == joongsungTable[Int(keyCode)] {
                keyCode = UInt32(joongsungTable.firstIndex(of: dJoongTable[i][2]) ?? 0)
                return true
            }
        }
        return false
    }
    
    private func jongsungPair() -> Bool {
        for i in 0..<dJongTable.count {
            if dJongTable[i][0] == jongsungTable[Int(oldKey)] && dJongTable[i][1] == chosungTable[Int(keyCode)] {
                keyCode = UInt32(jongsungTable.firstIndex(of: dJongTable[i][2]) ?? 0)
                return true
            }
        }
        return false
    }
    
    private func isJoongSungPair(first: String, result: String) -> Bool {
        for i in 0..<dJoongTable.count {
            if dJoongTable[i][0] == first && dJoongTable[i][2] == result {
                return true
            }
        }
        return false
    }
    
    private func decompositionChosung(charCode: UInt32) -> UInt32 {
        let unicodeHangul = charCode - 0xAC00
        let jongsung = (unicodeHangul) % 28
        let joongsung = ((unicodeHangul - jongsung) / 28) % 21
        let chosung = (((unicodeHangul - jongsung) / 28) - joongsung) / 21
        return chosung
    }
    
    private func decompositionChosungJoongsung(charCode: UInt32) -> UInt32 {
        let unicodeHangul = charCode - 0xAC00
        let jongsung = (unicodeHangul) % 28
        let joongsung = ((unicodeHangul - jongsung) / 28) % 21
        let chosung = (((unicodeHangul - jongsung) / 28) - joongsung) / 21
        return combinationHangul(chosung: chosung, joongsung: joongsung, jongsung: keyCode)
    }
    
    private func combinationHangul(chosung: UInt32 = 0, joongsung: UInt32, jongsung: UInt32 = 0) -> UInt32 {
        return (((chosung * 21) + joongsung) * 28) + jongsung + 0xAC00
    }
    
    func deleteBuffer() {
        if inpStack.count == 0 {
            if buffer.count > 0 {
                buffer.removeLast()
            }
        } else {
            if let popHanguel = inpStack.popLast() {
                if popHanguel.curhanst == .chosung {
                    buffer.removeLast()
                } else if popHanguel.curhanst == .joongsung || popHanguel.curhanst == .dJoongsung {
                    if inpStack[inpStack.count - 1].curhanst == .jongsung || inpStack[inpStack.count - 1].curhanst == .dJongsung {
                        buffer.removeLast()
                    }
                    buffer[buffer.count - 1] = inpStack[inpStack.count - 1].charCode
                } else {
                    if inpStack.isEmpty {
                        buffer.removeLast()
                    } else if popHanguel.chKind == .vowel {
                        if inpStack[inpStack.count - 1].curhanst == .jongsung {
                            if inpStack[inpStack.count - 1].chKind == .vowel {
                                if isJoongSungPair(first: joongsungTable[Int(inpStack[inpStack.count - 1].key)] , result: joongsungTable[Int(popHanguel.key)]) {
                                    buffer[buffer.count - 1] = inpStack[inpStack.count - 1].charCode
                                } else {
                                    buffer.removeLast()
                                }
                            }
                        } else {
                            buffer.removeLast()
                        }
                    } else {
                        buffer[buffer.count - 1] = inpStack[inpStack.count - 1].charCode
                    }
                }
                if inpStack.isEmpty {
                    currentHangulState = nil
                } else {
                    currentHangulState = inpStack[inpStack.count - 1].curhanst
                    oldKey = inpStack[inpStack.count - 1].key
                    oldChKind = inpStack[inpStack.count - 1].chKind
                    charCode = inpStack[inpStack.count - 1].charCode
                }
            }
        }
    }
}
extension HangulAutomata {
    /// 초기화 buffer,inpStack,currentHangulState
    func removeBuffer() {
        buffer.removeAll()
        inpStack.removeAll()
        currentHangulState = nil
    }
    
    /// 변수들 초기값으로 재지정
    func reset() {
        removeBuffer()
        charCode = ""
        oldKey = 0
        oldChKind = nil
        print("hangule.reset")
    }
    
    /// 키가 한글 자모(초성/중성)에 속하지 않으면 true
    func isNonHangul(_ key: String) -> Bool {
        if chosungTable.contains(key) { return false }
        if joongsungTable.contains(key) { return false }
        return true
    }
    
    func hangulAutomata(key: String) {
        
        if isNonHangul(key) {
            print("isNonHangul!!! \(currentHangulState)")
            if currentHangulState != nil {
                inpStack.removeAll()
                currentHangulState = nil
                oldChKind = nil
                oldKey = 0
                charCode = ""
            }
            // 그리고 비한글 키를 그대로 버퍼에 추가
            buffer.append(key)
            return
        }
        
        // chKind, keyCode 설정
        var canBeJongsung: Bool = false
        if joongsungTable.contains(key) {
            chKind = .vowel
            keyCode = UInt32(joongsungTable.firstIndex(of: key) ?? 0)
        } else {
            chKind = .consonant
            keyCode = UInt32(chosungTable.firstIndex(of: key) ?? 0)
            if !((key == "ㄸ") || (key == "ㅉ") || (key == "ㅃ")) {
                canBeJongsung = true
            }
        }
        
        // 이전 상태 값 세팅 (있으면)
        if currentHangulState != nil {
            oldKey = inpStack.last?.key ?? 0
            oldChKind = inpStack.last?.chKind
        } else {
            // 조합이 비어있으면 시작 상태와 buffer 슬롯 추가
            currentHangulState = .start
            buffer.append("") // 새로운 조합용 슬롯
        }
        
        // MARK: - 오토마타 전이 알고리즘
        switch currentHangulState {
        case .start:
            if chKind == .consonant {
                currentHangulState = .chosung
            } else {
                currentHangulState = .jongsung
            }
        case .chosung:
            if chKind == .vowel {
                currentHangulState = .joongsung
            } else {
                currentHangulState = .endOne
            }
        case .joongsung:
            if canBeJongsung {
                currentHangulState = .jongsung
            } else if joongsungPair() {
                currentHangulState = .dJoongsung
            } else {
                currentHangulState = .endOne
            }
        case .dJoongsung:
            if joongsungPair() {
                currentHangulState = .dJoongsung
            } else if canBeJongsung {
                currentHangulState = .jongsung
            } else {
                currentHangulState = .endOne
            }
        case .jongsung:
            if (chKind == .consonant) && jongsungPair() {
                currentHangulState = .dJongsung
            } else if chKind == .vowel {
                currentHangulState = .endTwo
            } else {
                currentHangulState = .endOne
            }
        case .dJongsung:
            if chKind == .vowel {
                currentHangulState = .endTwo
            } else {
                currentHangulState = .endOne
            }
        default:
            break
        }
        
        // MARK: - 오토마타 상태 별 작업 알고리즘
        switch currentHangulState {
        case .chosung:
            charCode = chosungTable[Int(keyCode)]
        case .joongsung:
            charCode = String(Unicode.Scalar(combinationHangul(chosung: oldKey, joongsung: keyCode)) ?? Unicode.Scalar(0))
        case .dJoongsung:
            let currentChosung = decompositionChosung(charCode: Unicode.Scalar(charCode)?.value ?? 0)
            charCode = String(Unicode.Scalar(combinationHangul(chosung: currentChosung, joongsung: keyCode)) ?? Unicode.Scalar(0))
        case .jongsung:
            if canBeJongsung {
                keyCode = UInt32(jongsungTable.firstIndex(of: key) ?? 0)
                let currentCharCode =  Unicode.Scalar(charCode)?.value ?? 0
                charCode = String(Unicode.Scalar(decompositionChosungJoongsung(charCode: currentCharCode)) ?? Unicode.Scalar(0))
            } else {
                charCode = key
            }
        case .dJongsung:
            let currentCharCode = Unicode.Scalar(charCode)?.value ?? 0
            charCode = String(Unicode.Scalar(decompositionChosungJoongsung(charCode: currentCharCode)) ?? Unicode.Scalar(0))
            keyCode = UInt32(jongsungTable.firstIndex(of: key) ?? 0)
        case .endOne:
            if chKind == .consonant {
                charCode = chosungTable[Int(keyCode)]
                currentHangulState = .chosung
            } else {
                charCode = joongsungTable[Int(keyCode)]
                currentHangulState = .jongsung
            }
            buffer.append("")
        case .endTwo:
            if oldChKind == .consonant {
                oldKey = UInt32(chosungTable.firstIndex(of: jongsungTable[Int(oldKey)]) ?? 0)
                charCode =  String(Unicode.Scalar(combinationHangul(chosung: oldKey, joongsung: keyCode)) ?? Unicode.Scalar(0))
                currentHangulState = .joongsung
                if inpStack.count >= 2 {
                    buffer[buffer.count - 1] = inpStack[inpStack.count - 2].charCode
                }
                buffer.append("")
            } else {
                if !joongsungPair() {
                    buffer.append("")
                }
                charCode = joongsungTable[Int(keyCode)]
                currentHangulState = nil
                currentHangulState = .jongsung
            }
        default:
            break
        }
        
        // inpStack에 현재 입력 기록 추가
        let entry = InpStack(curhanst: currentHangulState ?? .start, key: keyCode, charCode: String(Unicode.Scalar(charCode) ?? Unicode.Scalar(0)), chKind: chKind)
        inpStack.append(entry)
        
        if buffer.isEmpty {
            buffer.append(String(Unicode.Scalar(charCode) ?? Unicode.Scalar(0)))
        } else {
            buffer[buffer.count - 1] = String(Unicode.Scalar(charCode) ?? Unicode.Scalar(0))
        }
    }
}

