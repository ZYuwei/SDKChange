#! /bin/bash

function prefixLow(){
	prifixStr=${1?}
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
		oldMethodPrefix=`prefixLow $oldPrefix`
		newMethodPrefix=`prefixLow $newPrefix`
		sed -i '' -e "s/$oldMethodPrefix/$newMethodPrefix/g" -e "s/$oldPrefix/$newPrefix/g" $newFile
	elif [[ ${file} =~ $podRegularStr ]]; then
		echo "修改podfile文件 " $file

		sed -i '' "/pod.*${oldPrefix}/s/$oldPrefix/$newPrefix/g" $newFile
	fi	
}

function replace_podSpec(){

	filePath=${newFile%/*}
	mkdir -p $filePath
	touch $newFile		

	cp -r $file $newFile

	sed -i '' "s/$oldPrefix/$newPrefix/g" $newFile
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
	newPrefix=${4?}
	sdkName=${5?}

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

