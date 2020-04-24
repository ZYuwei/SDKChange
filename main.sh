#! /bin/bash
basepath=$(cd `dirname $0`; pwd)
. ${basepath}/replace.sh
. ${basepath}/rubbishCode.sh
. ${basepath}/readConfig.sh

# search_type: 1framework 2demo
function getdir(){
    echo "检索文件夹" ${1?}
    search_type=${2?}
    for file in $1/*
    do
    if test -d $file ; then
        #文件夹递归
        lasePath=${file##*/}

        case ${search_type} in
            '1')
                if [[ $lasePath == "Pods" || $lasePath == "Example" || $lasePath == "_Pods.xcodeproj" ]]; then
                    echo "忽略 路径" $lasePath
                else
                    getdir ${file} ${search_type}
                fi        
            ;;
            '2')
                if [[ $lasePath == "Pods" || $lasePath == "_Pods.xcodeproj" ]]; then
                    echo "忽略 路径" $lasePath
                else
                    # demo文件夹特殊处理
                    if [[ $lasePath == "Example" ]]; then
                        getdirForDemo ${file}
                    else
                        getdir ${file} ${search_type}
                    fi
                fi        
            ;;
        esac

    elif test -f $file ; then
        #替换文件名
        newfile="${out_file_path}${file##${source_path}}"
        newfile=${newfile//${old_prefix}/${new_prefix}}
        #替换开始
        replace $file $newfile $old_prefix $old_name $new_prefix
        #替换结束
        rubbishCode $newfile
    fi
    done
}

function getdirForDemo(){
    echo "检索文件夹" ${1?}
    noprefix_name=${old_name//${old_prefix}/}
    ignore_workspace="${noprefix_name}.xcworkspace"
    for file in $1/*
    do
        if test -d $file ; then
            #文件夹递归
            lasePath=${file##*/}
            if [[ $lasePath == "Pods" || $lasePath =~ $ignore_workspace ]]; then
                echo "忽略 路径" $lasePath
            else
                # demo文件夹特殊处理
                getdirForDemo ${file}
            fi  

        elif test -f $file ; then
            #替换文件名
            newfile="${out_file_path}${file##${source_path}}"
            # newfile=${newfile//${old_prefix}/${new_prefix}}
            #替换开始
            replace $file $newfile $old_prefix $old_name $new_prefix
            #替换结束
        fi
    done
}

