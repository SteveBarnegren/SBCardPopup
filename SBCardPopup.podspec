Pod::Spec.new do |s|
  s.name             = 'SBCardPopup'
  s.version          = '0.2.1'
  s.summary          = 'Show a view in a card popup UI'

  s.description      = <<-DESC
TODO: Show a UIViewController of UIView in a card popup UI. SBCardPopup handles the animations and dismiss gestures for you.
                       DESC

  s.homepage         = 'https://github.com/SteveBarnegren/SBCardPopup'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Steve Barnegren' => 'steve.barnegren@gmail.com' }
  s.source           = { :git => 'https://github.com/SteveBarnegren/SBCardPopup.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/stevebarnegren'

  s.ios.deployment_target = '9.0'

  s.source_files = 'SBCardPopup/SBCardPopup/**/*.swift'
  s.frameworks = 'UIKit'
end
