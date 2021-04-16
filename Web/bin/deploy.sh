# 将demo打包并发布到内部gitlab

if [ ! -n "$1" ]; then
  echo "第一个参数为远端的分支名，请填写！"
  exit 8
else
  echo "远端的分支名为"$1
fi

# 当前目录
currentPath=$PWD
# gitlab 项目目录
gitlabPath="../nim-web-demo-pc"
# 打包结果目录
fromPath=$currentPath"/dist"
# demo存放目录
toPath=$gitlabPath"/webdemo/groupCall/"
# 推送远端分支
branch=$1
# 是否本地存在该分支的标识符
branchExist="false"

# 打包
echo "安装依赖"
cd $currentPath
cnpm i
echo "开始打包"
if [ "$branch" = "test" ]; then
  npm run build:test
else
  npm run build
fi
echo "打包完成"

# 进入到目标项目
if [ ! -d "$gitlabPath" ]; then
  echo "请填写正确的远端仓库目录地址！"
  exit 8
fi
cd $gitlabPath

# 判断是否有branch分支，有的话切到该分支，没有的话，从远端拉取一个该分支
for BRANCH in `git branch --list|sed 's/\*//g'`;
  do
    if [ "$BRANCH" = "$branch" ]; then
      branchExist="true"
      break
    fi
  done
if [ "$branchExist" = "true" ]; then
  git checkout $branch
else
  git checkout -b $branch "origin/"$branch
fi
echo "切换分支到"$branch

# 更新代码
git pull
git fetch

# 将打包后的结果复制到gitlab项目
if [ ! -d "$fromPath" ]; then
  echo "找不到需要拷贝的目录"
  exit 8
else
  # 先清空目标目录
  rm -rf $toPath
  cp -R -f $fromPath"/." $toPath
  echo "代码复制完成"
  # 将该项目推送到远端
  git add .
  git status
  git commit -m "Update groupCall"
  git push origin $branch

  echo $gitlabPath"推送到"$branch"成功！"
fi
