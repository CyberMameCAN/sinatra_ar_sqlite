# sina_active_record
SinatraとActiveRecord、SQLite、Haml等を使ってWebアプリの雛形を作ってみました。

## GitHub
今回作成したのはGitHubに上げてあります。
-[]()

## Install
### Gemfileを作成
```
# frozen_string_literal: true
source "https://rubygems.org"

gem "sinatra"
gem 'sinatra-contrib'
gem 'activerecord'
gem 'sinatra-activerecord'
gem 'rake'

gem 'haml'
gem 'sass'
gem 'coffee-script'

group :production do
  #gem 'mysql'
end

group :development, :test do
  gem "thin"
  gem 'rack-test'
  gem 'sqlite3'
  gem 'tux'
end
```

### インストール
```
$ bundle install --path vendor/bundle 
```

## DB関係設定(ActiveRecord + SQLite)
### Rakefileの作成

```
$ emacs Rakefile

require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

require './app'
```

### コマンドの確認
```
$ bundle exec rake -T

rake db:create              # Creates the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (u...
rake db:create_migration    # Create a migration (parameters: NAME, VERSION)
rake db:drop                # Drops the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (use...
rake db:environment:set     # Set the environment value for the database
rake db:fixtures:load       # Loads fixtures into the current environment's database
rake db:migrate             # Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog)
rake db:migrate:status      # Display status of migrations
rake db:rollback            # Rolls the schema back to the previous version (specify steps w/ STEP=n)
rake db:schema:cache:clear  # Clears a db/schema_cache.dump file
rake db:schema:cache:dump   # Creates a db/schema_cache.dump file
rake db:schema:dump         # Creates a db/schema.rb file that is portable against any DB supported by Active Record
rake db:schema:load         # Loads a schema.rb file into the database
rake db:seed                # Loads the seed data from db/seeds.rb
rake db:setup               # Creates the database, loads the schema, and initializes with the seed data (use db:reset t...
rake db:structure:dump      # Dumps the database structure to db/structure.sql
rake db:structure:load      # Recreates the databases from the structure.sql file
rake db:version             # Retrieves the current schema version number
```

### マイグレーションファイルの作成
```
$ bundle exec rake db:create_migration NAME=create_comments VERSION=001

db/migrate/001_create_comments.rb
```

001_comments.rbを編集してテーブルを完成させる。
```
$ emacs db/migrate/001_comments.rb

class Comments < ActiveRecord::Migration[5.0]
  def change
+    create_table :comments do |t|
+      t.text :body
+      t.timestamps
+    end
  end
end
```

### DBの作成
```
$ bundle exec rake db:migrate

== 1 Comments: migrating ======================================================
-- create_table(:comments)
   -> 0.0046s
== 1 Comments: migrated (0.0047s) =============================================
```
db/bbs.dbというDBファイルが出来ます。

### 確認
```
$ sqlite3 db/bbs.db
SQLite version 3.13.0 2016-05-18 10:57:30
Enter ".help" for usage hints.
sqlite> .schema
CREATE TABLE "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "comments" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "body" text, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
sqlite> .exit
```


## Sinatra
### app.rb
```
$ emacs app.rb

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
      Comment.create( {:body => params[:body]} )
      redirect '/'

      haml :index
    end
  
  end

end
```

### config.ru
```
$ emacs config.ru

require './app.rb'
run MyHandling::App
```

#### ちなみに
<b>class App < Sinatra::Base</b>を使わない場合のconfig.ruは以下のような感じになるようです。
```
require './app.rb'
run Sinatra::Application
```

## Haml
ブラウザで表示の部分です。

```
$ emacs layout.haml

!!! 5
%html
  <!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
  <!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
  <!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
  <!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
  %head
    %meta{ charset: 'utf-8' }
    %meta{:content =>"IE=edge", :name => "X-UA-Compatible"}
    %title #{@title} | #{@description}
    %meta{:content => "Sinatra", :name => "keywords"}
    %meta{:content => "#{@description}", :name => "description"}
    %link{:href => "/css/normalize.css", :media => "all", :type => "text/css", :rel => "stylesheet"}
    %script{:src => "/js/modernizr-2.6.2.min.js"}
    <!--[if lt IE 9]>
    %script{:src => "/js/respond.min.js"}
    <![endif]-->

  %body
    .container
      %h2 Enjoy Sinatra life to the full.
      %span<>
        #{@subtitle2} Created by
        %a{:href => "https://twitter.com/CyberMameCAN"} #{@author}

      = yield
      
    %script{:src => "/js/jquery.min.js"}
```

```
$ emacs index.haml

%h2 BBS
%ul
  - @comments.each do |comment|
    %li{:data_id => "#{comment.id}"}<>
      - es = h comment.body
      #{comment.created_at}
      %b #{es}

%h3 Add New
%form{:method => "post", :action => "/new"}
  %input{:type => "text", :name => "body"}
  %input{:type => "submit", :value => "post"}   
```


## Starting

```
$ bundle exec rackup -p 8088
```
ブラウザでアクセスする。
http://localhost:8088

## 今後の課題として
- scssを使ってデザインしたい。
- coffee scriptも覚えたい。

## 参考
-[Sinatra + ActiveRecord + sqlite3覚書](http://ataru-kodaka.hatenablog.com/entry/2014/07/22/212526)
