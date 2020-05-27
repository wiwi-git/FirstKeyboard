//
//  KeyboardViewController.swift
//  FirstKeyboard
//
//  Created by 위대연 on 2020/05/23.
//  Copyright © 2020 위대연. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    
    var nextKeyboardButton: KeyboardButton!
    var spaceButton: KeyboardButton!
    var shiftButton: KeyboardButton!
    var returnButton: KeyboardButton!
    var deleteButton: KeyboardButton!
    var numberLineButtons: [KeyboardButton]!
    var charLine1Buttons: [KeyboardButton]!
    var charLine2Buttons: [KeyboardButton]!
    var charLine3Buttons: [KeyboardButton]!
    
    var longPressDeleteButtonTimer: Timer?
    
    var isPushedShift = false {
        didSet{
            self.changedShiftValue()
        }
    }
    var language:TextString.language = .en
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Add custom view sizing constraints here
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch language {
        case .en:
            self.numberLineButtons = self.createCharacterButtons(kind: .en(.number))
            self.charLine1Buttons = self.createCharacterButtons(kind: .en(.l1))
            self.charLine2Buttons = self.createCharacterButtons(kind: .en(.l2))
            self.charLine3Buttons = self.createCharacterButtons(kind: .en(.l3))
        case .ko:
            self.numberLineButtons = self.createCharacterButtons(kind: .ko(.number))
            self.charLine1Buttons = self.createCharacterButtons(kind: .ko(.l1))
            self.charLine2Buttons = self.createCharacterButtons(kind: .ko(.l2))
            self.charLine3Buttons = self.createCharacterButtons(kind: .ko(.l3))
        }
        
        self.nextKeyboardButton = KeyboardButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        self.spaceButton = KeyboardButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        self.shiftButton = KeyboardButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        self.returnButton = KeyboardButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        self.deleteButton = KeyboardButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        self.nextKeyboardButton.setTitle(text: "", option: "", for: .normal)
        self.shiftButton.setTitle(text: "⇧", option: "", for: .normal)
        self.deleteButton.setTitle(text: "", option: "", for: .normal)
        self.spaceButton.setTitle(text: "space", option: "", for: .normal)
        self.nextKeyboardButton.button.setImage(UIImage(named: "NextKeyboard"), for: .normal)
        self.deleteButton.button.setImage(UIImage(named: "Backspace"), for: .normal)
       
        self.setButtonsLayout()
        
        self.nextKeyboardButton.button.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        self.shiftButton.button.addTarget(self, action: #selector(touchUpShiftKey), for: .touchUpInside)
        self.deleteButton.button.addTarget(self, action: #selector(touchUpDeleteKey), for: .touchUpInside)
        self.spaceButton.button.addTarget(self, action: #selector(touchUpSpaceKey), for: .touchUpInside)
        self.returnButton.button.addTarget(self, action: #selector(touchUpReturnKey(_:)), for: .touchUpInside)
        
        let longTouchDeleteButtonGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTouchDeleteGesture(_:)))
        longTouchDeleteButtonGesture.minimumPressDuration = 0.2
        deleteButton.button.addGestureRecognizer(longTouchDeleteButtonGesture)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        self.setReturnKeyType()
        let backgroundColor = UIColor(named: "Background")
        self.view.backgroundColor = backgroundColor
    }

    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        /*
        let colorScheme: ColorScheme

        if textDocumentProxy.keyboardAppearance == .dark {
            print("colorScheme .dark")
          colorScheme = .dark
        } else {
            print("colorScheme .light")
          colorScheme = .light
        }
        setColorScheme(colorScheme)*/
        //setColorScheme2()
        
        //let buttonTextColor = UIColor(named: "ButtonText")
        //let buttonBackgroundColor = UIColor(named: "ButtonBackground")
        //let buttonHighlightColor = UIColor(named: "ButtonHighlight")
    }
    
    func setButtonsLayout() {
        let numberLineStackView = createCharLineStackView(buttons: numberLineButtons)
        let charLine1StackView = createCharLineStackView(buttons: charLine1Buttons)
        let charLine2StackView = createCharLineStackView(buttons: charLine2Buttons)
        let charLine3StackView = createCharLineStackView(buttons: charLine3Buttons)
        
        let addedFuncKeyLine3Stack = UIStackView(arrangedSubviews: [shiftButton, charLine3StackView, deleteButton])
        addedFuncKeyLine3Stack.alignment = .fill
        addedFuncKeyLine3Stack.axis = .horizontal
        addedFuncKeyLine3Stack.distribution = .fill
        addedFuncKeyLine3Stack.spacing = 16
        addedFuncKeyLine3Stack.translatesAutoresizingMaskIntoConstraints = false
        
        let funcLineStackView = UIStackView(arrangedSubviews: [nextKeyboardButton, spaceButton, returnButton])
        funcLineStackView.alignment = .fill
        funcLineStackView.axis = .horizontal
        funcLineStackView.distribution = .fill
        funcLineStackView.spacing = 4
        funcLineStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(numberLineStackView)
        self.view.addSubview(charLine1StackView)
        self.view.addSubview(charLine2StackView)
        self.view.addSubview(addedFuncKeyLine3Stack)
        self.view.addSubview(funcLineStackView)
        
        let safeGuide = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            numberLineStackView.topAnchor.constraint(equalTo: safeGuide.topAnchor),
            numberLineStackView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor, constant: 4),
            numberLineStackView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor, constant: -4),
            numberLineStackView.heightAnchor.constraint(equalToConstant: 40),
            
            charLine1StackView.topAnchor.constraint(equalTo: numberLineStackView.bottomAnchor, constant: 4),
            charLine1StackView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor,constant: 4),
            charLine1StackView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor, constant: -4),
            charLine1StackView.heightAnchor.constraint(equalToConstant: 40),
            
            charLine2StackView.topAnchor.constraint(equalTo: charLine1StackView.bottomAnchor, constant: 4),
            charLine2StackView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor,constant: 24),
            charLine2StackView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor, constant: -24),
            charLine2StackView.heightAnchor.constraint(equalToConstant: 40),
            
            shiftButton.widthAnchor.constraint(equalToConstant: 45),
            deleteButton.widthAnchor.constraint(equalToConstant: 45),
            
            addedFuncKeyLine3Stack.topAnchor.constraint(equalTo: charLine2StackView.bottomAnchor, constant: 4),
            addedFuncKeyLine3Stack.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor,constant: 4),
            addedFuncKeyLine3Stack.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor, constant: -4),
            addedFuncKeyLine3Stack.heightAnchor.constraint(equalToConstant: 40),
            
            
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: 40),
            nextKeyboardButton.heightAnchor.constraint(equalToConstant: 40),
            returnButton.widthAnchor.constraint(equalToConstant: 92),
            
            funcLineStackView.topAnchor.constraint(equalTo: addedFuncKeyLine3Stack.bottomAnchor, constant: 4),
            funcLineStackView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor, constant: 4),
            funcLineStackView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor, constant: -4),
            funcLineStackView.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor)
        ])
    }
    
    func setReturnKeyType(type: UIReturnKeyType? = UIReturnKeyType.default) {
        let textString = TextString.KeyboardTypeString

        switch type {
        case .continue:
            self.returnButton.setTitle(text: textString[.continue], option: "", for: .normal)
        case .default:
            self.returnButton.setTitle(text: textString[.default], option: "", for: .normal)
        case .done:
            self.returnButton.setTitle(text: textString[.done], option: "", for: .normal)
        case .emergencyCall:
            self.returnButton.setTitle(text: textString[.emergencyCall], option: "", for: .normal)
        case .go:
            self.returnButton.setTitle(text: textString[.go], option: "", for: .normal)
        case .google:
            self.returnButton.setTitle(text: textString[.google], option: "", for: .normal)
        case .join:
            self.returnButton.setTitle(text: textString[.join], option: "", for: .normal)
        case .next:
            self.returnButton.setTitle(text: textString[.next], option: "", for: .normal)
        case .route:
            self.returnButton.setTitle(text: textString[.route], option: "", for: .normal)
        case .search:
            self.returnButton.setTitle(text: textString[.search], option: "", for: .normal)
        case .send:
            self.returnButton.setTitle(text: textString[.send], option: "", for: .normal)
        case .yahoo:
            self.returnButton.setTitle(text: textString[.yahoo], option: "", for: .normal)
        default :
            self.returnButton.setTitle(text: textString[.default], option: "", for: .normal)
        }
    }
    func createCharLineStackView(buttons:[KeyboardButton]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
    
//
//    func getButtonLineText(kind:TextString.ButtonKind) ->([String],[String]) {
//        let plainText = TextString.getLineText(buttonKind: kind)
//        var firstReturnText = [String]()
//        var secondReturnText = [String]()
//        let split = plainText.split(separator: " ")
//        if split.count == 2 {
//            let general = split[0].split(separator: ",")
//            let specialSimbols = split[1].split(separator: ",")
//            for text in general {
//                firstReturnText.append(String(text))
//            }
//            for text in specialSimbols {
//                secondReturnText.append(String(text))
//            }
//        } else if split.count == 1 {
//            let general = split[0].split(separator: ",")
//            for text in general {
//                firstReturnText.append(String(text))
//            }
//        }
//        return (firstReturnText,secondReturnText)
//    }
//
    func createCharacterButtons(kind:TextString.ButtonKind) -> [KeyboardButton] {
        var buttons = [KeyboardButton]()
        
        let lineText = TextString.getLineText(buttonKind: kind)
        if lineText.0.count > 3 {
            let genealText = lineText.0
            let specialText = lineText.1
            
            for i in 0 ..< genealText.count {
                let key = KeyboardButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                let optionText = specialText.count > i ? specialText[i] : ""
                key.setTitle(text: genealText[i], option: optionText, for: .normal)
                key.button.addTarget(self, action: #selector(touchUpChartacterKey(_:)), for: .touchUpInside)
                var tagValue = 0
                let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTouchCharacterKeyGesture(_:)))
                longGesture.minimumPressDuration = 0.3
                switch kind {
                case .en(.l1),.ko(.l1): tagValue += 100
                case .en(.l2),.ko(.l2): tagValue += 200
                case .en(.l3),.ko(.l3): tagValue += 300
                case .en(.number),.ko(.number): tagValue += 0
                }
                tagValue += i
                key.button.tag = tagValue
                key.button.addGestureRecognizer(longGesture)
                buttons.append(key)
            }
        }
        return buttons
    }
    /*
    func setColorScheme2() {
        let buttonTextColor = UIColor(named: "ButtonText")
        let buttonBackgroundColor = UIColor(named: "ButtonBackground")
        let buttonHighlightColor = UIColor(named: "ButtonHighlight")
        let backgroundColor = UIColor(named: "Background")
        DispatchQueue.main.async {
            let buttons:[[KeyboardButton]] = [self.charLine1Buttons,self.charLine2Buttons,self.charLine3Buttons,self.numberLineButtons]
            for keys in buttons{
                for key in keys {
                    key.setTitleColor(buttonTextColor, for: .normal)
                    key.button.tintColor = buttonTextColor
                    key.optionLabel.textColor = .darkGray
                }
            }
            let funcButtons:[KeyboardButton] = [self.nextKeyboardButton, self.deleteButton, self.shiftButton, self.spaceButton]
            for key in funcButtons {
                key.defaultBackgroundColor = buttonBackgroundColor!
                key.highlightBackgroundColor = buttonHighlightColor!
            }
            self.view.backgroundColor = backgroundColor
        }
    }*/
    /*
    func setColorScheme(_ colorScheme: ColorScheme) {
        let colorScheme = KeyboardColors(colorScheme: colorScheme)
        for button in charLine1Buttons {
            button.setTitleColor(colorScheme.buttonTextColor, for: .normal)
            button.button.tintColor = colorScheme.buttonTextColor
            button.optionLabel.textColor = colorScheme.optionTextColor
        }
        for button in charLine2Buttons {
            button.setTitleColor(colorScheme.buttonTextColor, for: .normal)
            button.button.tintColor = colorScheme.buttonTextColor
            button.optionLabel.textColor = colorScheme.optionTextColor
        }
        for button in charLine3Buttons {
            button.setTitleColor(colorScheme.buttonTextColor, for: .normal)
            button.button.tintColor = colorScheme.buttonTextColor
            button.optionLabel.textColor = colorScheme.optionTextColor
        }
        for button in numberLineButtons{
            button.setTitleColor(colorScheme.buttonTextColor, for: .normal)
            button.button.tintColor = colorScheme.buttonTextColor
            button.optionLabel.textColor = colorScheme.optionTextColor
        }
        
        self.nextKeyboardButton.defaultBackgroundColor = colorScheme.buttonBackgroundColor
        self.nextKeyboardButton.highlightBackgroundColor = colorScheme.buttonHighlightColor
        
        self.deleteButton.defaultBackgroundColor = colorScheme.buttonBackgroundColor
        self.deleteButton.highlightBackgroundColor = colorScheme.buttonHighlightColor
        
        self.shiftButton.defaultBackgroundColor = colorScheme.buttonBackgroundColor
        self.shiftButton.highlightBackgroundColor = colorScheme.buttonHighlightColor
        
        self.spaceButton.defaultBackgroundColor = colorScheme.buttonBackgroundColor
        self.spaceButton.highlightBackgroundColor = colorScheme.buttonHighlightColor
    }*/
    
    /// isPushedShift변수의 didSet 호출시 호출되는 함수
    func changedShiftValue(){
        if isPushedShift {
            switch self.language {
            case .ko:
                for key in self.charLine1Buttons {
                    let character = key.getTitle()
                    switch character {
                    case "ㅂ":
                        key.button.setTitle("ㅃ", for: .normal)
                    case "ㅈ":
                        key.button.setTitle("ㅉ", for: .normal)
                    case "ㄷ":
                        key.button.setTitle("ㄸ", for: .normal)
                    case "ㄱ":
                        key.button.setTitle("ㄲ", for: .normal)
                    case "ㅅ":
                        key.button.setTitle("ㅆ", for: .normal)
                    default: break
                    }
                }
            case .en:
                for buttons in [self.charLine1Buttons, self.charLine2Buttons, self.charLine3Buttons] {
                    for key in buttons! {
                        let character = key.getTitle()
                        let upper = character.uppercased()
                        key.button.setTitle(upper, for: .normal)
                    }
                }
            }
        } else {
            switch self.language {
            case .ko:
                for key in self.charLine1Buttons {
                    let character = key.getTitle()
                    switch character {
                    case "ㅃ":
                        key.button.setTitle("ㅂ", for: .normal)
                    case "ㅉ":
                        key.button.setTitle("ㅈ", for: .normal)
                    case "ㄸ":
                        key.button.setTitle("ㄷ", for: .normal)
                    case "ㄲ":
                        key.button.setTitle("ㄱ", for: .normal)
                    case "ㅆ":
                        key.button.setTitle("ㅅ", for: .normal)
                    default: break
                    }
                }
            case .en:
                for buttons in [self.charLine1Buttons, self.charLine2Buttons, self.charLine3Buttons] {
                    for key in buttons! {
                        let character = key.getTitle()
                        let lower = character.lowercased()
                        key.button.setTitle(lower, for:  .normal)
                    }
                }
            }
        }
    }
    
    @objc func touchUpChartacterKey(_ sender:DKey) {
        //insertCharacter
        if let character = sender.titleLabel?.text {
            UIDevice.current.playInputClick()
            self.textDocumentProxy.insertText(character)
        }
        if isPushedShift { isPushedShift = false }
    }
    
    @objc func touchUpSpaceKey() {
        self.textDocumentProxy.insertText(" ")
        UIDevice.current.playInputClick()
        if isPushedShift { isPushedShift = false }
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
        self.isPushedShift = !self.isPushedShift
    }
    
    @objc func deleteCharacterBeforeCursor() {
        self.textDocumentProxy.deleteBackward()
        UIDevice.current.playInputClick()
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
            
            self.textDocumentProxy.insertText(text)
            UIDevice.current.playInputClick()
        }
    }
}
