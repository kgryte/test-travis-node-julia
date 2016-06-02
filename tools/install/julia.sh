#!/usr/bin/env bash

# DESCRIPTION #

# Script to install Julia.


# FUNCTIONS #

# Defines an error handler.
on_error() {
	echo 'ERROR: An error was encountered during execution.'
	cleanup
	exit 1
}

# Installs Julia.
install_julia() {
	if [ "$TRAVIS_OS_NAME" == "osx" ]; then
		url='https://s3.amazonaws.com/julialang/bin/osx/x64/0.4/julia-0.4.5-osx10.7+.dmg'

		# Generate a random file name:
		tmp_file=/tmp/`openssl rand -base64 10 | tr -dc '[:alnum:]'`.dmg
		apps_folder='/Applications'

		# Download file:
		echo "Downloading $url..."
		curl -# -L -o $tmp_file $url

		echo "Mounting image..."
		volume=`hdiutil mount $tmp_file | tail -n1 | perl -nle '/(\/Volumes\/[^ ]+)/; print $1'`

		# Locate `.app` folder and move to `/Applications`:
		app=`find $volume/. -name *.app -maxdepth 1 -type d -print0`
		echo "Copying `echo $app | awk -F/ '{print $NF}'` into $apps_folder..."
		cp -ir $app $apps_folder

		# Unmount volume, deleting the temporary file:
		echo "Cleaning up..."
		hdiutil unmount $volume -quiet
		rm $tmp_file

		# Place the Julia executable in our path:
		export PATH=/Applications/Julia-0.4.5.app/Contents/Resources/julia/bin/:$PATH
	else
		# Add personal package archives (PPAs) for updating to the latest stable Julia versions...
		echo 'Adding PPAs...'
		sudo add-apt-repository ppa:staticfloat/juliareleases -y
		sudo add-apt-repository ppa:staticfloat/julia-deps -y
		echo ''

		# Download and update package lists:
		echo 'Updating package lists...'
		sudo apt-get update
		echo ''

		# Install Julia:
		echo 'Installing Julia...'
		sudo apt-get install julia
		echo ''
	fi

	julia --version
	echo ''

	# Navigate to the test fixtures directory:
	echo 'Navigating to test fixtures directory...'
	cd ./test/fixtures
	echo ''

	# Install the required dependencies:
	echo 'Installing Julia dependencies...'
	julia -e 'Pkg.status()'
	sort -u REQUIRE >> ~/.julia/v0.4/REQUIRE
	julia -e 'Pkg.resolve()'
	julia -e 'Pkg.status()'
	echo ''

	# Generate test fixtures:
	echo 'Generating test fixtures...'
	julia -e 'include("./runner.jl")'
	cat data.json
	echo ''

	# Navigate back to the parent directory:
	echo 'Navigating back to the parent directory...'
	cd ../..

	# Run tests:
	echo 'Running Node.js tests...'
	npm run test
	echo ''
}

# Runs clean-up tasks.
cleanup() {
	echo ''
}


# MAIN #

# Exit immediately if one of the executed commands exits with a non-zero status:
set -e

# Set an error handler to print captured output and perform any clean-up tasks:
trap 'on_error' ERR

# Install Julia:
install_julia

# Run cleanup tasks:
cleanup
