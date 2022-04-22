require 'Justicar'
require 'opal-browser'

desc "Build your website"
task :build do
  Justicar.load_preprocessors('src')
  Justicar.build_source('src')
  Justicar.build_initialize('build', 'public')
end

desc "Create a server and open your site in your browser"
task :serve do
  link = "http://localhost:8000/index.html"
  if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
    system "start #{link}"
  elsif RbConfig::CONFIG['host_os'] =~ /darwin/
    system "open #{link}"
  elsif RbConfig::CONFIG['host_os'] =~ /linux|bsd/
    system "xdg-open #{link}"
  end
  `ruby -run -ehttpd build -p8000`
end
