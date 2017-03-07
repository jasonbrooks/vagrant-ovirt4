#!/usr/bin/env groovy
node {
  stage('Checkout') {
    checkout scm
  }

  // Run as many tests as possible in parallel.
  stage('rspec') {

    docker.build("jenkins/ruby:2.2.6").inside('-v /opt/gemcache:/opt/gemcache') {
      sh """#!/bin/bash -ex
        bundle install --path /opt/gemcache
        bundle exec rspec
      """
    }
  }

  String[] vagrantVersions = ["1.9.1", "1.9.2"]

  for (int i = 0; i < vagrantVersions.length; i++) {
   def index = i //if we tried to use i below, it would equal 4 in each job execution.
   def vagrantVersion = vagrantVersions[index]


    stage("vagrant-${vagrantVersion}") {
      docker.image("myoung34/vagrant:${vagrantVersion}").inside('-v /opt/gemcache:/opt/gemcache') {
        sh """#!/bin/bash -ex
          gem build *.gemspec
          /usr/bin/vagrant plugin install *.gem
          bundle install --path /opt/gemcache --without development plugins
          bundle exec kitchen destroy all
          rm -rf .kitchen
          bundle exec kitchen test all
        """
      }
    }
  }
    
  stage("Cleanup") {
    deleteDir()
  }
}
