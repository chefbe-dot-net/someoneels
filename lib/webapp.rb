require 'yaml'
require 'kramdown'
require 'epath'
require 'dialect'
require 'sinatra/base'
class WebApp < Sinatra::Base

  # PUBLIC of the web application
  ROOT    = Path(__FILE__).dir.dir
  PUBLIC  = ROOT/:public
  PAGES   = PUBLIC/:pages

  ############################################################## Configuration
  # Serve public pages from public
  set :public_folder, PUBLIC

  # A few configuration options for logging and errors
  set :logging, true
  set :raise_errors, true
  set :show_exceptions, false

  # Domain specific configuration
  set :default_lang, "nl"

  ############################################################## Routes

  get '/sitemap.xml' do
    content_type "application/xml"
    tpl = PUBLIC/:templates/"sitemap.whtml"
    files = (PUBLIC/:pages).glob("**/*.md").reject{|f|
      ["menu.md", "header.md"].include?(f.basename.to_s)
    }.map{|f| f.extend(Path2URL)}
    WLang::file_instantiate(tpl, :files => files)
  end

  get '/' do
    lang = params["lang"] || settings.default_lang
    info   = info(lang)
    wlang(:lang => lang, :info => info, :page => "home")
  end

  get '/:page' do
    lang = params["lang"] || settings.default_lang
    info   = info(lang)
    wlang(:lang => lang, :info => info, :page => params[:page])
  end
  
  ############################################################## Error handling

  # error handling
  error do
    'Sorry, an error occurred'
  end

  ############################################################## Helpers
  module Tools

    def structure
      PAGES.glob('*').
        select{|f| f.directory?}.
        sort{|k1,k2| k1.basename.to_s <=> k2.basename.to_s}.
        map do |f| 
          { :id   => /^\d+\-(.*)$/.match(f.basename.to_s)[1],
            :path => f,
            :yml  => f/"index.yml" }
        end
    end

    def info(lang)
      mtimef = if settings.environment == :production
        ROOT/"tmp"/"restart.txt" 
      else 
        ROOT/"Gemfile.lock"
      end
      YAML::load((PAGES/"info.yml").read)[lang].merge(
        "lastupdate" => mtimef.mtime.strftime("%Y-%m-%d")
      )
    end

    def wlang(ctx)
      page = structure.find{|s| s[:id] == ctx[:page]}
      return not_found unless page
      yml  = YAML::load(page[:yml].read)
      text = kramdown(yml[ctx[:lang]])
      ctx = ctx.merge(:environment => settings.environment)
      ctx = ctx.merge(:text => text)
      tpl = PUBLIC/:templates/"html.whtml"
      WLang::file_instantiate(tpl, ctx.merge(:structure => structure))
    end

    def kramdown(text)
      Kramdown::Document.new(text).to_html
    end

  end
  include Tools
  
  module Path2URL
    def to_url
      if basename.to_s == "index.md"
        (to_s =~ /pages\/(.*\/)index\.md$/) && $1
      else
        (to_s =~ /pages\/(.*)\.md$/) && $1
      end
    end
  end
  
  ############################################################## Auto start

  # start the server if ruby file executed directly
  run! if app_file == $0
end

