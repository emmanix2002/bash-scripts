#!/bin/bash
setup_smarty() {
	#sets up the smarty project
	SMARTY_DIRS=( cache configs templates templates_c )
	#the directories we need in a smarty project
	PROJECT_PATH=$1
	#gets the project path as an argument
	echo "Working on project $PROJECT_PATH ..."
	directory_exists=0
	#whether or not to continue execution  -- to be used later
	if [ ! -d $PROJECT_PATH ]; then
		#the path does not exist
		echo "Project does not exist...Creating it..."
		mkdir $PROJECT_PATH
		#try to create it
		if [ -d $PROJECT_PATH ]; then
			#it now exists
			echo "Project successfully created..."
			directory_exists=1
		fi
	else
		#it exists -- so we continue
		directory_exists=1
		echo "Project directory already exists...moving forward..."
	fi
	if [ $directory_exists -eq 1 ]; then
		#the directory exists -- create the smarty directories
		CURRENT_PATH=`pwd`
		#gets the value of the current path
		echo "Current working directory: $CURRENT_PATH ..."
		cd $PROJECT_PATH
		#change the working directory
		echo "Changing working directory to: $PROJECT_PATH ..."
		if [ ! -d ./smarty_tpls ]; then
			#the path does not exist
			echo "smarty_tpls directory doesn't exist in project...Creating it..."
			mkdir ./smarty_tpls
			#try to create it
			if [ -d ./smarty_tpls ]; then
				#it now exists
				echo "Directory successfully created..."
				directory_exists=1
			fi
		else
			#it exists -- so we continue
			directory_exists=1
			echo "Project directory already exists...moving forward..."
		fi
		#lets change the owner priviledges on all the files and folders to grant Apache access
		chown -R $USER:www-data .
		#done with that		
		for smarty_dir in "${SMARTY_DIRS[@]}"; do
			#loop through each
			echo "Checking SMARTY directory $smarty_dir ..."
			if [ ! -d ./smarty_tpls/$smarty_dir ]; then
				#the directory does not already exist
				echo "It does not exist...creating it..."
				mkdir ./smarty_tpls/$smarty_dir
				#create it
			else
				#it already exists
				echo "It already exists...moving forward..."
			fi
			if [ -d ./smarty_tpls/$smarty_dir ]; then
				#it was successfully created -- or exists
				echo "Directory $smarty_dir found..."
				if [ "$smarty_dir"="cache" ]; then
					#it's the cache directory
					echo "Changing permissions on the $smarty_dir directory..."
					chmod -R 777 ./smarty_tpls/$smarty_dir
				elif [ "$smarty_dir"="templates_c" ]; then
					#the templates_c directory
					echo "Changing permissions on the $smarty_dir directory..."
					chmod -R 777 ./smarty_tpls/$smarty_dir
				else
					#for other directories
					chmod -R 644 ./smarty_tpls/$smarty_dir
				fi
			else
				#not found
				echo "Could not find $smarty_dir directory..."
			fi
		done
		cd $CURRENT_PATH
		echo "Changing working directory back to: $CURRENT_PATH ..."
	else
		#directory creation failed
		echo "Could not create project directory..."
	fi
}

echo 'Starting smarty initializer script...'
argv=$#
#get the number of supplied arguments
if [ $argv -ge 1 ]; then
	setup_smarty $1
	#call the function
else
	echo 'No folder name was supplied to the script...'
	exit 1
fi
echo 'Closing script...Bye!'

