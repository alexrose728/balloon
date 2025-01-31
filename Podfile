# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'balloonarch' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for balloonarch
	pod 'Firebase/Auth'
	pod 'Firebase/Firestore'
	pod 'Firebase/Storage'
	pod 'SDWebImageSwiftUI' # For image loading
  pod 'FirebaseFirestoreSwift'
  pod 'Firebase/Storage'
  pod 'FirebaseAnalytics'
  pod 'Charts'
#  pod 'PhotoKit' # For SwiftUI image picker


  target 'balloonarchTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'balloonarchUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
  end
end
