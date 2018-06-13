#
# Be sure to run `pod lib lint FC-HttpClient.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FC-HttpClient'
  s.version          = '0.3.0'
  s.summary          = 'A short description of FC-HttpClient.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/fangqk1991/iOS-HttpClient'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fangqk1991' => 'me@fangqk.com' }
  s.source           = { :git => 'https://github.com/fangqk1991/iOS-HttpClient.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'


  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|

    core.dependency 'AFNetworking', '~> 3.0'

    core.source_files = 'FC-HttpClient/Core/*.{h,m}'
    core.public_header_files = 'FC-HttpClient/Core/*.h'

  end

  s.subspec 'ProgressHUD' do |hud|

    hud.dependency 'FC-HttpClient/Core'
    hud.dependency 'MBProgressHUD', '~> 1.1.0'

    hud.source_files = 'FC-HttpClient/ProgressHUD/*.{h,m}'
    hud.public_header_files = 'FC-HttpClient/ProgressHUD/*.h'

  end

  s.subspec 'Upyun' do |upyun|

    upyun.dependency 'FC-HttpClient/Core'

    upyun.source_files = 'FC-HttpClient/Upyun/*.{h,m}'
    upyun.public_header_files = 'FC-HttpClient/Upyun/UpyunFile.h'

  end
  
  
  # s.resource_bundles = {
  #   'FC-HttpClient' => ['FC-HttpClient/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  
end
