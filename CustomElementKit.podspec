Pod::Spec.new do |s|
    s.name         = "CustomElementKit"
    s.version      = "1.1.99"
    s.summary      = "SwiftUI Custom Elements"
    s.description  = <<-DESC
    FAT Theme Maker SwiftUI Custom Elements
    DESC
    s.homepage     = "https://google.com"
    s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }
    s.author             = { "FAT LLC" => "contact@fatapp.io" }
    s.source             = { :git => 'https://gitlab.com/fat-llc/CustomElementKit.git', :tag => "#{s.version}" }
    s.swift_version      = "5.3"
    s.source_files = 'Sources/CustomElementKit/**/*'
    s.ios.deployment_target  = '13.0'
end







