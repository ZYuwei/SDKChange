#! /bin/bash

rubbishCodePath="/Users/zy/WorkSpace/Test/ShellTest/RubbishCode"

classArray=('NSString' 'UILabel' 'NSDictionary' 'NSData' 'UIScrollView' 'UIView' 'NSObject' 'UIImage' 'NSArray' 'UIImageView' 'NSMutableString') #11
methodNameArray=('action' 'setup' 'reset' 'pay' 'notificaiton' 'load' 'reload' 'status' 'progress' 'resume' 'cancel' 'add' 'remove') #13
methodParamArray=('str' 'lab' 'dic' 'data' 'scrol' 'view' 'obj' 'img' 'arr' 'imgV' 'mutableStr') #11
enArray=('a1' 'b1' 'c1' 'd1' 'e1' 'f1' 'g1' 'h1' 'i1' 'j1' 'k1' 'l1' 'm1' 'n1' 'o1' 'p1' 'q1' 'r1' 's1' 't1' 'u1' 'v1' 'w1' 's1' 'y1' 'z1') #26

function judgeEnString(){
	arr=${1}
	newObjNameRand=`echo $RANDOM%26 | bc`
	newObjName=${enArray[newObjNameRand]}
	if [[ ${arr[*]} =~ newObjName && ${#arr[*]} > 1 ]]; then
		judgeEnString $arr
	else
		echo $newObjName
	fi
}

function judgeParmString(){
	parmArr=${1}
	parmNameRand=`echo $RANDOM%11 | bc`
	pramClass=${classArray[parmNameRand]}
	parmName=${methodParamArray[parmNameRand]}
	if [[ ${parmArr[*]} =~ parmName && ${#parmArr[*]} > 1 ]]; then
		judgeParmString $parmArr
	else
		echo "(${pramClass} *)${parmName}"
	fi
}

function generateFuncContent(){
	contentStr=''
	# 生成方法内容
	objArr=('')
	#  随机初始化对象的个数
	newObjRandNum=`echo $RANDOM%5+1 | bc`
	for (( j = 0; j < $newObjRandNum; j++ )); do
		# 判断name是否重复并获取一个不重复的
		newObjName=`judgeEnString $objArr`
		objArrIndex=$(echo ${#objArr[*]} | bc)
		objArr[objArrIndex]=$newObjName
		newClassRand=`echo $RANDOM%11 | bc`
		objClass=${classArray[newClassRand]}
		contentStr="${contentStr}\n ${objClass} *${newObjName} = [${objClass} new];"
	done
	# 增加for循环
	forinRandNum=`echo $RANDOM%5+1 | bc`
	for (( i = 0; i < $forinRandNum; i++ )); do
		forinRandCount=`echo $RANDOM%10+1 | bc`
		forinStr="for (int i=0; i<${forinRandCount}; i++) {"
		forinArr=('')
		forinObjRandNum=`echo $RANDOM%5+1 | bc`
		for (( m = 0; m < $forinObjRandNum; m++ )); do
			# 判断name是否重复并获取一个不重复的
			forinObjName=`judgeEnString $forinArr`
			forinArrIndex=$(echo ${#forinArr[*]} | bc)
			forinArr[forinArrIndex]=$forinObjName
			forinClassRand=`echo $RANDOM%11 | bc`
			forinObjClass=${classArray[forinClassRand]}
			forinStr="${forinStr}\n ${forinObjClass} *${forinObjName} = [${forinObjClass} new];"
		done
		contentStr="${contentStr}\n${forinStr}\n}"
	done
	echo ${contentStr}
}

function generateFunc(){
	# 随机取一个方法名
	randMethodName=`echo $RANDOM%12 | bc`
	methonName=${methodNameArray[randMethodName]}
	# 判断方法名是否存在
	if [ `grep -c ")$methonName" $file` -ne '0' ]; then
		# echo found same method $methonName ,will reset 2
		generateFunc
		return
	fi

	funcStr="- (void)$methonName"
	# 随机传参个数
	randPramNum=`echo $RANDOM%2+1 | bc`
	# 参数名数组
	paramArray=('')
	for (( i = 0; i<$randPramNum; i++ ))
	do
		# 随机取一个类
		randPramName=`judgeParmString $paramArray`
		paramArrayLastIndex=$(echo ${#paramArray[*]}-1 | bc)
		paramArray[paramArrayLastIndex]=$randPramName
		if [[ $i == 0 ]]; then
			funcStr="${funcStr}With:${randPramName} "
		else
			funcStr="${funcStr}with:${randPramName} "
		fi
	done
	funcStr="${funcStr}{"
	# 获取内容
	contentString=`generateFuncContent`
	funcStr="${funcStr}${contentString}\n}\n"
	echo $funcStr
}

function insetFile(){
	insetCode=${1?}

}

function rubbishCode(){
	file=${1?}
	fileRegularStr='.m$'
	if [[ ${file} =~ $fileRegularStr ]]; then
		echo '在文件中生成垃圾代码 ' $file
		# 在.m中生成垃圾代码
		 randNum=`echo $RANDOM%10+3 | bc`
		 for (( r = 0; r < $randNum; r++ )); do
			code=`generateFunc`
			echo -e $code >> $file
		 done
	fi
}

for file in ${rubbishCodePath}/* ; do
	if test -f $file ; then
		rubbishCode $file
	fi
done
