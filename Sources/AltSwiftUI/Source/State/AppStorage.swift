//
//  AppStorage.swift
//  AltSwiftUI
//
//  Created by yang.q.wang on 2021/3/3.
//

import Foundation

enum AppStorageDefaultKey {
    static let defaultKey = "AltSwiftUI.AppStorage.DefaultKey"
    static let defautPrefixDomainKey = "AltSwiftUI.AppStorage"
}
enum AppStorageNotificationOrigins {
    static var origins:[NotificationOrigin] = []
}
class NotificationOrigin {
    let id: UUID
    let value: Any
    var Name:  NSNotification.Name {
        let name = "\(AppStorageDefaultKey.defautPrefixDomainKey).\(id)"
        return NSNotification.Name(name)
    }
    init(id: UUID, value: Any) {
        self.id = id
        self.value = value
    }
}

class AppStorageValueHolder<Value>{
    public var storage: UserDefaults = UserDefaults.standard
    public var key = AppStorageDefaultKey.defaultKey
    var getDataFromStorage:(()-> Value)
    var setDataInStorage:((_ value: Value) -> Void)
    var value: Value  {
        get {
            return self.getDataFromStorage()
        }
        set {
            self.setDataInStorage(newValue)
        }
    }
    init(value: Value, key: String, store: UserDefaults? = nil) where Value == Bool{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () ->Value in
            return tempStorage.bool(forKey: key)
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value, forKey: key)
        }
        self.value = value
    }
    init(key: String,store: UserDefaults? = nil) where Value == Bool?{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () ->Value in
            if tempStorage.value(forKey: key) != nil {
                return tempStorage.bool(forKey: key)
            }
            return nil
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value, forKey: key)
        }
    }
    init(value: Value, key: String,store: UserDefaults? = nil) where Value == Int{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () -> Value in
            return tempStorage.integer(forKey: key)
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value, forKey: key)
        }
        self.value = value
    }
    init(key: String, store: UserDefaults? = nil) where Value == Int?{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () -> Value in
            if tempStorage.value(forKey: key) != nil {
                return tempStorage.integer(forKey: key)
            }
            return nil
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value, forKey: key)
        }
    }
    init(value: Value, key: String,store: UserDefaults? = nil) where Value == Double{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () ->Value in
            return (tempStorage.double(forKey: key) )
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value, forKey: key)
        }
        self.value = value
    }
    init(key: String, store: UserDefaults? = nil) where Value == Double?{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () -> Value in
            if tempStorage.value(forKey: key) != nil {
                return tempStorage.double(forKey: key)
            }
            return nil
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value, forKey: key)
        }
    }
    init(value: Value, key: String,store: UserDefaults? = nil) where Value == String{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () -> Value in
            return tempStorage.string(forKey: key)!
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value, forKey: key)
        }
        self.value = value
    }
    init(key: String, store: UserDefaults? = nil) where Value == String?{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () -> Value in
            if tempStorage.value(forKey: key) != nil {
                return tempStorage.string(forKey: key)
            }
            return nil
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value, forKey: key)
        }
    }
    init(value: Value, key: String, store: UserDefaults? = nil) where Value == URL{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () ->Value in
            return tempStorage.url(forKey: key)!
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value, forKey: key)
        }
        self.value = value
    }
    init(key: String, store: UserDefaults? = nil) where Value == URL?{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () ->Value in
            if tempStorage.value(forKey: key) != nil {
                return tempStorage.url(forKey: key)
            }
            return nil
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value, forKey: key)
        }
    }
    init(value: Value, key: String, store: UserDefaults? = nil) where Value == Data{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () -> Value in
            return tempStorage.data(forKey: key)!
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value, forKey: key)
        }
        self.value = value
    }
    init(key: String, store: UserDefaults? = nil) where Value == Data?{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () -> Value in
            if tempStorage.value(forKey: key) != nil {
                return tempStorage.data(forKey: key)
            }
            return nil
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value, forKey: key)
        }
    }
    init(value: Value, key: String, store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == Int{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () -> Value in
            return Value(rawValue: (tempStorage.integer(forKey: key)))!
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value.rawValue, forKey: key)
        }
        self.value = value
    }
    init(value: Value, key: String, store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == String{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () -> Value in
            return Value(rawValue: (tempStorage.string(forKey: key)!))!
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value.rawValue, forKey: key)
        }
        self.value = value
    }
    
}
@propertyWrapper public struct AppStorage<Value> {
    var _wrappedValue: AppStorageValueHolder<Value>
    let id: UUID = UUID()
    private func generateNotificationName() -> String {
        return "\(AppStorageDefaultKey.defautPrefixDomainKey).\(id)"
    }
    
