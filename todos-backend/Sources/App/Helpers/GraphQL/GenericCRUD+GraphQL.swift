//import GraphQLKit
//
//extension GenericController: FieldKeyProvider where Model: FieldKeyProvider {
//    enum FieldKey: ModelFieldKeyProviding {
//        case field(Model.FieldKey)
//        
//        @available(*, deprecated, message: "Used for raw value initializer, but not recommended. Consider using other `.field()` or `.model` instead")
//        case raw(RawValue)
//        
//        static var model: Self { .raw(String(describing: Model.self)) }
//        
//        init?(rawValue: String) { self = .model }
//        
//        var rawValue: String {
//            switch self {
//            case let .field(value):
//                return value.rawValue
//            case let .raw(value):
//                return value
//            }
//        }
//    }
//}
