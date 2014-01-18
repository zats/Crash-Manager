# Uncomment this line to define a global platform for your project
# platform :ios, "6.0"

target "Crashlytics" do
	pod 'MagicalRecord'
	pod 'AFNetworking'
	pod 'ReactiveCocoa'
	pod 'ProtobufObjC'
	pod 'GroundControl'
	pod 'SHUIKitBlocks'
	pod 'TTTLocalizedPluralString'
	pod 'GoogleAnalytics-iOS-SDK'

	inhibit_all_warnings!
end

target "CrashlyticsTests" do
end

post_install do | installer |
	require 'fileutils'
	FileUtils.cp_r('Pods/Pods-Crashlytics-acknowledgements.plist', 'Crashlytics/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end