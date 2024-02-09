#! /usr/bin/env zsh

# Source the zshrc file to load any necessary environment variables
source ~/.zshrc

# Regular expression to validate subdomain and task inputs
strict_regex='^[a-zA-Z0-9-]+$'
# numbers regex to validate theme, script, order, and notification IDs
numbers='^[0-9]+$'
space_regex='^[a-zA-Z0-9\s-]+$'

# Prompt user to enter the subdomain of the store they're working on
# TODO: Handle full .myshopify URLs as well as subdomains
echo "Enter subdomain of store you're working on"
while true; do
  read subdomain
  if [[ $subdomain =~ $strict_regex ]]; then
    break
  else
    echo "Invalid subdomain, please try again"
  fi
done

# Prompt user to enter the task they're working on
# TODO: Handle spaces in the task
echo "What are you doing?"
while true; do
  read task
  #regex should accept letters, numbers, spaces, and dashes
  # e.g. 'add-new-product' should pass,
  # 'adding new css file' should also pass
  if [[ $task =~ $strict_regex ]]; then
    break
  else
    echo "Invalid task, please try again"
  fi
done

# Prompt user to select the type of customization they're working on
valid_task='^[1-4]$'
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
elif [[ $type -eq 42 ]]; then
  echo "
  000000000000000000000000000000000000000000000000000000
000000000000000000000000942313248000000000000000000000
000088000000000000637               739000000000000000
03       71900047                       76000000000000
9  780000081777                           710000000000
07 700000007                           777   300000000
097 300004     7777                 72000097  79000000
006 72001   7800000027            74000000087  7400000
0006 731   7000000000067        76000000000777   50000
000087407        400000047      2000000001000097 76000
0000096004        7400000027    72000083000000007 7000
000003730007        500000000061  711200000000027  400
000007  760097       90000000000037 10000000027    300
00008    7700057     740000000000087730000016847   700
00008      7200037     30000000000007 73218000002  700
000007        600037    79000000000087  1000000067 300
000003         7900037   3000000000001  700000027  400
000009           760005779000000000008   729617   7000
0000002            7600000000000000008           74000
00000007            760000000000000004           20000
000000007         76000000000000000007          740000
0000000003      790000000000000000004         74875000
000000000087  76000000000000000000097        780007200
0000000000009900000000000000000000000477   79000008750
000000000000000000000000000000001 71000007000000000270
00000000000000000000000000000027    776477 73400008779
00000000000000000000000000004113290000000005177    720
000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000
"
else
  echo "Unexpected input" $type
  #This doesn't stop the script, if the user enters numbers less than 1 or greater than 4
  #we need to figure how to send the user back to the start in this case.

#send user back to start if they enter a number that isn't defined in the case statement

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

  # Generate the shopify.theme.toml file
  #TODO: Make enviroment unique to update in question
  #TODO: Break if the file already exists
  tee -a shopify.theme.toml << CON
[environments.env${subdomain}${themeid}${task}]
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
  shopify theme pull -e env${subdomain}${themeid}

elif [[ $type -eq 2 ]]; then
  # Create the necessary directories and files for a script customization
  mkdir -p ${subdomain}/scripts
  cd ${subdomain}/scripts
  touch ${scriptid}.rb
  echo "If there is a script that you would like to use, please add it now and press enter when you're done. Otherwise, press enter to continue."
  code .
  read cont
elif [[ $type -eq 3 ]]; then
  # Create the necessary directories and files for an order customization
  mkdir -p ${subdomain}/orders
  cd ${subdomain}/orders
  touch ${otid}.liquid
  echo "If there is a order template that you would like to use, please add it now and press enter when you're done. Otherwise, press enter to continue."
  code .
  read cont
elif [[ $type -eq 4 ]]; then
  # Create the necessary directories and files for a notification customization
  mkdir -p ${subdomain}/notifications
  cd ${subdomain}/notifications
  touch ${notificationid}.liquid
  echo "If there is a notification template that you would like to use, please add it now and press enter when you're done. Otherwise, press enter to continue."
  code .
  read cont
else
  echo "Unexpected input" $type
fi

# Add, commit, and push the changes to the new branch
git add .
git commit -m "[${subdomain}]$ {task}-init"
git push origin ${subdomain}-${task}-init

# Open a new pull request on GitHub
open https://github.com/aisling-krewer/sample-merchant-repo/pull/new/${subdomain}-${task}-init

# Wait for the PR to be merged
echo "Press enter when the PR is merged."
read cont

# Switch back to the main branch
echo "Switching to the main branch and pulling the latest changes"
#TODO: Main v master - is that something we need to handle here?
# Main can cause some issues if master is still the default term used.
#TEMP: For now switching to master for testing, will switch back to main to align with proper terminology
git checkout master && git pull origin master
echo "Creating new branch ${subdomain}-${task}"
git checkout -b ${subdomain}-${task}
code .
# Serve the theme if the customization type is a theme
if [[ $type -eq 1 ]]; then
  echo "Serving theme"
  shopify theme dev -e env${subdomain}${themeid}
  echo "Press enter when you're done serving the theme"
  read cont
fi