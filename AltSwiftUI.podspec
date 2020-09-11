Pod::Spec.new do |s|
  s.name         = "AltSwiftUI"
  s.version      = "1.0.0"
  s.ios.deployment_target = "11.0"
  s.summary      = "Open Source UI framework based on SwiftUI syntax and features, adding backwards compatibility."
  s.description  = <<-DESC
                  Open Source UI framework based on SwiftUI syntax and features, adding backwards compatibility.
                   DESC
  s.homepage     = "https://github.com/rakutentech/AltSwiftUI"
  s.license      = "MIT"
  s.author       = { "Kevin Wong" => "kevin.a.wong@rakuten.com" }
  s.source       = { :git => "https://github.com/rakutentech/AltSwiftUI.git", :tag => "#{s.version}" }
  s.source_files = ["AltSwiftUI/Source/*/*.swift", "AltSwiftUI/Source/*/*/*.swift"]
end
