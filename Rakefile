$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

desc %q{Run the website locally}
task :development do
  exec "bundle exec ruby scripts/development.rb"
end

desc %q{Run all client tests}
task :test do
  exec "bundle exec ruby -Ilib -Itest test/runall.rb"
end
