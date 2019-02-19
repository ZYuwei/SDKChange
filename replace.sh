#! /bin/bash

function replace_content(){
	#读取内容
	# content=$(cat "${file}")
	content=""
	cat "${file}" | while read line ; do
		content="${line}"
		echo "content ${content}"
		
		importRegularStr="^ *#import *[<\"]${oldPrefix}.*\.[hm][\">]"
		# 文件引用的替换
		if [[ "${content}" =~ $importRegularStr ]]; then
			content=${content/${oldPrefix}/${newPrefix}}
			echo "文件引用的替换：${content}"
			echo "${content}" >> ${newFile}
			continue
		fi

		#类声名的替换
		classRegularStr="^ *@[a-zA-Z]* *${oldPrefix}.*"
		if [[ "${content}" =~ $classRegularStr ]]; then
			content=${content/${oldPrefix}/${newPrefix}}
			echo "类声名的替换：${content}"
			echo "${content}" >> ${newFile}
			continue
		fi

		#方法名的替换
		# methodRegularStr="^ *[-+] *\(.*\)${oldPrefix}.*"
		# if [[ "${content}" =~ $methodRegularStr ]]; then
		# 	content=${content/${oldPrefix}/${newPrefix}}
		# 	echo "方法的替换：${content}"
		# fi

		#内容替换
		contentRegularStr=".*${oldPrefix}.*"
		if [[ "${content}" =~ $contentRegularStr ]]; then
			content=${content//${oldPrefix}/${newPrefix}}
			echo "内容替换：${content}"
		fi
		echo "${content}" >> ${newFile}

	done	
}

#1:输入文件路径 #2:输出文件路径 #3旧的前缀 #4新的前缀
function replace(){
	#文件路径
	file=${1?}
	newFile=${2?}
	oldPrefix=${3?}
	newPrefix=${4?}

	if ! test -e $newFile
	then

		# fileName=${newFile##*/}
		filePath=${newFile%/*}
		mkdir -p $filePath
		touch $newFile		
	else
		rm $newFile
		touch $newFile
	fi

	replace_content
}

