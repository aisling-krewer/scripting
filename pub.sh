#! /usr/bin/env zsh 
source ~/.zshrc

echo "Enter subdomain of store you're working on"
read subdomain
echo "What are you doing?"
read task
echo "Enter theme ID of theme that you're working on"
read themeid
echo "Enter themekit password"
read themekit

task="${${task}// /-}"
echo  ${subdomain} ${task} ${themeid}

cd ~/Documents/sample-merchant-repo

git checkout master && git pull origin master
git checkout -b ${subdomain}-${task}-init
mkdir -p ${subdomain}/${themeid}
cd ${subdomain}/${themeid}
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