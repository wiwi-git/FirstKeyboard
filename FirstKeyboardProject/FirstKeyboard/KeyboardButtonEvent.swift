//
//  KeyboardButtonEvent.swift
//  FirstKeyboardProject
//
//  Created by 위대연 on 11/8/25.
//  Copyright © 2025 위대연. All rights reserved.
//

import UIKit
import Foundation

extension KeyboardViewController {
    @objc func touchUpChartacterKey(_ sender:DKey) {
        //insertCharacter
        defer {
            UIDevice.current.playInputClick()
            if isPushedShift { isPushedShift = false }
        }
        
        guard let char = sender.titleLabel?.text else {
            return
        }
        
        insertText(char: char)
    }
    
    private func insertText(char: String) {
        if self.language == .en {
            self.textDocumentProxy.insertText(char)
            return
        }
        
        let currentID = textDocumentProxy.documentIdentifier
        if currentID != lastDocumentIdentifier {
            // 필드 변경됨 -> 오토마타 상태 초기화
            self.hangul.reset()
            self.setLastDocumentIdentifier(currentID)
        }
        
        overwrite {
            self.hangul.hangulAutomata(key: char)
        }
    }
    
    // TODO: 이 부분을 다른 키 이벤트와 합치고 싶은데 아이디어가 안떠오름
    @objc func touchUpSpaceKey() {
        defer {
            UIDevice.current.playInputClick()
            if isPushedShift { isPushedShift = false }
        }
        
        // 공백은 조합을 끊고, 버퍼를 리셋
        self.hangul.reset()
        self.textDocumentProxy.insertText(" ")
    }
    
    @objc func touchUpReturnKey(_ sender:DKey) {
        self.textDocumentProxy.insertText("\n")
        UIDevice.current.playInputClick()
        if isPushedShift { isPushedShift = false }
    }
    
    @objc func touchUpDeleteKey() {
        self.deleteCharacterBeforeCursor()
        if isPushedShift { isPushedShift = false }
    }
    
    @objc func touchUpShiftKey() {
        UIDevice.current.playInputClick()
        self.isPushedShift.toggle()
    }
    
    @objc func deleteCharacterBeforeCursor() {
        defer {
            UIDevice.current.playInputClick()
        }
        
        if language == .en {
            self.textDocumentProxy.deleteBackward()
            return
        }
        // ko
        
        
        // 빈값
        if hangul.buffer.isEmpty && hangul.inpStack.isEmpty {
            self.textDocumentProxy.deleteBackward()
            return
        }
        
        overwrite {
            self.hangul.deleteBuffer()
        }
    }
    
    private func overwrite(middle: () -> Void) {
        // 기존 입력한 텍스트
        let oldBufferText = self.hangul.buffer.joined()
        
        // 버퍼 변화
        middle()
        
        // 변화된 텍스트
        let newBufferText = self.hangul.buffer.joined()
        
        // 입력
        for _ in 0..<oldBufferText.count {
            self.textDocumentProxy.deleteBackward()
        }
        self.textDocumentProxy.insertText(newBufferText)
    }
    
    @objc func touchUpChangeModeKey() {
        defer {
            hangul.clearStack()
            UIDevice.current.playInputClick()
        }
        
        self.language = self.language == .en ? .ko : .en
        let isNewEn: Bool = self.language == .en
        
        // ButtonKind
        let line1Kind: TextString.ButtonKind = isNewEn ? .en(.l1) : .ko(.l1)
        let line2Kind: TextString.ButtonKind = isNewEn ? .en(.l2) : .ko(.l2)
        let line3Kind: TextString.ButtonKind = isNewEn ? .en(.l3) : .ko(.l3)
        
        // LineText
        let line1Text = TextString.getLineText(buttonKind: line1Kind)
        let line2Text = TextString.getLineText(buttonKind: line2Kind)
        let line3Text = TextString.getLineText(buttonKind: line3Kind)
        
        // 문자줄1 변경
        for (i, _) in self.charLine1Buttons.enumerated() {
            guard line1Text.generalText.count == charLine1Buttons.count else {
                print("error - changeMode1, 버튼 텍스트수와 버튼 수가 같지 않습니다.")
                return
            }
            self.charLine1Buttons[i].setTitle(text: line1Text.generalText[i], option: line1Text.optionText[i], for: .normal)
        }
        // 문자줄2 변경
        for (i, _) in self.charLine2Buttons.enumerated() {
            guard line2Text.generalText.count == charLine2Buttons.count else {
                print("error - changeMode2, 버튼 텍스트수와 버튼 수가 같지 않습니다.")
                return
            }
            self.charLine2Buttons[i].setTitle(text: line2Text.generalText[i], option: line2Text.optionText[i], for: .normal)
        }
        // 문자줄3 변경
        for (i, _) in self.charLine3Buttons.enumerated() {
            guard line3Text.generalText.count == charLine3Buttons.count else {
                print("error - changeMode3, 버튼 텍스트수와 버튼 수가 같지 않습니다.")
                return
            }
            self.charLine3Buttons[i].setTitle(text: line3Text.generalText[i], option: line3Text.optionText[i], for: .normal)
        }
    }
    
    @objc func longTouchDeleteGesture(_ sender:UIGestureRecognizer) {
        if sender.state == .began {
            self.longPressDeleteButtonTimer =
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.deleteCharacterBeforeCursor), userInfo: nil, repeats: true)
        } else if sender.state == .ended || sender.state == .cancelled {
            self.longPressDeleteButtonTimer?.invalidate()
            self.longPressDeleteButtonTimer = nil
        }
    }
    
    /*
     @objc func longTouchChartacterKey(_ sender:DKey) {
     let optionText = sender.getOptionText()
     if optionText.count > 0 {
     self.textDocumentProxy.insertText(sender.getOptionText())
     } else if let text = sender.titleLabel?.text {
     self.textDocumentProxy.insertText(text)
     }
     if isPushedShift { isPushedShift = false }
     }*/
    
    @objc func longTouchCharacterKeyGesture(_ sender:UILongPressGestureRecognizer) {
        if sender.state == .ended {
            let tagValue:Int = sender.view?.tag ?? 0
            guard tagValue >= 100 else { return }
            
            let text:String
            let floor:Int = tagValue / 100
            switch floor {
            case 1:
                let index = tagValue - 100
                text = TextString.OptionKeyButtonText[.l1]![index]
            case 2:
                let index = tagValue - 200
                text = TextString.OptionKeyButtonText[.l2]![index]
            case 3:
                let index = tagValue - 300
                text = TextString.OptionKeyButtonText[.l3]![index]
            default: return
            }
            
            insertText(char: text)
            UIDevice.current.playInputClick()
        }
    }
}
