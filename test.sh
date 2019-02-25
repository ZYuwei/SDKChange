#! /bin/bash
enArray=('a1' 'b1' 'c1' 'd1' 'e1' 'f1' 'g1' 'h1' 'i1' 'j1' 'k1' 'l1' 'm1' 'n1' 'o1' 'p1' 'q1' 'r1' 's1' 't1' 'u1' 'v1' 'w1' 's1' 'y1' 'z1') #26


function judgeEnString(){
	rubbishEnArr=${*}
	rubbishNewObjNameRand=`echo $RANDOM%26 | bc`
	rubbishNewObjName=${enArray[rubbishNewObjNameRand]}
	rubbishEnArrStr="${rubbishEnArr[*]}"
	echo rubbishNewObjNameRand $rubbishNewObjNameRand rubbishNewObjName $rubbishNewObjName
	echo rubbishEnArr $rubbishEnArr
	if [[ $rubbishEnArrStr =~ $rubbishNewObjName ]]; then
		echo 参数重复重新获取
		judgeEnString $rubbishEnArr
	else
		echo $rubbishNewObjName
	fi
}

arr=('a1' 'b1' 'c1' 'd1' 'e1' 'f1' 'g1' 'h1' 'i1' 'j1' 'k1' 'l1' 'm1' 'n1' 'o1' 'p1' 'r1' 's1' 't1' 'u1' 'v1' 'w1' 's1' 'z1')
echo "${arr[*]}"
judgeEnString $arr

# rubbishNewObjNameRand=`echo $RANDOM%26 | bc`
# rubbishNewObjName=${enArray[rubbishNewObjNameRand]}
# echo rubbishNewObjNameRand $rubbishNewObjNameRand rubbishNewObjName $rubbishNewObjName