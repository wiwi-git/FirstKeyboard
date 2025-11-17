//
//  exHangul.swift
//  FirstKeyboardProject
//
//  Created by 위대연 on 11/13/25.
//  Copyright © 2025 위대연. All rights reserved.
//

extension HangulAutomata {
    func getInpCharArr() -> Array<String> {
        return inpStack.map { stack in
            stack.charCode
        }
    }
    
    func clearStack() {
//        self.buffer.removeAll()
        self.buffer = []
        self.inpStack = []
        /*
        var buffer: [String] = []
        
        var inpStack: [InpStack] = []
        
        var currentHangulState: HangulStatus?
        
        private var chKind = HangulCHKind.vowel
        
        private var charCode: String = ""
        private var oldKey: UInt32 = 0
        private var oldChKind: HangulCHKind?
        private var keyCode: UInt32 = 0
         */
        self.currentHangulState = nil
        
        print("stack.... \(self.buffer) \(self.inpStack)")
    }
    
}
