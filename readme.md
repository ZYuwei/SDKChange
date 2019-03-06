# 脚本使用方法
注：大部分SDK都会依赖统计SDK，因此在打DEMO时，需先将统计SDK打包出相应前缀
## 1配置shell.config文件
目前针对统计、买量、支付 SDK 设置了默认的前缀，如需增加SDK的设置需要在此文件中配置

## 2.正确配置.config文件
*****若需输入空格时用';'代替*****

内容如下:
<!--源码的名字-->
s.old_name='Co_pay_PaymentSDK'
<!--源码的前缀-->
s.old_prefix='Co_pay_'
<!--设置的将要导出的SDK的前缀数组;以,分割每一个前缀-->
s.new_prefix='Re_new_','Test'
<!--源码的git仓库-->
s.in_path='https://gitlab.com/gomo_sdk/GOMOPayment.git'

 以下配置无需多次修改所有SDK可共用一个
 
<!--代码文件的本地根目录-->
s.in_file_base_path='/Users/zy/WorkSpace/Test/ShellTest/source'
<!--打包时使用的临时根目录-->
s.out_file_base_path='/Users/zy/WorkSpace/Test/ShellTest/package'
<!--framework压缩包的根目录-->
s.sdk_file_base_path='/Users/zy/WorkSpace/Test/ShellTest/framework'
<!--framework压缩包存放的git仓库-->
s.out_path='https://github.com/ZYuwei/sdk_insulate_framework.git'
<!--私有pod的配置根目录-->
s.pod_spec_base_path='/Users/zy/WorkSpace/Test/ShellTest/sdk_insulate_spec'
<!--pod私有库的Git地址-->
s.pod_git_path='https://gitlab.com/gomo_sdk/sdk_insulate_spec.git'

## 3调用main.sh 脚本文件

调用脚本时，需传递4个参数
参数1:
具有3种选项
1  #通过config下所有前缀进行打包framework;
2  #通过config以及在参数3输入的前缀进行打包framework;
3  #通过config以及在参数3输入的前缀进行打包Demo;
参数2:
配置文件的地址
参数3:
版本号或者分支
参数4:
单独设置前缀或打Demo时使用新前缀
### 如: ./main.sh '3' '/Users/zy/WorkSpace/Test/ShellTest/shell/configExample/Co_pay_PaymentSDK.config' 'new_pay_master' 'New_Test_' 
