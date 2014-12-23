#!/bin/bash
#It's important that you navigate to this project's directory before running the setup script
show_help() {
	echo "Usage: www-appsetup [-h|--help] path"
	echo ""
	echo "It changes the user/group permissions for a web project; The directory must have a root index.php file"
	echo "It also changes read-write perms of all folders with 'upload' in them to 777"
	echo ""
	echo "required arguments:"
	echo "path           This specifies the path to the directory to be processed"
	echo ""
	echo "optional arguments:"
	echo "-h, --help           show this help message and exit"
	exit 0
}

set_permissions() {
	app_directory=$1
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
	if [[ -f "./index.php" || -f "./index.html" || -d "./html" ]]; then
		# it's a project's web root
		chown -R $USER:www .
		find . -type f -exec chmod 644 {} \;
		find . -type d -exec chmod 750 {} \;
		
		find . -type d -name "*upload*" -exec chmod -R 777 {} \;
		#specifically for upload directories -- changes permissions on all directories with upload in their name
		find . -type d -path "*/smarty_tpls/cache" -exec chmod -R 777 {} \;
		find . -type d -path "*/smarty_tpls/templates_c" -exec chmod -R 777 {} \;
		#specifically set the permissions on smarty folders
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
fi
if [ ! $app_directory == "/" ]; then
	echo 'Starting WWW-AppSetup script...'
	set_permissions $app_directory
else
	echo "You shouldn't run this command from the FileSystem root...Go somewhere else!!"
	exit 1
fi
echo 'Cleaning up after myself...Bye!'
exit 0
