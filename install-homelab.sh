#!/usr/bin/env bash
set -e

# Function to check if a Homebrew package is installed
is_brew_package_installed() {
    brew list --formula | grep -Fqx "$1"
}

# Function to check if a Helm plugin is installed
is_helm_plugin_installed() {
    helm plugin list | grep -Fq "$1"
}

# Install Helm if not installed
if ! is_brew_package_installed helm; then
    echo "Installing Helm..."
    brew install helm
else
    echo "Helm is already installed."
fi

# Install Helmfile if not installed
if ! is_brew_package_installed helmfile; then
    echo "Installing Helmfile..."
    brew install helmfile
else
    echo "Helmfile is already installed."
fi

# Install Helm Diff plugin if not installed
if ! is_helm_plugin_installed diff; then
    echo "Installing helm-diff plugin..."
    helm plugin install https://github.com/databus23/helm-diff
else
    echo "helm-diff plugin is already installed."
fi

helmfile sync