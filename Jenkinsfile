#!/usr/bin/env groovy
node {
  stage('Checkout') {
    checkout scm
  }

  // Run as many tests as possible in parallel.
  stage('Test') {

    String[] vagrantVersions = ["1.9.1", "1.9.2"]

    def buildJobs = [:]

    buildJobs["rspec"] = {
      docker.build("jenkins/ruby:2.2.6").inside('-v /opt/gemcache:/opt/gemcache') {
        sh """#!/bin/bash -ex
          bundle install --path /opt/gemcache
          bundle exec rspec
        """
      }
    }
    
    for (int i = 0; i < vagrantVersions.length; i++) {
      def index = i //if we tried to use i below, it would equal 4 in each job execution.
      def vagrantVersion = vagrantVersions[index]

      buildJobs["vagrant-${vagrantVersion}"] = {

        docker.image("myoung34/vagrant:${vagrantVersion}").inside('-v /opt/gemcache:/opt/gemcache') {
          sh """#!/bin/bash -ex
            bundle install --path /opt/gemcache
            gem build *.gemspec
            /usr/bin/vagrant plugin install *.gem
            sleep \$(shuf -i 0-5 -n 1) 
            bundle exec kitchen test ^[^singleton-].*
          """
        }

      }
    }
    
    parallel( buildJobs )
  }

  // Some tests cant be run in parallel, such as tests with static IPs. Run those individually.
  // These are defined by having `singleton-` prefix in .kitchen.yml suites
  for (int i = 0; i < vagrantVersions.length; i++) {

    stage("vagrant-${vagrantVersion} Singleton") {
      docker.image("myoung34/vagrant:${vagrantVersion}").inside('-v /opt/gemcache:/opt/gemcache') {
        sh """#!/bin/bash -ex
          bundle install --path /opt/gemcache
          gem build *.gemspec
          /usr/bin/vagrant plugin install *.gem
          sleep \$(shuf -i 0-5 -n 1) 
          bundle exec kitchen test ^singleton-.*
        """
      }
    }
  }

  stage("Cleanup") {
    deleteDir()
  }
}
