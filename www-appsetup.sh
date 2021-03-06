#!/bin/bash
#It's important that you navigate to this project's directory before running the setup script
show_help() {
	echo "Usage: www-appsetup [-h|--help] [path] [LOGIN]"
	echo ""
	echo "It changes the user/group permissions for a web project; The directory must have either a root index.php file, an html directory or an index.html file"
	echo "It also changes read-write perms of all folders with 'upload' in them to 777"
	echo ""
	echo "optional arguments:"
	echo "-h, --help           show this help message and exit"
	echo "path           This specifies the path to the directory to be processed. It defaults to the current working directory"
	echo "LOGIN                the system username to use with the command user:group change -- it is especially useful when running the script in sudo mode"
	echo ""
	echo "Example:"
	echo "www-appsetup.sh - this will run the script on the current pwd"
	echo "www-appsetup.sh /var/www - runs the scrip on the /var/www directory setting [LOGIN] to the current user"
	echo "www-appsetup.sh /var/www ubuntu"
	exit 0
}

set_permissions() {
	app_directory=$1
	username=$2
	current_working_directory=`pwd`
	if [ ! -d $app_directory ]; then
		#directory does not exist
		echo "The supplied directory $app_directory does not exist"
		echo "Try passing the --help argument e.g. www-appsetup --help"
		exit 1
	fi
	if [ ! $app_directory == $current_working_directory ]; then
		echo "Switching to directory $app_directory"
		cd $app_directory
	fi
	html_directories=$(find . -type d -path "*html" | wc -l)
	if [[ -f "./index.php" || -f "./index.html" || -d "./public" || -d "./html" || -d "./web" || $html_directories -gt 0 ]]; then
		# it's a project's web root
		echo "Changing ownership..."
		chown -R $username:www-data .
		echo "Changing file and directory permissions..."
		find . -type f -exec chmod 644 {} \;
		find . -type f -name '*.sh' -exec chmod +x {} \;
		find . -type d -exec chmod 755 {} \;

		find . -type d -name "*upload*" -exec chmod -R 777 {} \;
		#specifically for upload directories -- changes permissions on all directories with upload in their name
		find . -type d -path "*/tmp" -exec chmod -R 770 {} \;
		# for temporary directories -- if found
		find . -type d -path "*/smarty*/cache" -exec chmod -R 777 {} \;
		find . -type d -path "*/smarty*/templates_c" -exec chmod -R 777 {} \;
		find . -type d -path "*/views/cache" -exec chmod -R 777 {} \;
        find . -type d -path "*/views/templates_c" -exec chmod -R 777 {} \;
		#specifically set the permissions on smarty/views folders
		
		#if the person is using composer, we'll need to make bin files executable
		find . -type f -path "*/vendor/*/bin/*" -exec chmod +x {} \;
	else
		echo "This doesn't seem to be the root of a project -- Exiting..."
		exit 1
	fi
	if [ ! $app_directory == $current_working_directory ]; then
		echo "Switching back to directory $current_working_directory"
		cd $current_working_directory
	fi
}

argv=$#
#get the number of supplied arguments
username=$USER
app_directory=`pwd`
#sets a default value for the app_directory
if [ $argv -ge 1 ]; then
	if [ $1 == "--help" ]; then
		show_help
	elif [ $1 == "-h" ]; then
		show_help
	fi
	app_directory=$1
	#if an argument is supplied -- set the value to the argument
	if [ $argv -ge 2 ]; then
		# we set a different username than the assumed if provided
		username=$2
	fi
fi
if [ ! $app_directory == "/" ]; then
	echo 'Starting WWW-AppSetup script...'
	set_permissions $app_directory $username
else
	echo "You shouldn't run this command from the FileSystem root...Go somewhere else!!"
	exit 1
fi
echo 'Cleaning up after myself...Bye!'
exit 0
