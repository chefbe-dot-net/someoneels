puts "Loading dependencies..."
require 'bundler'
Bundler.setup(:runtime)

t1 = Thread.new do 
  require 'epath'
  Dir.chdir(Path(__FILE__).dir.dir) do
    puts "Starting the web server..."
    pid = spawn('rake cli:run')
    Process.wait(pid)
  end
end
sleep(1)

Thread.new do 
  try, max = 0, 200
  begin
    puts "Attempting to connect to the web server..."
    require 'http'
    Http.head "http://127.0.0.1:9292"
  rescue 
    sleep(0.5)
    try += 1
    retry unless try > max
  end
  if try < max
    puts "Got it!!"
    require 'launchy'
    Launchy.open("http://127.0.0.1:9292")
  else
    puts "Server not found, sorry."
  end
end
t1.join