function package_sdk(){
        # 创建git
        cd $out_file_path
        git init && git add . && git commit -m "build" 
        podspec=${old_name//$old_prefix/$new_prefix}
        echo old_name ${old_name}
        echo podspec ${podspec}
        # admob源需要通过--gomoad 用于防止打包
        if [[ $old_name == 'Co_ad_CSAdmobAdLoad' ]]; then
                echo 广告sdk打包
                pod package ${podspec}.podspec —force --spec-sources='https://github.com/CocoaPods/Specs.git,http://gerrit.3g.net.cn/gomo_ios_specs,https://gitlab.com/gomo_sdk/sdk_insulate_spec.git' --no-mangle  --exclude-deps --gomoad
            else
                pod package ${podspec}.podspec —force --spec-sources='https://github.com/CocoaPods/Specs.git,http://gerrit.3g.net.cn/gomo_ios_specs,https://gitlab.com/gomo_sdk/sdk_insulate_spec.git' --no-mangle  --exclude-deps #--gomoad
        fi

        
        if [ $? -ne 0 ]; then
            echo -e "\033[31m error: pod package failed \033[0m"
            kill $$
        fi

        local_spec_name=${podspec}.podspec
        # 进入framework
        versionStr=`sed -n "/s.version *=/p" $local_spec_name`
        versionStr=`echo $versionStr | tr -cd "[0-9.]"`
        versionStr=${versionStr:1}
        frameworkPath="${out_file_path}/${podspec}-${versionStr}"
        echo frameworkPath $frameworkPath

        #删除end所在行
        sed -i '' "/^end$/d" ${frameworkPath}/${local_spec_name}

        # 更新打包后spec文件
        dependencyStr=`sed -n "/s.dependency.*/p" $local_spec_name`
        # 将bundles写入spec
        resourceBundlesStr=`cat $local_spec_name|sed '/ *#/d'|awk '{{printf"%s",$0}}'|grep '.resource_bundles*'`
        if [ -n "$resourceBundlesStr" ]; then 
            echo "resourceBundlesStr is not empty"
            resourceBundlesStr=`echo ${resourceBundlesStr#*.resource_bundles *\'}`
            resourceBundlesStr=`echo ${resourceBundlesStr%%\'*}`
            echo "  s.resources = 'ios/${resourceBundlesStr}.bundle' " >> ${frameworkPath}/${local_spec_name}
            echo resourceBundlesStr is $resourceBundlesStr
        fi

        echo "$dependencyStr" >> ${frameworkPath}/${local_spec_name}
        echo 'end' >> ${frameworkPath}/${local_spec_name}

        #清空仓库
        mkdir -p ${sdk_path}/${old_name}/${versionStr}
        for file in ${sdk_path}/${versionStr}/*
        do
            if [[ $file =~ "${podspec}" ]];then
                rm -rf $file
                echo "删除历史文件" $podspec $file
            fi
        done
       
        cd ${frameworkPath}
        # 如果有资源文件则对资源进行移动
        if [ -n "$resourceBundlesStr" ]; then 
            mv ios/${podspec}.framework/Resources/${resourceBundlesStr}.bundle ./ios
            rm -rf ios/${podspec}.framework/Resources
        fi
         # 压缩sdk
        zip -r ${frameworkPath}/${podspec}.zip ./ios
        if [ $? -ne 0 ]; then
            echo -e "\033[31m error: zip ${frameworkPath}/ios failed \033[0m"
            kill $$
        fi
        #删除压缩包中多余文件
        zip -d ${podspec}.zip ios/${podspec}.framework/Versions/\*
        # 拷贝到git 仓库
        cp -r ${frameworkPath}/${podspec}.zip ${sdk_path}/${old_name}/${versionStr}/
        if [ $? -ne 0 ]; then
            echo -e "\033[31m error: copy to ${sdk_path}/${old_name}/${versionStr}/ failed \033[0m"
            kill $$
        fi

        #修改spec
        sdk_spec_file=${frameworkPath}/${podspec}.podspec
        framework_download_path=${out_git_path%.*}
        # github源对下载路径进行拼接
        framework_download_path=${framework_download_path}/blob/master/${old_name}/${versionStr}/${podspec}.zip
        # gilab源，目前不可用
        # framework_download_path=${framework_download_path}/raw/master/${old_name}/${versionStr}/${podspec}.zip?inline=false
        framework_download_path=${framework_download_path//\//\\\/}
        sed -i '' "s/s.source = —force/s.source ={ :http => '${framework_download_path}'}/g" $sdk_spec_file
        if [ $? -ne 0 ]; then
            echo -e "\033[31m error: change $sdk_spec_file failed \033[0m"
            kill $$
        fi
        pod_spec_path="${pod_spec_base_path}/${podspec}/${versionStr}"

        if test -d ${pod_spec_base_path} ; then
            # 更新pod仓库
            cd ${pod_spec_base_path} && git pull
        else
            # 安装pod 仓库
            spec_clone_path=${pod_spec_base_path%/*}
            echo -e "\033[33m install podSpec directory on ${pod_spec_base_path} \033[0m"
            cd ${spec_clone_path} && git clone ${pod_git_path}
        fi
        
        # 确保目录存在
        mkdir -p ${pod_spec_path}
        # 移除历史文件
        for file in ${pod_spec_path}/*
        do
            if [[ $file =~ "${podspec}.spec" ]];then
                rm -rf $file
                echo "删除历史文件" $podspec $file
            fi
        done

        # 拷贝
        cp -r ${sdk_spec_file} ${pod_spec_path}/
        if [ $? -ne 0 ]; then
            echo -e "\033[31m error: copy to ${pod_spec_path}/ failed \033[0m"
            kill $$
        fi
        # 上传git
        cd ${pod_spec_base_path} && git add . && git commit -m "update ${podspec} for ${versionStr}"
        git push origin
        
}


function setupGit(){

    mkdir -p $in_file_base_path
    mkdir -p $sdk_file_base_path

    #源代码git文件名
    in_path_name=${in_git_path##*/}
    in_path_name=${in_path_name%.*}
    #源代码路径
    source_path="${in_file_base_path}/${in_path_name}"
    if test -d $source_path ; then
    	cd ${source_path}
    	echo "reset git 仓库"
		git reset --hard HEAD && git checkout master && git pull

	    if [[ ${#code_branch} > 1 ]]; then
	        echo "checkout from branch :${code_branch}"
	        git checkout ${code_branch} 
	    else
	        echo "checkout from master branch"
	        git checkout master 
	    fi

        if [ $? -ne 0 ]; then
            echo -e "\033[31m error: git checkout failed ${in_git_path} \033[0m"
            kill $$
        fi

        git pull
        
	else
		cd ${in_file_base_path}

	    if [[ ${#code_branch} > 1 ]]; then
	        echo "clone from branch :${code_branch}"
	        git clone -b ${code_branch} $in_git_path
	    else
	        echo "clone from master branch"
	        git clone -b master $in_git_path 
	    fi
	        
	    
	    if [ $? -ne 0 ]; then
	        echo -e "\033[31m error: git setup failed ${in_git_path} \033[0m"
	        kill $$
	    fi

    fi

    #移除gemfile.lock文件防止插件版本限制
    examplePath="${source_path}/Example"
    if test -d $examplePath ; then
        gemfileLockPath="${examplePath}/Gemfile.lock"
        echo 移除  $gemfileLockPath
        rm $gemfileLockPath
    fi


    # 输出git文件名 
    out_path_name=${out_git_path##*/}
    out_path_name=${out_path_name%.*}

    #framework git仓库路径,更新拉取内容
    sdk_path="${sdk_file_base_path}/${out_path_name}"
    if test -d $sdk_path ; then
        cd $sdk_path
        git pull
    else
        cd ${sdk_file_base_path}
        git clone $out_git_path
    fi

    if [ $? -ne 0 ]; then
        echo -e "\033[31m error: git setup failed ${out_git_path} \033[0m"
        kill $$
    fi
}

# 参数为new_prefix数组
function startToFramework(){
    new_prefix_arr=${*}
    # 更新pod仓库
    repoName=`grep -h 's.repoName.*' ${basepath}/shell.config`
    repoName=`changeConfig $repoName`
    pod repo update $repoName
    #source_path 源代码本地git路径 #sdk_path 输出sdk指定git路径 #old_prefix 旧前缀  #new_prefix_arr 新前缀数组
    #遍历所有新前缀
    if [[ ${#new_prefix_arr[0]} > 0 ]]; then
        for prefix in ${new_prefix_arr[*]}; do
            new_prefix=$prefix
            new_name=${old_name/${old_prefix}/${new_prefix}}
            out_file_path=${out_file_base_path}/${new_name}
            rm -rf $out_file_path
            echo "删除 路径下文件" $out_file_path
            getdir ${source_path} 1
            
            # 打包SDK并复制到sdk文件夹
            package_sdk
        done
    else
        new_prefix=""
        new_name=${old_name/${old_prefix}/${new_prefix}}
        out_file_path=${out_file_base_path}/${new_name}
        rm -rf $out_file_path
        echo "删除 路径下文件" $out_file_path
        getdir ${source_path} 1
        # 打包SDK并复制到sdk文件夹
        package_sdk
    fi

}

function startToDemo(){
    new_prefix_arr=${*}
    #source_path 源代码本地git路径 #sdk_path 输出sdk指定git路径 #old_prefix 旧前缀  #new_prefix_arr 新前缀数组
    #遍历所有新前缀
    if [[ ${#new_prefix_arr[0]} > 0 ]]; then
        for prefix in ${new_prefix_arr[*]}; do
            new_prefix=$prefix
            new_name=${old_name/${old_prefix}/${new_prefix}}
            out_file_path=${out_file_base_path}/${new_name}
            rm -rf $out_file_path
            echo "删除 路径下文件" $out_file_path
            getdir ${source_path} 2
            # 更新cocoapods仓库
            repoName=`grep -h 's.repoName.*' ${basepath}/shell.config`
            repoName=`changeConfig $repoName`
            pod repo update $repoName
            cd ${out_file_path}/Example && pod install
            # 打包SDK并复制到sdk文件夹
            package_sdk
        done
    else
        new_prefix=""
        new_name=${old_name/${old_prefix}/${new_prefix}}
        out_file_path=${out_file_base_path}/${new_name}
        rm -rf $out_file_path
        echo "删除 路径下文件" $out_file_path
        getdir ${source_path} 2
        # 更新cocoapods仓库
        repoName=`grep -h 's.repoName.*' ${basepath}/shell.config`
        repoName=`changeConfig $repoName`
        pod repo update $repoName
        cd ${out_file_path}/Example && pod install
        # 打包SDK并复制到sdk文件夹
        package_sdk
    fi

}

# 参数1类型：1-通过config下所有前缀进行打包framework; 2-通过config以及在参数3输入的前缀进行打包framework; 3-通过config以及在参数3输入的前缀进行打包Demo
# 参数2配置文件的地址
# 参数3版本号或者分支
# 参数4单独设置前缀或打Demo时使用新前缀
# 如:workStart '3' '/Users/zy/WorkSpace/Test/ShellTest/shell/config/Co_pay_PayNotificationSDK.config' 'new_pay_master' 'New_Test_' 
function workStart(){

    work_type=${1?}
    config_file=${2?}
    code_branch=${3}
    input_prefix=${4}
    readConfig ${config_file}
    
    if [[ work_type > 1 ]]; then
        unset new_prefix_arr
        new_prefix_arr[0]=${input_prefix}
    fi

    # 设置git仓库
    setupGit

    # 开始
    # 1打包config下所有config
    # 2打包config下某一个config
    # 3使用config下某一个config打包Demo
    case ${work_type} in
        '1')
            echo -e "\033[33m start package all framework \033[0m"
            startToFramework ${new_prefix_arr[*]}
            ;;
        '2')
            echo -e "\033[33m start package ${new_prefix_arr[0]} prefix framework \033[0m"
            startToFramework ${new_prefix_arr[*]}
            ;;
        '3')
            echo -e "\033[33m start package ${new_prefix_arr[0]} prefix demo \033[0m"
            startToDemo ${new_prefix_arr[*]}
            ;;
        '*')
            echo -e "\033[31m error: work type is wrong \033[0m"
            kill $$
            ;;
    esac


    # 上传
    cd ${sdk_path} && git pull origin && git add . && git commit -m $versionStr
    git push origin
}

workStart ${1?} ${2?} ${3} ${4} 

