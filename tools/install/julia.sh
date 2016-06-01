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
	# Navigate to parent directory:
	cd ..

	# Upgrade to the latest version of `git`:
	sudo apt-get install git-all

	# Use `https` instead of `git`:
	git config --global url."https://".insteadOf git://

	# Clone the latest stable version of Julia from the Julia repository:
	git clone --depth=50 --branch=release-0.4 git://github.com/JuliaLang/julia.git julia

	# Navigate to the cloned directory:
	cd julia

	# Run `make` to build the `julia` executable:
	make

	# Add the Julia directory to the executable path for this shell session:
	export PATH="$(pwd):$PATH"

	# Test that the installation is working properly:
	make testall

	# Navigate back to project directory:
	cd ../test-travis-node-julia

	# Run tests:
	npm run test-cov
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
