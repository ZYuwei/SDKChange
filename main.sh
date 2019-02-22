#! /bin/bash
. ./replace.sh
. ./rubbishCode.sh

#文件配置
filepath="/Users/zy/WorkSpace/Test/ShellTest/Co_pay_PayNotificationSDK"
newFilePath="/Users/zy/WorkSpace/Test/ShellTest/package/TESTPayNotificationSDK"
gitPath="/Users/zy/WorkSpace/Test/ShellTest/framework"
oldPrefix="Co_pay_"
newPrefix="TEST"

sdkName=${filepath##*/}
echo "目标文件夹 ${filepath}"

function getdir(){
    echo "检索文件夹" ${1?}
    for file in $1/*
    do
    if test -d $file ; then
        #文件夹递归
        lasePath=${file##*/}
        if [[ $lasePath == "Pods" || $lasePath == "Example" || $lasePath == "_Pods.xcodeproj" ]]; then
            echo "忽略 路径" $lasePath
        else
            getdir $file
        fi
    elif test -f $file ; then
        #替换文件名
        newfile="${newFilePath}${file##${filepath}}"
        newfile=${newfile//${oldPrefix}/${newPrefix}}
        #替换开始
        replace $file $newfile $oldPrefix $newPrefix $sdkName
        #替换结束
        #增加垃圾代码
        rubbishCode $newfile 
    fi
    done
}



function main(){
    rm -rf $newFilePath
    echo "删除 路径下文件" $newFilePath
    changePath=${filepath}
    getdir $changePath
    # 后续步骤暂时关闭
    # 创建git
    # cd $newFilePath
    # git init && git add . && git commit -m "build" 
    # podspec=${sdkName/$oldPrefix/$newPrefix}
    # pod package ${podspec}.podspec —force --spec-sources='https://github.com/CocoaPods/Specs.git,http://gerrit.3g.net.cn/gomo_ios_specs' --no-mangle --gomoad --exclude-deps
    # versionStr=`sed -n "/s.version *=/p" ${podspec}.podspec`
    # versionStr=`echo $versionStr | tr -cd "[0-9.]"`
    # versionStr=${versionStr:1}
    # frameworkPath="${newFilePath}/${podspec}-${versionStr}"
    # echo $frameworkPath 
    # #清空仓库
    # for file in ${gitPath}/*
    # do
    #     if [[ $file =~ "${podspec}" ]];then
    #         rm -rf $file
    #         echo "删除" $podspec"/"$file
    #     fi
    # done
    # # 拷贝到git 仓库
    # cp -r ${frameworkPath}/ios/ ${gitPath}/
    # cd ${gitPath} && git pull origin && git add . && git commit -m $versionStr && git push origin
}
main 
