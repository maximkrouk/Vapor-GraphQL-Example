//
//  CastError.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//

struct CastError<T1, T2>: Error {
    let type1: T1.Type
    let type2: T2.Type
    let function: String
    let file: String
    let line: Int
    
    init(
        _ type1: T1.Type,
        to type2: T2.Type,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        self.type1 = type1
        self.type2 = type2
        self.function = function
        self.file = file
        self.line = line
    }
    
    var localizedDescription: String {
        "Could not cast \(type1) to \(type2)"
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
