# Install dependencies
brew install helm helmfile
helm plugin install https://github.com/databus23/helm-diff

helmfile sync