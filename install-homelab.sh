#!/usr/bin/env bash
set -e

# List of Homebrew packages to be installed
brew_packages=("helm" "helmfile" "kubeseal")

# Associative array for Helm plugins (plugin name as key, URL as value)
declare -A helm_plugins=(
    [diff]="https://github.com/databus23/helm-diff"
)

# Function to check if a Homebrew package is installed
is_brew_package_installed() {
    brew list --formula | grep -Fqx "$1"
}

# Function to check if a Helm plugin is installed
is_helm_plugin_installed() {
    helm plugin list | grep -Fq "$1"
}

# Iterate over the list of Homebrew packages and install if not already installed
for package in "${brew_packages[@]}"; do
    if ! is_brew_package_installed "$package"; then
        echo "Installing $package..."
        brew install "$package"
    else
        echo "$package is already installed."
    fi
done

# Iterate over the associative array of Helm plugins and install if not already installed
for plugin in "${!helm_plugins[@]}"; do
    if ! is_helm_plugin_installed "$plugin"; then
        echo "Installing helm-$plugin plugin..."
        helm plugin install "${helm_plugins[$plugin]}"
    else
        echo "helm-$plugin plugin is already installed."
    fi
done

helmfile sync