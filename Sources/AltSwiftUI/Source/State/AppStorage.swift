//
//  AppStorage.swift
//  AltSwiftUI
//
//  Created by yang.q.wang on 2021/3/3.
//

import Foundation

enum AppStorageDefaultKey {
    static let defaultKey = "AltSwiftUI.AppStorageDefaultKey.Key"
}
class AppStorageValueHolder<Value>{
    public var storage: UserDefaults = UserDefaults.standard
    public var key = AppStorageDefaultKey.defaultKey
    var getDataFromStorage:(()->Value)
    var setDataInStorage:((_ value:Value)->Void)
    var value: Value  {
        get {
            return self.getDataFromStorage()
        }
        set {
            self.setDataInStorage(newValue)
        }
    }
    init(value: Value , key:String,store: UserDefaults? = nil) where Value == Bool{
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
        guard  let _ = self.storage.value(forKey: key) else  {
            self.value = value
            return
        }
    }
    init(key:String,store: UserDefaults? = nil) where Value == Bool?{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () ->Value in
            if let _ = tempStorage.value(forKey: key){
                return tempStorage.bool(forKey: key)
            }else{
                return Optional<Bool>.none
            }
        }
        self.setDataInStorage = { (value) in
            if value == Optional<Bool>.none {
                return
            }
            tempStorage.set(value, forKey: key)
        }
    }
    init(value: Value , key:String,store: UserDefaults? = nil) where Value == Int{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () ->Value in
            return (tempStorage.integer(forKey: key) )
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value, forKey: key)
        }
        guard  let _ = self.storage.value(forKey: key) else  {
            self.value = value
            return
        }
    }
    init(key:String,store: UserDefaults? = nil) where Value == Int?{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () ->Value in
            if let _ = tempStorage.value(forKey: key){
                return tempStorage.integer(forKey: key)
            }else{
                return Optional<Int>.none
            }
        }
        self.setDataInStorage = { (value) in
            if value == Optional<Int>.none {
                return
            }
            tempStorage.set(value, forKey: key)
        }
    }
    init(value: Value , key:String,store: UserDefaults? = nil) where Value == Double{
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
        guard  let _ = self.storage.value(forKey: key) else  {
            self.value = value
            return
        }
    }
    init(key:String,store: UserDefaults? = nil) where Value == Double?{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () ->Value in
            if let _ = tempStorage.value(forKey: key){
                return tempStorage.double(forKey: key)
            }else{
                return Optional<Double>.none
            }
        }
        self.setDataInStorage = { (value) in
            if value == Optional<Double>.none {
                return
            }
            tempStorage.set(value, forKey: key)
        }
    }
    init(value: Value , key:String,store: UserDefaults? = nil) where Value == String{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () ->Value in
            return (tempStorage.string(forKey: key)!)
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value, forKey: key)
        }
        guard  let _ = self.storage.value(forKey: key) else  {
            self.value = value
            return
        }
    }
    init(key:String,store: UserDefaults? = nil) where Value == String?{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () ->Value in
            if let _ = tempStorage.value(forKey: key){
                return tempStorage.string(forKey: key)
            }else{
                return Optional<String>.none
            }
        }
        self.setDataInStorage = { (value) in
            if value == Optional<String>.none {
                return
            }
            tempStorage.set(value, forKey: key)
        }
    }
    init(value: Value , key:String,store: UserDefaults? = nil) where Value == URL{
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
        guard  let _ = self.storage.value(forKey: key) else  {
            self.value = value
            return
        }
    }
    init(key:String,store: UserDefaults? = nil) where Value == URL?{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () ->Value in
            if let _ = tempStorage.value(forKey: key){
                return tempStorage.url(forKey: key)
            }else{
                return Optional<URL>.none
            }
        }
        self.setDataInStorage = { (value) in
            if value == Optional<URL>.none {
                return
            }
            tempStorage.set(value, forKey: key)
        }
    }
    init(value: Value , key:String,store: UserDefaults? = nil) where Value == Data{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () ->Value in
            return tempStorage.data(forKey: key)!
        }
        self.setDataInStorage = { (value) in
            tempStorage.set(value, forKey: key)
        }
        guard  let _ = self.storage.value(forKey: key) else  {
            self.value = value
            return
        }
    }
    init(key:String,store: UserDefaults? = nil) where Value == Data?{
        self.key = key
        if let _store = store {
            self.storage = _store
        }
        let tempStorage = self.storage
        self.getDataFromStorage = { () ->Value in
            if let _ = tempStorage.value(forKey: key){
                return tempStorage.data(forKey: key)
            }else{
                return Optional<Data>.none
            }
        }
        self.setDataInStorage = { (value) in
            if value == Optional<Data>.none {
                return
            }
            tempStorage.set(value, forKey: key)
        }
    }
    init(value: Value , key:String ,store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == Int{
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
        guard  let _ = self.storage.value(forKey: key) else  {
            self.value = value
            return
        }
    }
    init(value: Value , key:String ,store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == String{
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
        guard  let _ = self.storage.value(forKey: key) else  {
            self.value = value
            return
        }
    }
    
}
@propertyWrapper public struct AppStorage<Value> : DynamicProperty {
    func update(context: Context) {
        _wrappedValue.value = _wrappedValue.value
    }
    var _wrappedValue: AppStorageValueHolder<Value>
     public var wrappedValue: Value{
        get{
            EnvironmentHolder.currentBodyViewBinderStack.last?.registerStateNotification(origin: _wrappedValue)
            return _wrappedValue.value
        }
        nonmutating set{
            _wrappedValue.value = newValue
            if EnvironmentHolder.notifyStateChanges {
                sendStateChangeNotification()
            }
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
        NotificationCenter.default.post(name: ViewBinder.StateNotification.name, object: _wrappedValue, userInfo: userInfo)
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
    public  init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Bool{
        
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
    public  init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Double{
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
    public  init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == String{
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
    public  init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == URL{
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
    public  init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Data{
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
