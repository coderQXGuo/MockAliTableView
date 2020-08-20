#
# Be sure to run `pod lib lint MockAliTableView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MockAliTableView'
  s.version          = '1.0.0'
  s.summary          = 'MockAliTableView'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
MockAliTableView: 只需用一个tableView仿支付宝财富页面的下拉效果
                       DESC

  s.homepage         = 'https://github.com/coderQXGuo/MockAliTableView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'coderQXGuo' => '915776696@qq.com' }
  s.source           = { :git => 'https://github.com/coderQXGuo/MockAliTableView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.3'

  s.source_files = 'MockAliTableView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MockAliTableView' => ['MockAliTableView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'MJRefresh'
  s.dependency 'Masonry'
end
