#! /bin/bash

rubbishCodePath="/Users/zy/WorkSpace/Test/ShellTest/RubbishCode"

classArray=('NSString' 'UILabel' 'NSDictionary' 'NSData' 'UIScrollView' 'UIView' 'NSObject' 'UIImage' 'NSArray' 'UIImageView' 'NSMutableString')
methodNameArray=('action' 'setup' 'reset' 'pay' 'notificaiton' 'load' 'reload' 'status' 'progress' 'resume' 'cancel' 'add' 'remove') #13
methodParamArray=('str' 'lab' 'dic' 'data' 'scrol' 'view' 'obj' 'img' 'arr' 'imgV' 'mutableStr') #11
enArray=('a1' 'b1' 'c1' 'd1' 'e1' 'f1' 'g1' 'h1' 'i1' 'j1' 'k1' 'l1' 'm1' 'n1' 'o1' 'p1' 'q1' 'r1' 's1' 't1' 'u1' 'v1' 'w1' 's1' 'y1' 'z1') #26

function judgeEnString(){
	arr=${1}
	newObjNameRand=`echo $RANDOM%26 | bc`
	newObjName=${enArray[newObjNameRand]}
	if [[ ${arr[*]} =~ newObjName && ${#objArr[*]} > 1 ]]; then
		judgeEnString $arr
	else
		echo $newObjName
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
		objArrLastIndex=$(echo ${#objArr[*]}-1 | bc)
		objArr[objArrLastIndex]=$newObjName
		newClassRand=`echo $RANDOM%11 | bc`
		objClass=${classArray[newClassRand]}
		contentStr="${contentStr}\n ${objClass} *${newObjName} = [${objClass} new]"
	done

	echo $contentStr
}

function generateFunc(){
	# 随机取一个方法名
	randMethodName=`echo $RANDOM%12 | bc`
	methonName=${methodNameArray[randMethodName]}
	# 判断方法名是否存在
	if [ `grep -c ")$methonName" $file` -ne '0' ]; then
		echo found same method $methonName ,will reset
		generateFunc
		return
	fi

	funcStr="- (void)$methonName"
	# 随机传参个数
	randPramNum=`echo $RANDOM%2+1 | bc`
	# 参数名
	for (( i = 0; i<$randPramNum; i++ ))
	do
		# 随机取一个类
		randPram=`echo $RANDOM%10 | bc`
		randPramClass=${classArray[randPram]}
		randPramName=${methodParamArray[randPram]}
		if [[ $i == 0 ]]; then
			funcStr="${funcStr}With:(${randPramClass} *)${randPramName} "
		else
			funcStr="${funcStr}with:(${randPramClass} *)${randPramName} "
		fi
	done
	funcStr="${funcStr}{"
	contentString=`generateFuncContent`
	echo $funcStr $contentString
}

function rubbishCode(){
	file=${1?}
	fileRegularStr='.m$'
	if [[ ${file} =~ $fileRegularStr ]]; then
		echo '在文件中生成垃圾代码 ' $file
		# 在.m中生成垃圾代码
		 randNum=`echo $RANDOM%10+3 | bc`
		 for (( r = 0; r < $randNum; r++ )); do
 			generateFunc
		 done
	fi
}

for file in ${rubbishCodePath}/* ; do
	if test -f $file ; then
		rubbishCode $file
	fi
done
