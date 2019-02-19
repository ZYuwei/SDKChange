#! /bin/bash


oldPrefix="CS"


function setGit(){
	packagefile=${1?}
	newPrefix=${2?}

	gitPath="${packagefile}/${newPrefix}"
	echo "git地址" $gitPath

	if ! test -e $gitPath ; then
		mkdir -p $gitPath
		echo "创建git 路径"
	else
		rm -f $gitPath
		mkdir -p $gitPath
		echo "删除git 路径并创建新的"
	fi
	#创建git仓库
	cd $gitPath
	git init

}

#setGit "/Users/zy/WorkSpace/Test/ShellTest/package" "TEST"






