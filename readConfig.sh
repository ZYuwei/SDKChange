#! /bin/bash	


function changeConfig(){
	config_str=${1?}
	config_str=${config_str%\#*}
	config_str=${config_str#*\'}
	config_str=${config_str%\'*}

	if [[ ${#config_str} <1 ]]; then
		echo -e "\033[33m error: the lack of config, please review config \033[0m" 
		kill $$	
	fi
	echo $config_str
}

function readConfig(){
	configFile=${1?}

	old_name=`grep -h 's.old_name.*' $configFile`
	old_name=`changeConfig $old_name`


	old_prefix=`grep -h 's.old_prefix.*' $configFile`
	old_prefix=`changeConfig $old_prefix`

	in_git_path=`grep -h 's.in_path.*' $configFile`
	in_git_path=`changeConfig $in_git_path`


	out_git_path=`grep -h 's.out_path.*' $configFile`
	out_git_path=`changeConfig $out_git_path`

	pod_spec_base_path=`grep -h 's.pod_spec_base_path.*' $configFile`
	pod_spec_base_path=`changeConfig $pod_spec_base_path`

	in_file_base_path=`grep -h 's.in_file_base_path.*' $configFile`
	in_file_base_path=`changeConfig $in_file_base_path`

	sdk_file_base_path=`grep -h 's.sdk_file_base_path.*' $configFile`
	sdk_file_base_path=`changeConfig $sdk_file_base_path`

	out_file_base_path=`grep -h 's.out_file_base_path.*' $configFile`
	out_file_base_path=`changeConfig $out_file_base_path`

	pod_git_path=`grep -h 's.pod_git_path.*' $configFile`
	pod_git_path=`changeConfig $pod_git_path`
	
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

	echo old_name: $old_name
	echo old_prefix: $old_prefix
	echo new_prefix_arr: ${new_prefix_arr[*]}
	echo in_git_path: $in_git_path
	echo out_git_path: $out_git_path
	echo in_file_base_path: $in_file_base_path
	echo sdk_file_base_path: $sdk_file_base_path
	echo out_file_base_path: $out_file_base_path

}

# function readConfigPath(){
#     for file in ${config_path}/*; do
#     echo 开始读取配置
#     if test -f $file ; then
#         readConfig $file
#     fi
# 	done
# }

