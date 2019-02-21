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
	if [[ ${file} =~ $fileRegularStr ]]; then
	    echo "修改OC文件 " $file
	    #读取内容
		# content=""
		# cat "${file}" | while read line ; do
		# 	content="${line}"
		# 	# echo "content ${content}"

		# 	importRegularStr=".*#import *[<\"]${oldPrefix}.*\.[hm]"
		# 	# 文件引用的替换
		# 	if [[ "${content}" =~ $importRegularStr ]]; then
		# 		content=${content/${oldPrefix}/${newPrefix}}
		# 		# echo "文件引用的替换：${content}"
		# 		echo "${content}" >> ${newFile}
		# 		continue
		# 	fi

		# 	#类声名的替换
		# 	classRegularStr="^ *@[a-zA-Z]* *${oldPrefix}.*"
		# 	if [[ "${content}" =~ $classRegularStr ]]; then
		# 		content=${content/${oldPrefix}/${newPrefix}}
		# 		# echo "类声名的替换：${content}"
		# 		echo "${content}" >> ${newFile}
		# 		continue
		# 	fi	
		# 	echo "${content}" >> ${newFile}		
		# done

		#方法名的替换
		# oldMethodPrefix=`prefixLow $oldPrefix`
		# newMethodPrefix=`prefixLow $newPrefix`
		# methodRegularStr="^ *${oldMethodPrefix}.*"
		# if [[ "${content}" =~ $methodRegularStr ]]; then
		# 	content=${content//${oldMethodPrefix}/${newMethodPrefix}}
		# 	echo "方法名的替换：${content}"
		# fi

		#其他内容替换
		# contentRegularStr=".*${oldPrefix}.*"
		# if [[ "${content}" =~ $contentRegularStr ]]; then
		# 	content=${content//${oldPrefix}/${newPrefix}}
		# 	# echo "内容替换：${content}"
		# fi
		
		#内容替换
		oldMethodPrefix=`prefixLow $oldPrefix`
		newMethodPrefix=`prefixLow $newPrefix`
		sed -i '' -e "s/$oldMethodPrefix/$newMethodPrefix/g" -e "s/$oldPrefix/$newPrefix/g" $newFile
	fi	
}

function replace_podSpec(){

	filePath=${newFile%/*}
	mkdir -p $filePath
	touch $newFile		

	cp -r $file $newFile

	sed -i '' "s/$oldPrefix/$newPrefix/g" $newFile
	sedFilePathStr=${filePath//\//\\\/}
	sed -i '' "/s.source *=/s/\'.*\'/\'$sedFilePathStr\'/g" $newFile
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

