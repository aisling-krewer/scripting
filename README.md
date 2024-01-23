# README.md

## Script Name: pub.sh

The Plus Utility Belt (PUB) is a tool used by the Plus Front End Development (PFED) team to streamline how we make adjustments to themes, notifications and scripts. With the upcoming deprecation of ThemeKit, and the level of maintenance the PUB currently requires, I've been working on an alternative implementation that will use Shopify's CLI instead, and be overall easier to maintain.

### Prerequisites

You should already have the following if you used the PFED Bootstrapper to set up your system as of 22/12/23.

- Zsh installed on your system.
- The script assumes that you have a `.zshrc` file in your home directory (`~/.zshrc`) that sets up necessary environment variables.

You will also need to install the Shopify CLI. In the future this may be added to the bootstrapper, but for now, you may need to install this manually. [The instructions are available in the Help Docs here!](https://shopify.dev/docs/themes/tools/cli/install)


### Usage

1. Make sure the script is executable. If not, you can make it executable by running `chmod +x pub.sh` in your terminal.
2. Run the script by typing `./pub.sh` in your terminal.

I hope to add this as an alias in coming updates, so that it may be run anywhere with a command such as `pub`.

### Code Explanation

The code performs the following steps:

1. Prompts the user to enter the subdomain of the store they're working on.
   - In the finished version, it should handle store names, myshopify URLs, and the new admin URLs to minimize mental load.

2. Prompts the user to enter the task they're working on.

3. Prompts the user to select the type of customization they're working on.
[!NOTE] The code includes scripts despite their upcoming deprecation. This may be removed in future updates.

4. Prompts the user for input based on the value of the variable 'type':
   - If 'type' is equal to 1, the user is asked to enter a theme ID.
   - If 'type' is equal to 2, the user is asked to enter a script ID.
   - If 'type' is equal to 3, the user is asked to enter an order printer template ID.
   - If 'type' is equal to 4, the user is asked to enter a notification template handle.

5. Validates the input using regular expressions to ensure it consists of only numbers.
   - If the input is invalid, the user is prompted to try again.

6. Stores the entered values in the variables 'themeid', 'scriptid', 'otid', and 'notificationid', respectively.

7. Switches to the "sample-merchant-repo" directory.

8. Creates a new branch for customization.

9. Handles different customization types:
   - For type 1, it creates necessary directories and files for a theme customization.
	   - Generates the "shopify.theme.toml" file with environment-specific settings.
	   - Opens the theme in VSCode.
	   - Pulls the theme from Shopify.

   -  For type 2, it creates directories and files for a script customization.

   -  For type 3, it creates directories and files for an order customization.

   -  For type 4, it creates directories and files for a notification customization.

   -  If 'type' is none of the above, it prints an error message indicating unexpected input, and will prompt the user for valid input.

14. The directories are created using the `mkdir -p` command, which creates parent directories if they don't exist.

15. Files are added using the `touch` command.

16. The directories and files are named based on the values of the variables 'subdomain', 'scriptid', 'otid', and 'notificationid'.

17. After creating the directories and files, it prints the corresponding option number.

18. Adds, commits, and pushes the changes to a new branch in a Git repository.

19. Opens a new pull request on GitHub.

20. Waits for the user to confirm the pull request was merged.

21. Switches back to the main branch and pulls the latest changes.

22. Creates a new branch

23. Serves the theme if the customization type is a theme.

### Note
This is an experiment under development, and this document is subject to regular revision and updates. 