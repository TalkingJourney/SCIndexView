#
#  Be sure to run `pod spec lint SCIndexView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

    s.name          = "SCIndexView"
    s.summary       = "SCIndexView provide a index view."
    s.description   = "SCIndexView provide a index view like Wechat. It is very easy."
    s.license       = { :type => 'MIT', :file => 'LICENSE' }
    s.homepage      = "https://github.com/TalkingJourney/SCIndexView"
    s.author        = { "TalkingJourney" => "https://github.com/TalkingJourney" }
    s.platform      = :ios, "7.0"
    s.requires_arc  = true
    s.version       = "2.2.4"
    s.source        = { :git => "https://github.com/TalkingJourney/SCIndexView.git", :tag => s.version }
    s.source_files  = "SCIndexView/**/*.{h,m}"
    s.public_header_files   = "SCIndexView/**/*.h"

end
