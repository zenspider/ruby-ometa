require "rake/testtask"

$:.unshift 'lib'
require 'ometa'

desc 'rebuild bootstrap.rb from the core ometa grammar files'
task :bootstrap do
  ruby = Bootstrapper.to_ruby(OMeta::GRAMMAR_FILES)

  open("lib/ometa/bootstrap.rb", "w") do |f|
    f.puts("# Automatically generated. DO NOT MODIFY.")
    f.puts
    f.puts(ruby)
  end
end

desc 'create new standard'
task :standard do
	commit=`git rev-parse --short HEAD`.strip
	mkdir "standards/#{commit}"
	cp "lib/ometa/bootstrap.rb","standards/#{commit}"
end


desc "basic bootstrap profiling"
task :profile do
  sh 'zenprofile -Ilib -rometa -e "Bootstrapper.to_ruby(OMeta::GRAMMAR_FILES)"'
end

desc 'Simple benchmark'
task :bench do
	require 'profile'
  # all we do is run the complete bootstrap 3 times.  this currently
  # takes about 44-48 seconds currently on my laptop (~1.4Ghz single
  # core).  they're pretty simple grammars, so ideally this'd take
  # more like a few seconds...  ok after using _x* variant functions
  # which use blocks instead of procs, and removing some other
  # unnecessary procs, we get this down to 30 s. this also has the
  # nice side effect of reducing the size of bootstrap.rb from 13kb
  # down to 10kb.  can get it down to 28 with a bit more of that. will
  # now try inlining _or() alternations to avoid the only remaining
  # need for procs. if that doesn't have an appreciable impact, (eg >
  # 5s), i'll revert it and focus on runtime.rb, which is probably
  # where the slowness is - implementation of streams, memoization,
  # the _apply function etc.  just tested it on ruby1.9, and the speed
  # was the same.
  t = Time.now
  1.times { Bootstrapper.to_ruby(OMeta::GRAMMAR_FILES) }
  puts "1 bootstraps took #{Time.now - t} seconds"
end

Rake::TestTask.new do |t|
  t.libs = %w(test lib)
  t.test_files = FileList["test/test_*.rb"]
  t.verbose = true
end

task :default => :test