    public var wrappedValue: Value{
        get{
            let origins = AppStorageNotificationOrigins.origins.filter { (origin) -> Bool in
                if generateNotificationName() == origin.Name.rawValue {
                    return true
                }
                return false
            }
            if origins.isEmpty {
                let origin = NotificationOrigin(id: self.id, value: _wrappedValue)
                AppStorageNotificationOrigins.origins.append(origin)
                EnvironmentHolder.currentBodyViewBinderStack.last?.registerAppStorageNotification(origin: origin)
            }else{
                EnvironmentHolder.currentBodyViewBinderStack.last?.registerAppStorageNotification(origin: origins.first!)
            }
            return _wrappedValue.value
        }
        nonmutating set{
            _wrappedValue.value = newValue
            sendStateChangeNotification()
        }
    }
    public var projectedValue: Binding<Value> {
        Binding<Value>(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
    private func sendStateChangeNotification() {
        let userInfo = EnvironmentHolder.notificationUserInfo
        let _ = AppStorageNotificationOrigins.origins.map { origin in
            if generateNotificationName() == origin.Name.rawValue {
                NotificationCenter.default.post(name: origin.Name, object: origin, userInfo: userInfo)
            }
        }
    }
}

extension AppStorage{
    /// Creates a property that can read and write to a boolean user default.
    ///
    /// - Parameters:
    ///   - wrappedValue: The default value if a boolean value is not specified
    ///     for the given key.
    ///   - key: The key to read and write the value to in the user defaults
    ///     store.
    ///   - store: The user defaults store to read and write to. A value
    ///     of `nil` will use the user default store from the environment.
    public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Bool{
        
        self._wrappedValue = AppStorageValueHolder<Bool>(value: wrappedValue, key: key, store: store)
        
    }
    
    /// Creates a property that can read and write to an integer user default.
    ///
    /// - Parameters:
    ///   - wrappedValue: The default value if an integer value is not specified
    ///     for the given key.
    ///   - key: The key to read and write the value to in the user defaults
    ///     store.
    ///   - store: The user defaults store to read and write to. A value
    ///     of `nil` will use the user default store from the environment.
    public  init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Int{
        self._wrappedValue = AppStorageValueHolder<Int>(value: wrappedValue, key: key, store: store)
    }
    
    /// Creates a property that can read and write to a double user default.
    ///
    /// - Parameters:
    ///   - wrappedValue: The default value if a double value is not specified
    ///     for the given key.
    ///   - key: The key to read and write the value to in the user defaults
    ///     store.
    ///   - store: The user defaults store to read and write to. A value
    ///     of `nil` will use the user default store from the environment.
    public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Double{
        self._wrappedValue = AppStorageValueHolder<Double>(value: wrappedValue, key: key, store: store)
    }
    
    /// Creates a property that can read and write to a string user default.
    ///
    /// - Parameters:
    ///   - wrappedValue: The default value if a string value is not specified
    ///     for the given key.
    ///   - key: The key to read and write the value to in the user defaults
    ///     store.
    ///   - store: The user defaults store to read and write to. A value
    ///     of `nil` will use the user default store from the environment.
    public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == String{
        self._wrappedValue = AppStorageValueHolder<String>(value: wrappedValue, key: key, store: store)
    }
    
    /// Creates a property that can read and write to a url user default.
    ///
    /// - Parameters:
    ///   - wrappedValue: The default value if a url value is not specified for
    ///     the given key.
    ///   - key: The key to read and write the value to in the user defaults
    ///     store.
    ///   - store: The user defaults store to read and write to. A value
    ///     of `nil` will use the user default store from the environment.
    public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == URL{
        self._wrappedValue = AppStorageValueHolder<URL>(value: wrappedValue, key: key, store: store)
    }
    
    /// Creates a property that can read and write to a user default as data.
    ///
    /// Avoid storing large data blobs in user defaults, such as image data,
    /// as it can negatively affect performance of your app. On tvOS, a
    /// `NSUserDefaultsSizeLimitExceededNotification` notification is posted
    /// if the total user default size reaches 512kB.
    ///
    /// - Parameters:
    ///   - wrappedValue: The default value if a data value is not specified for
    ///    the given key.
    ///   - key: The key to read and write the value to in the user defaults
    ///     store.
    ///   - store: The user defaults store to read and write to. A value
    ///     of `nil` will use the user default store from the environment.
    public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Data{
        self._wrappedValue = AppStorageValueHolder<Data>(value: wrappedValue, key: key, store: store)
    }
    
    /// Creates a property that can read and write to an integer user default,
    /// transforming that to `RawRepresentable` data type.
    ///
    /// A common usage is with enumerations:
    ///
    ///    enum MyEnum: Int {
    ///        case a
    ///        case b
    ///        case c
    ///    }
    ///    struct MyView: View {
    ///        @AppStorage("MyEnumValue") private var value = MyEnum.a
    ///        var body: some View { ... }
    ///    }
    ///
    /// - Parameters:
    ///   - wrappedValue: The default value if an integer value
    ///     is not specified for the given key.
    ///   - key: The key to read and write the value to in the user defaults
    ///     store.
    ///   - store: The user defaults store to read and write to. A value
    ///     of `nil` will use the user default store from the environment.
    public init(wrappedValue: Value, _ key: String , store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == Int{
        self._wrappedValue = AppStorageValueHolder(value: wrappedValue, key: key, store: store)
    }
    /// Creates a property that can read and write to a string user default,
    /// transforming that to `RawRepresentable` data type.
    ///
    /// A common usage is with enumerations:
    ///
    ///    enum MyEnum: String {
    ///        case a
    ///        case b
    ///        case c
    ///    }
    ///    struct MyView: View {
    ///        @AppStorage("MyEnumValue") private var value = MyEnum.a
    ///        var body: some View { ... }
    ///    }
    ///
    /// - Parameters:
    ///   - wrappedValue: The default value if a string value
    ///     is not specified for the given key.
    ///   - key: The key to read and write the value to in the user defaults
    ///     store.
    ///   - store: The user defaults store to read and write to. A value
    ///     of `nil` will use the user default store from the environment.
    public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == String{
        self._wrappedValue = AppStorageValueHolder(value: wrappedValue, key: key, store: store)
    }
}

extension AppStorage where Value : ExpressibleByNilLiteral {
    
    /// Creates a property that can read and write an Optional boolean user
    /// default.
    ///
    /// Defaults to nil if there is no restored value.
    ///
    /// - Parameters:
    ///   - key: The key to read and write the value to in the user defaults
    ///     store.
    ///   - store: The user defaults store to read and write to. A value
    ///     of `nil` will use the user default store from the environment.
    public init(_ key: String, store: UserDefaults? = nil) where Value == Bool?{
        self._wrappedValue = AppStorageValueHolder<Bool?>(key: key, store: store)
    }
    /// Creates a property that can read and write an Optional integer user
    /// default.
    ///
    /// Defaults to nil if there is no restored value.
    ///
    /// - Parameters:
    ///   - key: The key to read and write the value to in the user defaults
    ///     store.
    ///   - store: The user defaults store to read and write to. A value
    ///     of `nil` will use the user default store from the environment.
    public init(_ key: String, store: UserDefaults? = nil) where Value == Int?{
        self._wrappedValue = AppStorageValueHolder<Int?>(key: key, store: store)
    }
    
    /// Creates a property that can read and write an Optional double user
    /// default.
    ///
    /// Defaults to nil if there is no restored value.
    ///
    /// - Parameters:
    ///   - key: The key to read and write the value to in the user defaults
    ///     store.
    ///   - store: The user defaults store to read and write to. A value
    ///     of `nil` will use the user default store from the environment.
    public init(_ key: String, store: UserDefaults? = nil) where Value == Double?{
        self._wrappedValue = AppStorageValueHolder<Double?>(key: key, store: store)
    }
    /// Creates a property that can read and write an Optional string user
    /// default.
    ///
    /// Defaults to nil if there is no restored value.
    ///
    /// - Parameters:
    ///   - key: The key to read and write the value to in the user defaults
    ///     store.
    ///   - store: The user defaults store to read and write to. A value
    ///     of `nil` will use the user default store from the environment.
    public init(_ key: String, store: UserDefaults? = nil) where Value == String?{
        self._wrappedValue = AppStorageValueHolder<String?>( key: key, store: store)
    }
    
    /// Creates a property that can read and write an Optional URL user
    /// default.
    ///
    /// Defaults to nil if there is no restored value.
    ///
    /// - Parameters:
    ///   - key: The key to read and write the value to in the user defaults
    ///     store.
    ///   - store: The user defaults store to read and write to. A value
    ///     of `nil` will use the user default store from the environment.
    public init(_ key: String, store: UserDefaults? = nil) where Value == URL?{
        self._wrappedValue = AppStorageValueHolder<URL?>(key: key, store: store)
    }
    
    /// Creates a property that can read and write an Optional data user
    /// default.
    ///
    /// Defaults to nil if there is no restored value.
    ///
    /// - Parameters:
    ///   - key: The key to read and write the value to in the user defaults
    ///     store.
    ///   - store: The user defaults store to read and write to. A value
    ///     of `nil` will use the user default store from the environment.
    public init(_ key: String, store: UserDefaults? = nil) where Value == Data?{
        self._wrappedValue = AppStorageValueHolder<Data?>(key: key, store: store)
    }
}
