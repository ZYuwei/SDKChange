#! /bin/bash
. ~/WorkSpace/Test/ShellTest/shell/replace.sh
. ~/WorkSpace/Test/ShellTest/shell/package.sh

#文件配置
filepath="/Users/zy/WorkSpace/Test/ShellTest/CSPayNotificationSDK"
newFilePath="/Users/zy/WorkSpace/Test/ShellTest/package/TESTPayNotificationSDK"
oldPrefix="CS"
newPrefix="TEST"
echo "目标文件夹 ${filepath}"

function getdir(){
    echo $1
    for file in $1/*
    do
    if test -d $file ; then
        #文件夹递归
    	getdir $file
    elif test -f $file ; then
        #statements
        #替换文件名
        newfile="${newFilePath}${file##${filepath}}"
        newfile=${newfile//${oldPrefix}/${newPrefix}}
        echo "file" $file
        echo "newfile" $newfile
        #替换开始
        replace $file $newfile $oldPrefix $newPrefix
        #替换结束
    fi
    done
}

function main(){
    sdkName=${filepath##*/}
    changePath=${filepath}"/"${sdkName}
    getdir $changePath
}

main 


# replace_content "/Users/zy/WorkSpace/Test/ShellTest/CSPayNotificationSDK/Classes/Core/GMPayNotificationFailManager.h" "/Users/zy/WorkSpace/Test/ShellTest/NewCSPayNotificationSDK/Classes/Core/GMPayNotificationFailManager.h" "GM" "TEST"

