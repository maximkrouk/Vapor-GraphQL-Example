//
//  UnwrappingError.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//

import Foundation

struct UnwrappingError<T>: Error {
    let type: T.Type
    let function: String
    let file: String
    let line: Int
    
    init(
        _ type: T.Type,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        self.type = type
        self.function = function
        self.file = file
        self.line = line
    }
    
    var localizedDescription: String {
        "Could not unwrap value of type \(type)."
    }
    
    var debugDescription: String {
        localizedDescription
            .appending("\n{")
            .appending("\n    function: \(function)")
            .appending("\n    file: \(file),")
            .appending("\n    line: \(line)")
            .appending("\n}")
    }
}
