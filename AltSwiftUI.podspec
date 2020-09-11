Pod::Spec.new do |s|
  s.name         = "AltSwiftUI"
  s.version      = "1.0.0"
  s.ios.deployment_target = "11.0"
  s.swift_version = "5.3"
  s.summary      = "Open Source UI framework based on SwiftUI syntax and features, adding backwards compatibility."
  s.description  = <<-DESC
                  Available from iOS 11 using Xcode 12. AltSwiftUI has some small differences to SwiftUI, where it 
                  handles certain features slightly differently and adds some missing features as well.
                   DESC
  s.homepage     = "https://github.com/rakutentech/AltSwiftUI"
  s.license      = "MIT"
  s.author       = { "Kevin Wong" => "kevin.a.wong@rakuten.com" }
  s.source       = { :git => "https://github.com/rakutentech/AltSwiftUI.git", :tag => "#{s.version}" }
  s.source_files = ["AltSwiftUI/Source/*/*.swift", "AltSwiftUI/Source/*/*/*.swift"]
end
