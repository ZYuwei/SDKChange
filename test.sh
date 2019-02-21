#! /bin/bash	

enArray=('a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 's' 'y' 'z') #26

newObjName=${enArray[4]}

if [[ ${enArray[*]} =~ $newObjName ]]; then
	forinArr=('')
	for (( i = 0; i < 10; i++ )); do
		forinArrLastIndex=$(echo ${#forinArr[*]} | bc)
		echo $forinArrLastIndex
		forinArr[forinArrLastIndex]=$newObjName
	done

	echo ${forinArr[*]}
fi