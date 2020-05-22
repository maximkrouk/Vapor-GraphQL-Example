//
//  Mismatch.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//

import Foundation

struct PlainError: Error {
    let message: String
    let function: String
    let file: String
    let line: Int
    
    init(
        _ message: String,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        self.message = message
        self.function = function
        self.file = file
        self.line = line
    }
    
    var localizedDescription: String { message }
    
    var debugDescription: String {
        localizedDescription
            .appending("\n{")
            .appending("\n    function: \(function)")
            .appending("\n    file: \(file),")
            .appending("\n    line: \(line)")
            .appending("\n}")
    }
}
