//
//  Optional+Extension.swift
//  App
//
//  Created by Maxim Krouk on 5/14/20.
//

extension Optional {
    var isNil: Bool {
        switch self {
        case .none: return true
        case .some: return false
        }
    }
    
    func or(_ defaultValue: @autoclosure () -> Wrapped) -> Wrapped {
        self ?? defaultValue()
    }
    
    func unwrap() -> Result<Wrapped, Error> {
        switch self {
        case .some(let value):
            return .success(value)
        case .none:
            return .failure(UnwrappingError(Wrapped.self))
        }
    }
    
    static func update(_ value: inout Wrapped, using optional: Self) {
        if let unwrapped = optional { value = unwrapped }
    }
}

extension Optional where Wrapped: StringProtocol {
    func or(_ defaultValue: @autoclosure () -> Wrapped = "") -> Wrapped {
        self ?? defaultValue()
    }
}
