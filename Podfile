platform :ios, '14.0'

target 'AWS Exams Prep Pro' do
  use_frameworks!
  
  # Pods for AWS Exams Prep Pro
  pod 'Google-Mobile-Ads-SDK'
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
        config.build_settings['ENABLE_BITCODE'] = 'NO'
        
        # Ensure minimum deployment target for all pods
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      end
    end
  end
end 