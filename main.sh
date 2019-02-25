#! /bin/bash
. ./replace.sh
. ./rubbishCode.sh
. ./readConfig.sh

#文件配置
in_file_base_path="/Users/zy/WorkSpace/Test/ShellTest/Source"
sdk_file_base_path="/Users/zy/WorkSpace/Test/ShellTest/sdk"
out_file_base_path="/Users/zy/WorkSpace/Test/ShellTest/package"

echo "目标文件夹 ${source_path}"

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
        newfile="${out_file_path}${file##${source_path}}"
        newfile=${newfile//${old_prefix}/${new_prefix}}
        echo file: $file
        echo newfile: $newfile
        echo old_prefix: $old_prefix
        echo new_prefix: $new_prefix
        echo old_name: $old_name
        #替换开始
        replace $file $newfile $old_prefix $new_prefix $old_name
        #替换结束
        #增加垃圾代码
        rubbishCode $newfile 
    fi
    done
}

function main(){
    mkdir -p $in_file_base_path
    mkdir -p $sdk_file_base_path

    readConfig '/Users/zy/WorkSpace/Test/ShellTest/config/Co_pay_PayNotificationSDK.config'

    oldPrefix=$old_prefix
    #源代码git文件名
    in_path_name=${in_git_path##*/}
    in_path_name=${in_path_name%.*}
    #源代码路径
    source_path="${in_file_base_path}/${in_path_name}"
    if test -d $source_path ; then
        cd $source_path
        git pull
    else
        cd ${in_file_base_path}
        git clone $in_git_path
    fi

    # 输出git文件名 
    out_path_name=${out_git_path##*/}
    out_path_name=${out_path_name%.*}
    #framework git仓库路径
    sdk_path="${sdk_file_base_path}/${out_path_name}"
    if test -d $sdk_path ; then
        cd $sdk_path
        git pull
    else
        cd ${sdk_file_base_path}
        git clone $out_git_path
    fi

    #source_path 源代码本地git路径 #sdk_path 输出sdk指定git路径 #old_prefix 旧前缀  #new_prefix_arr 新前缀数组
    for prefix in ${new_prefix_arr[*]}; do
        new_prefix=$prefix
        new_name=${old_name/${old_prefix}/${new_prefix}}
        out_file_path=${out_file_base_path}/${new_name}
        rm -rf $out_file_path
        echo "删除 路径下文件" $out_file_path
        getdir $source_path
        
        # 创建git
        cd $out_file_path
        git init && git add . && git commit -m "build" 
        podspec=${old_name/$old_prefix/$new_prefix}
        pod package ${podspec}.podspec —force --spec-sources='https://github.com/CocoaPods/Specs.git,http://gerrit.3g.net.cn/gomo_ios_specs' --no-mangle --gomoad --exclude-deps
        versionStr=`sed -n "/s.version *=/p" ${podspec}.podspec`
        versionStr=`echo $versionStr | tr -cd "[0-9.]"`
        versionStr=${versionStr:1}
        frameworkPath="${out_file_path}/${podspec}-${versionStr}"
        echo $frameworkPath 
        # #清空仓库

        for file in ${sdk_path}/*
        do
            if [[ $file =~ "${podspec}" ]];then
                rm -rf $file
                echo "删除" $podspec"/"$file
            fi
        done
    done
    # 拷贝到git 仓库
    cp -r ${frameworkPath}/ios/ ${sdk_path}/
    cd ${sdk_path} && git pull origin && git add . && git commit -m $versionStr && git tag ${versionStr} && git push origin --tags
}

main 
