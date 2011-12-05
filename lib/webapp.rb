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
    WLang::file_instantiate(tpl)
  end

  get '/' do
    lang = params["lang"] || settings.default_lang
    page = "home"
    serve(lang, page)
  end

  get '/:page' do
    lang = params["lang"] || settings.default_lang
    page = params[:page]
    serve(lang, page)
  end
  
  ############################################################## Error handling

  # error handling
  error do
    'Sorry, an error occurred'
  end

  ############################################################## Helpers
  module Tools

    # Structure as a relation
    def structure
      PAGES.glob('*').
        select{|f| f.directory?}.
        sort{|k1,k2| k1.basename.to_s <=> k2.basename.to_s}.
        map do |f| 
          /^(\d+)\-(.*)$/ =~ f.basename.to_s
          id, pos = $2, $1
          { :id      => id,
            :pos     => pos,
            :path    => f,
            :yml     => f/"index.yml",
            :bullets => "images/#{pos}-bullets.gif",
            :sticker => "pages/#{f.basename.to_s}/sticker.gif" }
        end
    end

    # Loads info for a given language
    def info(lang)
      YAML::load((PAGES/"info.yml").read)[lang]
    end

    def serve(lang, pageid)
      if page = structure.find{|s| s[:id] == pageid}
        ctx = { 
          :lang        => lang,
          :page        => page,
          :info        => info(lang),
          :text        => kramdown(YAML::load(page[:yml].read)[lang]),
          :environment => settings.environment, 
          :structure   => structure}
        tpl = PUBLIC/:templates/"html.whtml"
        WLang::file_instantiate(tpl, ctx)
      else
        not_found
      end
    end

    def kramdown(text)
      Kramdown::Document.new(text).to_html
    end

  end
  include Tools
  
  ############################################################## Auto start

  # start the server if ruby file executed directly
  run! if app_file == $0
end

