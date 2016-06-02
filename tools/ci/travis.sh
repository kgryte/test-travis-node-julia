#!/usr/bin/env bash

# DESCRIPTION #

# Script to run continuous integration.


# FUNCTIONS #

# Defines an error handler.
on_error() {
	echo 'ERROR: An error was encountered during execution.'
	cleanup
	exit 1
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

# Install required Julia dependencies:
echo 'Installing Julia dependencies...'
julia -e 'Pkg.status()'
sort -u ./test/fixtures/REQUIRE >> ~/.julia/v0.4/REQUIRE
julia -e 'Pkg.resolve()'
julia -e 'Pkg.status()'

# Generate test fixtures:
echo 'Generating test fixtures...'
julia -e 'include("./test/fixtures/runner.jl")'
cat ./test/fixtures/data.json

# Run tests:
echo 'Running Node.js tests...'
npm run test

# Run cleanup tasks:
cleanup
