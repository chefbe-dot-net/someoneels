require 'yaml'
require 'kramdown'
require 'epath'
require 'dialect'
require 'sinatra/base'
require 'ext/hash'
require 'json'
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
    WLang::file_instantiate(tpl)
  end

  get '/' do
    lang = params["lang"] || settings.default_lang
    serve(lang, "1-home/")
  end

  get %r{^/(.+)} do
    lang = params["lang"] || settings.default_lang
    page = params[:captures].first
    serve(lang, page)
  end

  ############################################################## Error handling

  # error handling
  error do
    'Sorry, an error occurred'
  end

  ############################################################## Helpers
  module Tools

    def serve(lang, url)
      if file = PAGES/url/"index.yml"
        ctx = load_ctx(lang, file).merge(:url => "/#{url}")
        tpl = PUBLIC/:templates/"html.whtml"
        WLang::file_instantiate(tpl, ctx)
      else
        not_found
      end
    end

    def load_ctx(lang, url)
      ctx = {}
      while url.exist?
        ctx = YAML::load(url.read).merge(ctx)
        url = url.dir.parent/"index.yml"
      end
      {
        :lang => lang, 
        :environment => settings.environment,
        :pictures => (PUBLIC/"pictures").glob("*.jpg").map{|f|
          {:url => "/pictures/#{f.basename.to_s}"}
        }
      }.merge(ctx)
    end

  end
  include Tools
  
  ############################################################## Auto start

  # start the server if ruby file executed directly
  run! if app_file == $0
end

