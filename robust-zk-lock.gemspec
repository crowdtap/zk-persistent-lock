# encoding: utf-8
$:.unshift File.expand_path("../lib", __FILE__)
$:.unshift File.expand_path("../../lib", __FILE__)

require 'zk-persistent-lock/version'

Gem::Specification.new do |s|
  s.name        = "zk-persistent-lock"
  s.version     = ZK::PersistentLock::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kareem Kouddous"]
  s.email       = ["kareeknyc@gmail.com"]
  s.homepage    = "http://github.com/crowdtap/zk-persistent-lock"
  s.summary     = "Persistent Zookeeper lock"
  s.description = "Persistent Zookeeper lock"

  s.add_dependency "zk", "~> 1.9"

  s.files        = Dir["lib/**/*"]
  s.require_path = 'lib'
  s.has_rdoc     = false
end
