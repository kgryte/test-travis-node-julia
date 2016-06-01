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
	# sudo apt-get install git-all

	# Use `https` instead of `git`:
	# git config --global url."https://".insteadOf git://

	# Clone the latest stable version of Julia from the Julia repository:
	echo ''
	echo 'Cloning the latest stable version of Julia...'
	git clone --depth=50 --branch=release-0.4 git://github.com/JuliaLang/julia.git julia
	echo ''

	# Navigate to the cloned directory:
	echo ''
	echo 'Entering Julia directory...'
	cd julia
	echo ''

	make check-whitespace
	contrib/travis_fastfail.sh || exit 1;

    mkdir -p $HOME/bin;

    ln -s /usr/bin/gcc-5 $HOME/bin/gcc;
    ln -s /usr/bin/g++-5 $HOME/bin/g++;
    ln -s /usr/bin/gfortran-5 $HOME/bin/gfortran;
    ln -s /usr/bin/gcc-5 $HOME/bin/x86_64-linux-gnu-gcc;
    ln -s /usr/bin/g++-5 $HOME/bin/x86_64-linux-gnu-g++;

    echo ''
    echo 'The current gcc version...'
    gcc --version;
    echo ''

    BUILDOPTS="-j3 VERBOSE=1 FORCE_ASSERTIONS=1 LLVM_ASSERTIONS=1";
    echo "override ARCH=$ARCH" >> Make.user;
    TESTSTORUN="all";

    echo ''
    echo 'Cloning helper utilities repository...'
    git clone -q git://git.kitenet.net/moreutils
    echo ''

    make -C moreutils mispipe
    make $BUILDOPTS -C base version_git.jl.phony
    moreutils/mispipe "make $BUILDOPTS NO_GIT=1 -C deps" bar > deps.log || cat deps.log


	# Run `make` to build the `julia` executable:
	echo ''
	echo 'Building the Julia executable...'
	make
	echo ''

	# Add the Julia directory to the executable path for this shell session:
	export PATH="$(pwd):$PATH"

	# Test that the installation is working properly:
	echo ''
	echo 'Testing the Julia installation...'
	make testall
	echo ''

	# Navigate back to project directory:
	cd ../test-travis-node-julia

	# Run tests:
	echo ''
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
