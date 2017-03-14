require 'html/proofer'

task :test do
    sh "bundle exec jekyll build"
    options = {
      :parallel => {:in_processes => 2},
      :check_html => true,
      :check_opengraph => true,
      :http_status_ignore => [0,429]
      :typhoeus => {
        :timeout => 10,
        :headers => { "User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3" }
      }
    }
    HTML::Proofer.new("./_site", options).run
end
