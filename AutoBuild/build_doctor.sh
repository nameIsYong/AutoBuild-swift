#蒲公英
User_Key=""
API_Key=""

#---------------------------CD到jenkins的工作目录
cd /Users/mac/files/workspace_ios/线上/ios_phone/WorldDoctor

#---------------------------配置工程名
project_name=WorldDoctor
#---------------------------配置不同的scheme名（一个工程下可能多个target）
scheme_name=WorldDoctor_Doctor

#----------------------------打包模式Debug/Release
development_mode=Debug

#----------------------------配置打包脚本文件所在目录
superPath=/Users/mac/重要的文件/AutoBuild

#----------------------------配置打包后编译出文件父目录
saveFilPath=${superPath}/build

#----------------------------配置.ipa文件存放目录
ipaFilePath=${saveFilPath}/`date '+%Y_%m_%d_%H_%M_%S'`

#----------------------------配置.ipa文件路径
ipaPath=${ipaFilePath}/${scheme_name}.ipa

#****************************************************************************
#$(cd "$(dirname "$0")"; pwd)
#echo '当前路径--->'$saveFilPath


#plist文件所在路径
exportOptionsPlistPath=${superPath}/DevelopmentExportOptionsPlist.plist
xcarchivePath=${saveFilPath}/${scheme_name}.xcarchive

ipaName=`date '+%Y_%m_%d_%H_%M_%S'`  

echo '*** 正在 清理工程 ***'
xcodebuild \
clean -configuration ${development_mode} -quiet  || exit 
echo '*** 清理完成 ***'


echo '*** 正在 编译工程 For '${development_mode}
xcodebuild -workspace ${project_name}.xcworkspace -scheme ${scheme_name} -archivePath ${xcarchivePath} -configuration Debug archive -quiet  || exit

#xcodebuild archive -project ${project_name}.xcworkspace -scheme ${scheme_name} -archivePath ${xcarchivePath} -quiet  || exit

echo '*** 编译完成 ***'

echo '*** 正在 打包 ***即将导出到 '${ipaPath}

xcodebuild -exportArchive -archivePath ${xcarchivePath} \
-configuration ${development_mode} \
-exportPath ${ipaFilePath} \
-exportOptionsPlist ${exportOptionsPlistPath} \
-quiet || exit


if  [ -e $ipaPath ]
then

    echo '*** .ipa文件已导出 ***>'$ipaPath
    cd ${ipaFilePath}
    echo "*** 开始上传.ipa文件 ***"

    RESULT=$(curl -F "file=@$ipaPath" -F "uKey=$User_Key" -F "_api_key=$API_Key" -F "publishRange=2" http://www.pgyer.com/apiv1/app/upload)

    echo "*** .ipa文件上传成功 ***"
    echo $RESULT
else
    echo "*** 准备上传ipa文件，但没找到该文件 ***"
fi


echo "*** 打包完成准备导出 ***"
if [[ -d ${saveFilPath} ]]; then
echo "*** 删除原包 ***"
rm -rf ${saveFilPath} -r
fi



echo '*** 打包完成 ***'

