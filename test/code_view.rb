#!/usr/bin/env ruby
#encoding: utf-8
require 'benchmark'
require 'gitlab_git_client'
require_relative '../spec/support/seed_config'
PAGE_REPO_PATH = SeedConfig::PAGE_REPO_PATH
real_time = Benchmark.realtime do
  a = ARGV.first || 200 
  ts = []
  t = []
  a.to_i.times do |i|
    ts << Thread.new(i) do
      Thread.stop
      ti = Benchmark.realtime do
        repo = Gitlab::Git::Repository.new(PAGE_REPO_PATH)
        commit = repo.commit("master")
        tree = commit.tree_rpc
        repo.empty?
        repo.branch_names
        repo.tag_names
        repo.commit("HEAD")
        repo.commits('master', 1, nil)
        Gitlab::Git::Tree.tree_contents(repo, tree.id, "", commit.id, true)
        repo.branches
        repo.tags
      end
      t << ti
    end
  end
  sleep 0.2 
  ts.each &:run
  ts.each &:join  
  puts "#{a}次线程执行的时间: #{t}"
end
puts "总共执行时间: #{real_time}"
