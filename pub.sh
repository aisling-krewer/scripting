#! /usr/bin/env zsh
source ~/.zshrc

echo "Enter subdomain of store you're working on"
read subdomain
echo "What are you doing?"
read task
echo "What type of customisation are you working on?"
echo "1 = Theme"
echo "2 = Script"
echo "3 = Order"
echo "4 = Notification"
read type
echo "Enter theme ID of theme that you're working on"
read themeid
echo "Enter themekit password"
read themekit

task="${${task}// /-}"
echo  ${subdomain} ${task} ${themeid}

cd ~/Documents/sample-merchant-repo

git checkout master && git pull origin master
git checkout -b ${subdomain}-${task}-init

if [[ $type -eq 1 ]]
then
mkdir -p ${subdomain}/${themeid}
cd ${subdomain}/${themeid}
echo 'option 1'
tee -a config.yml << CON
development:
  password:  ${themekit}
  theme_id:  ${themeid}
  store:  ${subdomain}.myshopify.com
  timeout: 30s
  ignore_files:
      - "config/settings_data.json"
      - "config/settings.html"
      - "*.png"
      - "*.jpg"
      - "*.jpeg"
      - "*.gif"
      - "*.pdf"
      - "*.mp4"
CON

code .

theme download

elif [[ $type -eq 2 ]]
then
  mkdir -p ${subdomain}/scripts
  cd ${subdomain}/scripts
  echo 'option 2'
elif [[ $type -eq 3 ]]
then
  mkdir -p ${subdomain}/orders
  cd ${subdomain}/orders
  echo 'option 3'
elif [[ $type -eq 4 ]]
then
  mkdir -p ${subdomain}/notifications
  cd ${subdomain}/notifications
  echo 'option 4'
else
  echo "Unexpected input" $type
fi

git add .
git commit -m "${subdomain} ${task} init"
git push origin ${subdomain}-${task}-init
open https://github.com/aisling-krewer/sample-merchant-repo/pull/new/${subdomain}-${task}-init

echo "Press enter to when the PR is merged."
read cont
git checkout master && git pull origin master
git checkout -b ${subdomain}-${task}
theme open
theme watch