#! /bin/bash	


function readConfig(){
	configFile=${1?}

	old_name=`grep -h 's.old_name.*' $configFile`
	old_name=${old_name%\#*}
	old_name=${old_name#*\'}
	old_name=${old_name%\'*}

	if [[ ${#old_name} <1 ]]; then
		echo error: no old_name, please review config
		kill $$	
	fi


	old_prefix=`grep -h 's.old_prefix.*' $configFile`
	old_prefix=${old_prefix%\#*}
	old_prefix=${old_prefix#*\'}
	old_prefix=${old_prefix%\'*}

	if [[ ${#old_prefix} <1 ]]; then
		echo error: no old_prefix, please review config
		kill $$	
	fi

	new_prefixs=`grep -h 's.new_prefix.*' $configFile`
	new_prefixs=${new_prefixs#*=}
	new_prefixs=${new_prefixs%\#*}
	while [[ ${#new_prefixs} >1 ]]; do
		prefix=${new_prefixs%,*}
		if [[ $new_prefixs == $prefix ]]; then
			unset new_prefixs 
		else
			new_prefixs=${new_prefixs#*,}
		fi

		prefix=${prefix#*\'}
		prefix=${prefix%%\'*}
		new_prefix_arr[${#new_prefix_arr[*]}]=$prefix
	done

	if [[ ${#new_prefix_arr[*]} <1 ]]; then
		echo error: no new_prefixs, please review config
		kill $$	
	fi


	in_git_path=`grep -h 's.in_path.*' $configFile`
	in_git_path=${in_git_path%\#*}
	in_git_path=${in_git_path#*\'}
	in_git_path=${in_git_path%\'*}

	if [[ ${#in_git_path} <1 ]]; then
		echo error: no in_path, please review config
		kill $$	
	fi

	out_git_path=`grep -h 's.out_path.*' $configFile`
	out_git_path=${out_git_path%\#*}
	out_git_path=${out_git_path#*\'}
	out_git_path=${out_git_path%\'*}

	if [[ ${#out_git_path} <1 ]]; then
		echo error: no out_path, please review config
		kill $$	
	fi

	echo old_name: $old_name
	echo old_prefix: $old_prefix
	echo new_prefix_arr: ${new_prefix_arr[*]}
	echo in_git_path: $in_git_path
	echo out_git_path: $out_git_path
}

# function readConfigPath(){
#     for file in ${config_path}/*; do
#     echo 开始读取配置
#     if test -f $file ; then
#         readConfig $file
#     fi
# 	done
# }

