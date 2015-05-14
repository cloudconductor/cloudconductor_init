#!/bin/sh

if ! which chef-solo ; then
  curl -L http://www.opscode.com/chef/install.sh | bash
  chef gem install berkshelf
fi


