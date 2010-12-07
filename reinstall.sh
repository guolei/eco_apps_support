#/bin/bash 
sudo gem uninstall eco_apps_support
gem build eco_apps_support.gemspec
gem install --no-rdoc --no-ri eco_apps_support-0.2.0.gem
