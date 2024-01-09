#! /usr/bin/env zsh

# Source the zshrc file to load any necessary environment variables
source ~/.zshrc

# Regular expression to validate subdomain and task inputs
regex='^[a-zA-Z0-9-]+$'
# numbers regex to validate theme, script, order, and notification IDs
numbers='^[0-9]+$'

# Prompt user to enter the subdomain of the store they're working on
echo "Enter subdomain of store you're working on"
while true; do
  read subdomain
  if [[ $subdomain =~ $regex ]]; then
    break
  else
    echo "Invalid subdomain, please try again"
  fi
done

# Prompt user to enter the task they're working on
echo "What are you doing?"
while true; do
  read task
  if [[ $task =~ $regex ]]; then
    break
  else
    echo "Invalid task, please try again"
  fi
done

# Prompt user to select the type of customization they're working on
valid_task='^[1-4]+$'
echo "What type of customization are you working on?"
echo "1 = Theme"
echo "2 = Script"
echo "3 = Order"
echo "4 = Notification"
while true; do
  read type
  if [[ $type =~ $valid_task ]]; then
    break
  else
    echo "Invalid type, please try again"
  fi
done

# Handle different customization types
if [[ $type -eq 1 ]]; then
  echo "Enter theme ID of the theme that you're working on"
  while true; do
    read themeid
    #TODO: Investifate regex error
    #./pub.sh:52: failed to compile regex: empty (sub)expression
    if [[ $themeid =~ $numbers ]]; then
      break
    else
      echo "Invalid ID, please try again"
    fi
  done
  echo "Enter Shopify CLI password"
  read shopify_cli
elif [[ $type -eq 2 ]]; then
  echo "Enter script ID of the script that you're working on"
  while true; do
    read scriptid
    if [[ $scriptid =~ $numbers ]]; then
      break
    else
      echo "Invalid ID, please try again"
    fi
  done
elif [[ $type -eq 3 ]]; then
  echo "Enter ID of the order printer template that you're working on"
  while true; do
    read otid
    if [[ $otid =~ $numbers ]]; then
      break
    else
      echo "Invalid ID, please try again"
    fi
  done
elif [[ $type -eq 4 ]]; then
  echo "Enter handle of the notification template that you're working on"
  read notificationid
fi

# Replace spaces in the task with dashes
task="${${task}// /-}"

# Print the subdomain, task, and theme ID
echo ${subdomain} ${task} ${themeid}

# Switch to the sample-merchant-repo directory
echo "Switching directories"
cd ~/Documents/sample-merchant-repo

# Create a new branch for the customization
echo "Creating new branch ${subdomain}-${task}-init"
git checkout master && git pull origin master
git checkout -b ${subdomain}-${task}-init

# Handle different customization types
if [[ $type -eq 1 ]]; then
  # Create the necessary directories and files for a theme customization
  mkdir -p ${subdomain}/${themeid}
  cd ${subdomain}/${themeid}
  echo 'option 1'
  # Generate the shopify.theme.toml file
  tee -a shopify.theme.toml << CON
[environments.env${subdomain}${themeid}]
  password = "${shopify_cli}"
  store = "${subdomain}"
  theme_id = "${themeid}"
  ignore = [
    "config/settings_data.json",
    "config/settings.html",
    "*.png",
    "*.jpg",
    "*.jpeg",
    "*.gif",
    "*.pdf",
    "*.mp4"
  ]
CON

  # Open the theme in VSCode
  echo "Opening theme in VSCode"
  code .

  # Pull the theme from Shopify
  echo "Pulling theme from Shopify"
  shopify theme pull -e env

elif [[ $type -eq 2 ]]; then
  # Create the necessary directories and files for a script customization
  mkdir -p ${subdomain}/scripts
  cd ${subdomain}/scripts
  touch ${scriptid}.rb
  echo 'option 2'

elif [[ $type -eq 3 ]]; then
  # Create the necessary directories and files for an order customization
  mkdir -p ${subdomain}/orders
  cd ${subdomain}/orders
  touch ${otid}.liquid
  echo 'option 3'

elif [[ $type -eq 4 ]]; then
  # Create the necessary directories and files for a notification customization
  mkdir -p ${subdomain}/notifications
  cd ${subdomain}/notifications
  touch ${notificationid}.liquid
  echo 'option 4'

else
  echo "Unexpected input" $type
fi

# Add, commit, and push the changes to the new branch
git add .
git commit -m "${subdomain} ${task} init"
git push origin ${subdomain}-${task}-init

# Open a new pull request on GitHub
open https://github.com/aisling-krewer/sample-merchant-repo/pull/new/${subdomain}-${task}-init

# Wait for the PR to be merged
echo "Press enter when the PR is merged."
read cont

# Switch back to the master branch
git checkout master && git pull origin master
git checkout -b ${subdomain}-${task}

# Serve the theme if the customization type is a theme
if [[ $type -eq 1 ]]; then
  shopify theme dev -e env
fi