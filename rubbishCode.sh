#! /bin/bash

classArray=('NSString' 'UILabel' 'NSDictionary' 'NSData' 'UIScrollView' 'UIView' 'NSObject' 'UIImage' 'NSArray' 'UIImageView' 'NSMutableString') #11
methodNameArray=('action' 'setup' 'reset' 'pay' 'notificaiton' 'load' 'reload' 'status' 'progress' 'resume' 'cancel' 'add' 'remove') #13
methodParamArray=('str' 'lab' 'dic' 'data' 'scrol' 'view' 'obj' 'img' 'arr' 'imgV' 'mutableStr') #11
enArray=('a1' 'b1' 'c1' 'd1' 'e1' 'f1' 'g1' 'h1' 'i1' 'j1' 'k1' 'l1' 'm1' 'n1' 'o1' 'p1' 'q1' 'r1' 's1' 't1' 'u1' 'v1' 'w1' 's1' 'y1' 'z1') #26


function judgeEnString(){
	rubbishEnArr=${1}
	rubbishNewObjNameRand=`echo $RANDOM%26 | bc`
	rubbishNewObjName=${enArray[rubbishNewObjNameRand]}
	rubbishEnArrStr="${rubbishEnArr[*]}"
	if [[ $rubbishEnArrStr =~ $rubbishNewObjName ]]; then
		judgeEnString $rubbishEnArr
	else
		echo $rubbishNewObjName
	fi
}

function judgeParmString(){
	rubbishParmArr=${1}
	rubbishParmNameRand=`echo $RANDOM%11 | bc`
	rubbishPramClass=${classArray[rubbishParmNameRand]}
	rubbishParmName=${methodParamArray[rubbishParmNameRand]}
	rubbishParamArrStr="${rubbishParmArr[*]}"
	if [[ $rubbishParamArrStr =~ $rubbishParmName ]]; then
		judgeParmString $rubbishParmArr
	else
		echo "(${rubbishPramClass} *)${rubbishParmName}"
	fi
}

