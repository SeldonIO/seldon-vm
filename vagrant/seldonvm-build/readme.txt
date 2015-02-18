Building and deploying a vagrant box has a few dependenices

    virtualbox
    vagrant
    coreos vagrant box

Getting the coreos box installed (This only needs to done once)

    Clone the github project "https://github.com/coreos/coreos-vagrant" somewhere.
    Copy the config file

        coreos-vagrant/config.rb

    to coreos-vagrant project dir.
    cd to that cloned coreos-vagrant project dir.
    Use the normal vagrant commands to get the 'coreos-stable' box installed by issusing

        vagrant up

Check that the right coreos box is installed:

    vagrant box list

    Make sure a 'coreos-stable' box is part of that list

Doing the build

    make build

Uploading and publishing to S3

    make upload_to_s3:

