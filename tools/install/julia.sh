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
	sudo add-apt-repository ppa:staticfloat/juliareleases -y
	sudo add-apt-repository ppa:staticfloat/julia-deps -y
	sudo apt-get update
	sudo apt-get install julia

	julia --version

	# Run tests:
	echo 'Running Node.js tests...'
	npm run test-cov
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
