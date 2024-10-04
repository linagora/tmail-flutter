patrol build android && gcloud firebase test android run \
	--type instrumentation \
	--app build/app/outputs/apk/debug/app-debug.apk \
	--test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
	--device model="oriole",version="33",locale=en,orientation=portrait \
	--timeout 10m \
	--use-orchestrator \
	--environment-variables clearPackageData=true