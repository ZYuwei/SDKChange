#! /bin/bash
replace_base_path=$(cd `dirname $0`; pwd)
function readShellConfig(){
	prefixList=`grep -h 's.prefixList.*' ${replace_base_path}/shell.config`
	prefixList=${prefixList#*=}
	prefixList=${prefixList%\#*}
	echo will change prefixList $prefixList replace_base_path ${replace_base_path}/shell.config
	while [[ ${#prefixList} >1 ]]; do
		prefixConfig=${prefixList%,*}
		if [[ $prefixList == $prefixConfig ]]; then
			unset prefixList 
		else
			prefixList=${prefixList#*,}
		fi

		prefixConfig=${prefixConfig#*\'}
		prefixConfig=${prefixConfig%%\'*}
		echo prefixConfig $prefixConfig
		prefix_config_arr[${#prefix_config_arr[*]}]=$prefixConfig
	done
}
readShellConfig

function prefixLow(){
	prifixStr=${1}
	firstStr="${prifixStr:0:1}"
	otherStr=${prifixStr:1}
	firstStr=`echo $firstStr | tr 'A-Z' 'a-z'`
	echo "$firstStr$otherStr"
}

function replace_content(){

	# 过滤文件类型
	cp -r $file $newFile
	fileRegularStr=".*.[hm]$"
	podRegularStr=".*Podfile"
	if [[ ${file} =~ $fileRegularStr ]]; then
	    echo "修改OC文件 " $file
		#内容替换
		newMethodPrefix=`prefixLow $newPrefix`
		for config_Prefix in ${prefix_config_arr[*]}; do
			oldMethodPrefix=`prefixLow $config_Prefix`
			sed -i '' -e "s/$oldMethodPrefix/$newMethodPrefix/g" -e "s/$config_Prefix/$newPrefix/g" $newFile
		done
	elif [[ ${file} =~ $podRegularStr ]]; then
		echo "修改podfile文件 " $file

		for config_Prefix in ${prefix_config_arr[*]}; do
			sed -i '' "/pod.*${config_Prefix}/s/$config_Prefix/$newPrefix/g" $newFile
		done
	fi	
}

function replace_podSpec(){

	filePath=${newFile%/*}
	mkdir -p $filePath
	touch $newFile		

	cp -r $file $newFile

	# sed -i '' "s/$oldPrefix/$newPrefix/g" $newFile
	# 修改关联前缀的SDK
	for config_Prefix in ${prefix_config_arr[*]}; do
		sed -i '' "s/$config_Prefix/$newPrefix/g" $newFile
	done

	sedFilePathStr=${filePath//\//\\\/}
	sedFilePathStr="{  :git =>'${sedFilePathStr}'}"
	sed -i '' "/s.source *=/s/{.*}/${sedFilePathStr}/g" $newFile
}

#1:输入文件路径 #2:输出文件路径 #3旧的前缀 #4新的前缀
function replace(){
	#文件路径
	file=${1?}
	newFile=${2?}
	oldPrefix=${3?}
	sdkName=${4?}
	newPrefix=${5}

	for config_Prefix in ${prefix_config_arr[*]}; do
	    newfile=${newfile//${config_Prefix}/${newPrefix}}		
	done

	filePath=${newFile%/*}
	mkdir -p $filePath
	touch $newFile	

	oldFileName=${file##*/}
	echo "oldFileName" $oldFileName 
	if [[ $oldFileName == "${sdkName}.podspec" ]]; then
		echo "podSpec 替换"
		replace_podSpec 
	else
        replace_content
    fi
	
}

