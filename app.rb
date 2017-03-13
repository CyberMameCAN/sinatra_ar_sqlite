require 'bundler'
Bundler.require

module MyHandling

  class Comment < ActiveRecord::Base
  end

  class App < Sinatra::Base
    enable :logging
    
    configure :development do
      register Sinatra::Reloader

      config = YAML.load_file('config/database.yml')
      ActiveRecord::Base.establish_connection config['development']
    end
    
    configure do
      include ERB::Util   # h()用
    end
    

  	before do
      @title = "Sinatra + ActiveRecord + SQLite + haml"
      @author = "@CyberMameCAN"
    end

    after do
    end
  	
  	helpers do
    	def strong(a)
      	"<strong> #{a} </strong>"
      end
  	end
  	
  	get '/' do
      @comments = Comment.order("id desc").limit(20)

  		haml :index
  	end
  	
  	not_found do
      '404 not found'
    end
  	
    post '/new' do
      puts '通過 /new'
      Comment.create( {:body => params[:body]} )
      redirect '/'
      haml :index
    end
    
    post '/delete' do
      Comment.find(params[:id]).destroy
    end
  
  end

end
