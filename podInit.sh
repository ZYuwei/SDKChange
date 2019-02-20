#! /bin/bash

filepath="/Users/zy/WorkSpace/Test/ShellTest/CSPayNotificationSDK"


function initPod(){
	sdkPath=${1?}
	sdkName=${sdkPath##*/}
	prefixStr=${2?}
	rm -f $sdkPath
	mkdir -p $sdkPath
	cd $sdkPath
	pod lib create $sdkName

}

initPod "/Users/zy/WorkSpace/Test/ShellTest/package/TESTPayNotificationSDK" "TEST"