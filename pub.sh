#! /usr/bin/env zsh
source ~/.zshrc

# Function to validate ID input
validate_id() {
  # Add your validation logic here
  # Example: Ensure ID is a positive integer
  if [[ ! $1 =~ ^[1-9][0-9]*$ ]]; then
    return 1
  fi
  return 0
}

echo "Enter subdomain of store you're working on"
read subdomain

# Validate subdomain validation logic here
valid_domain=false
# Example: Ensure subdomain is not empty - allow user to try again
while [[ $valid_domain == false ]]; do
  if [[ -z $subdomain ]]; then
    echo "Subdomain cannot be empty. Please enter a valid subdomain."
    read subdomain
    #if the subdomain ends in .myshopify.com, or a variant of it, remove it
  elif [[ $subdomain =~ ^[a-zA-Z0-9-]+\.myshopify\.com$ ]]; then
    subdomain=${subdomain%.myshopify.com}
    valid_domain=true
  elif [[ $subdomain =~ ^[a-zA-Z0-9-]+\.myshopify\.com\/$ ]]; then
    subdomain=${subdomain%.myshopify.com/}
    valid_domain=true
  elif [[ $subdomain =~ ^[a-zA-Z0-9-]+\.myshopify\.com\/.*$ ]]; then
    subdomain=${subdomain%.myshopify.com/*}
    valid_domain=true
  else
    valid_domain=true
  fi
done


echo "What are you doing?"
read task
task="${task// /-}"
type_regex='^[1-4]+$'
echo "What type of customization are you working on?"
echo "1 = Theme"
echo "2 = Script"
echo "3 = Order"
echo "4 = Notification"
read type
# Validate type validation logic here
valid_type=false

# Example: Ensure type is not empty - allow user to try again
while [[ $valid_type == false ]]; do
  if [[ -z $type ]]; then
    echo "Type cannot be empty. Please enter a valid type."
    read type
  else
  #check the type is a number between 1 and 4
    if [[ ! $type =~ $type_regex ]]; then
      echo "Type must be a number between 1 and 4. Please enter a valid type."
      read type
      elif [[ $type -eq 1 ]]; then
        valid_type=true
      elif [[ $type -eq 2 ]]; then
        valid_type=true
      elif [[ $type -eq 3 ]]; then
        valid_type=true
      elif [[ $type -eq 4 ]]; then
        valid_type=true
      else
        echo "Type must be a number between 1 and 4. Please enter a valid type."
        read type
    fi
    
  fi
done

valid_id=false
while [[ $valid_id == false ]]; do
  if [[ $type -eq 1 ]]; then
    echo "Enter theme ID of the theme that you're working on"
    read themeid
    if validate_id "$themeid"; then
      valid_id=true
    else
      echo "Invalid theme ID. Please enter a valid theme ID."
    fi
  elif [[ $type -eq 2 ]]; then
    echo "Enter script ID of the script that you're working on"
    read scriptid
    if validate_id "$scriptid"; then
      valid_id=true
    else
      echo "Invalid script ID. Please enter a valid script ID."
    fi
  elif [[ $type -eq 3 ]]; then
    echo "Enter ID of the order printer template that you're working on"
    read otid
    if validate_id "$otid"; then
      valid_id=true
    else
      echo "Invalid order template ID. Please enter a valid order template ID."
    fi
  elif [[ $type -eq 4 ]]; then
    echo "Enter handle of the notification template that you're working on"
    read notificationid
    if validate_id "$notificationid"; then
      valid_id=true
    else
      echo "Invalid notification template ID. Please enter a valid notification template ID."
    fi
  else
    echo "Unexpected input: $type"
    exit 1
  fi
done
#create a regex tnat cnecks if the input is a valid themekit password, consisting of only letters, numbers and underscores
themekit_regex='^[a-zA-Z0-9_]+$'
#if option 1 is selected and it is valid, read in themekit password
if [[ $type -eq 1 ]]; then
  echo "Enter your themekit password"
  read themekit
  valid_themekit=false
  while [[ $valid_themekit == false ]]; do
    if [[ ! $themekit =~ $themekit_regex ]]; then
      echo "Themekit password must only contain letters, underscores and numbers. Please enter a valid themekit password."
      read themekit
    else
      valid_themekit=true
    fi
  done
fi

echo "Moving to sample-merchant-repo..."
dev cd sample-merchant-repo    

echo "Switching to master branch and pulling latest changes..."

git checkout master && git pull origin master
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to checkout and pull from master branch."
  exit 1
fi

git checkout -b "${subdomain}-${task}-init"
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to create a new branch."
  exit 1
fi

if [[ $type -eq 1 ]]; then
#check if the subdomain folder exists
#if it does, move into it and check for the themeid folder
#if not, create the subdomain folder and themeid folder
if [[ -d "${subdomain}" ]]; then
  cd "${subdomain}"
  if [[ -d "${themeid}" ]]; then
    cd "${themeid}"
    echo "Theme already exists. Moving into theme folder..."
  else
    mkdir -p "${themeid}"
    cd "${themeid}"
    echo "Theme folder created. Moving into theme folder..."
  fi
  elif [[ ! -d "${subdomain}" ]]; then
    mkdir -p "${subdomain}/${themeid}"
    cd "${subdomain}/${themeid}"
    echo "Subdomain and theme folder created. Moving into theme folder..."
fi
  echo 'option 1'
  tee -a config.yml <<CON
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

  theme download
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to download the theme."
    exit 1
  fi
echo "Theme downloaded."
code .
theme open
theme watch
elif [[ $type -eq 2 ]]; then
  mkdir -p "${subdomain}/scripts"
  cd "${subdomain}/scripts"
  touch "${scriptid}.rb"
  echo '${scriptid}.rb created.'
  #pause to allow user to edit script
  read -p "Press enter to continue, once you've added the existing script"
  #Commit only the script file
  git add "${scriptid}.rb"
  git commit -m "Add existing script ${scriptid}.rb"
  git push origin "${subdomain}-${task}-init"
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to push to remote branch."
    exit 1
  fi
  # open PR
  #might need to leverage dev here
  # pause to allow user to create a PR
  dev open pr
  read -p "Press enter to continue, once you've created and merged the initial PR"
  #merge PR
  git checkout master
  git pull origin master

  elif [[ $type -eq 3 ]]; then
  mkdir -p "${subdomain}/orders"
  cd "${subdomain}/orders"
  touch "${otid}.liquid"
  echo 'option 3'
elif [[ $type -eq 4 ]]; then
  mkdir -p "${subdomain}/notifications"
  cd "${subdomain}/notifications"
  touch "${notificationid}.liquid"
  echo 'option 4'
fi