function generateFuncContent(){
	# 生成方法内容
	rubbishObjArr=('')
	#  随机初始化对象的个数
	rubbishNewObjRandNum=`echo $RANDOM%5+1 | bc`
	for (( rubbishJ = 0; rubbishJ < $rubbishNewObjRandNum; rubbishJ++ )); do
		# 判断name是否重复并获取一个不重复的
		rubbishewObjName=`judgeEnString $rubbishObjArr`
		# objArrIndex=$(echo ${#rubbishObjArr[*]} | bc)
		rubbishObjArr[${#rubbishObjArr[*]}]=$rubbishewObjName
		rubbishNewClassRand=`echo $RANDOM%11 | bc`
		rubbishObjClass=${classArray[rubbishNewClassRand]}
		rubbishContentStr="${rubbishContentStr}\\ ${rubbishObjClass} *${rubbishewObjName} = [${rubbishObjClass} new];"
	done
	# 增加for循环
	rubbishForinRandNum=`echo $RANDOM%3+1 | bc`
	for (( rubbishI = 0; rubbishI < $rubbishForinRandNum; rubbishI++ )); do
		rubbishForinRandCount=`echo $RANDOM%50+1 | bc`
		rubbishForinStr="for (int i=0; i<${rubbishForinRandCount}; i++) {"
		rubbishForinArr=('')
		rubbishForinObjRandNum=`echo $RANDOM%5+1 | bc`
		for (( rubbishM = 0; rubbishM < $rubbishForinObjRandNum; rubbishM++ )); do
			# 判断name是否重复并获取一个不重复的
			rubbishForinObjName=`judgeEnString $rubbishForinArr`
			# forinArrIndex=$(echo ${#rubbishForinArr[*]} | bc)
			rubbishForinArr[${#rubbishForinArr[*]}]=$rubbishForinObjName
			rubbishForinClassRand=`echo $RANDOM%11 | bc`
			rubbishForinObjClass=${classArray[rubbishForinClassRand]}
			rubbishForinStr="${rubbishForinStr}\\ ${rubbishForinObjClass} *${rubbishForinObjName} = [${rubbishForinObjClass} new];"
		done
		rubbishContentStr="${rubbishContentStr}\\${rubbishForinStr}\\}"
	done
}

function generateFunc(){
	# 随机取一个方法名
	rubbishRandMethodNum=`echo $RANDOM%13 | bc`
	rubbishRandMethodName=${methodNameArray[rubbishRandMethodNum]}
	# 判断方法名是否存在
	if [ `grep -c ")$rubbishRandMethodName" $rubbishFile` -ne '0' ]; then
		echo found same method $rubbishRandMethodName ,will reset 
		generateFunc
	else
		rubbishFuncStr="- (void)$rubbishRandMethodName"
		# 随机传参个数
		rubbishFandPramNum=`echo $RANDOM%2+1 | bc`
		# 参数名数组
		rubbishParamArray=('')
		for (( rubbishZ = 0; rubbishZ<$rubbishFandPramNum; rubbishZ++ ))
		do
			# 随机取一个类
			rubbishRandPramName=`judgeParmString $rubbishParamArray`
			# rubbishParamArrayLastIndex=$(echo ${#rubbishParamArray[*]} | bc)
			rubbishParamArray[${#rubbishParamArray[*]}]=$rubbishRandPramName
			if [[ $i == 0 ]]; then
				rubbishFuncStr="${rubbishFuncStr}With:${rubbishRandPramName} "
			else
				rubbishFuncStr="${rubbishFuncStr}with:${rubbishRandPramName} "
			fi
		done
		rubbishFuncStr="${rubbishFuncStr}{"
		# 获取内容
		generateFuncContent 
		rubbishInsetCode="${rubbishFuncStr}${rubbishContentStr}\\}\\"
		# echo rubbishContentStr $rubbishContentStr
		unset rubbishContentStr
	fi

}

function insetFile(){

	rubbishAllLineString=`grep '^[-+].*(.*).*' $rubbishFile`

	rubbishLineArr=()
	while [[ ${#rubbishAllLineString} != 0 ]]; do
		# 条件需要修改 当{处于下一行时无法正常筛选
		rubbishLineStr="${rubbishAllLineString%%{*}{"
		rubbishLineStrlength=${#rubbishLineStr}
		rubbishAllLineString=${rubbishAllLineString:${rubbishLineStrlength}}
		rubbishLineArr[${#rubbishLineArr[*]}]=$rubbishLineStr
		# echo rubbishLineStr $rubbishLineStr rubbishAllLineString $rubbishAllLineString
	done

	if [[ ${#rubbishLineArr[*]} > 0 ]]; then
		rubbishInsetLineNum=`echo $RANDOM%${#rubbishLineArr[*]} | bc`
		rubbishInsetLineStr=${rubbishLineArr[$rubbishInsetLineNum]}
		rubbishInsetLineStr="${rubbishInsetLineStr#*)}"
		rubbishInsetLineStr="${rubbishInsetLineStr%%:*}"
		rubbishInsetLineStr="${rubbishInsetLineStr%%{*}"

		if [[ ${#rubbishInsetLineStr} != 0 ]]; then
			# 获取垃圾代码
			generateFunc
			#插入
			sed -i '' -e "/)${rubbishInsetLineStr}/i\\
			${rubbishInsetCode}" $rubbishFile
			echo insert rubbishInsetLineStr $rubbishInsetLineStr rubbishInsetCode $rubbishInsetCode
		fi
		echo noinsert because no rubbishInsetLineStr rubbishFile $rubbishFile
	else
		echo noinsert because no rubbishLineArr rubbishFile $rubbishFile
	fi
	unset rubbishInsetCode
	unset rubbishLineArr
}

function rubbishCode(){
	rubbishFile=${1?}
	rubbishfileRegularStr='.m$'
	if [[ ${rubbishFile} =~ $rubbishfileRegularStr ]]; then
		echo '在文件中生成垃圾代码 ' $rubbishFile
		# 在.m中生成垃圾代码
		 rubbishRandNum=`echo $RANDOM%4+1 | bc`
		 echo rubbishRandNum $rubbishRandNum
		 for (( rubbishR = 0; rubbishR < $rubbishRandNum; rubbishR++ )); do
			insetFile
		 done
	fi
	unset rubbishFile
}
