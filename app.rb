require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'sinatra/activerecord'
=begin
def init_db
  @db = SQLite3::Database.new 'leprosorium.db'
  @db.results_as_hash = true
end
=end
set :database, { adapter: "sqlite3", database: "leprosorium.db" }

class Post < ActiveRecord::Base
  has_many :comments, dependent: :destroy
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

before do
end

get '/' do
  @results = @db.execute 'select * from Posts order by id desc'
  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  @content = params[:content]
  @username = params[:username]

  hh = {
    :username => 'Type username',
    :content => 'Type content'
  }

  @error = hh.select { |key,value| params[key] == ''}.values.join(", ")

  if @error != ''
    return erb :new
  end

  @db.execute 'insert into Posts
  (
    username,
    content,
    created_date
  )
  values(?,?,datetime())', [@username, @content]
  redirect to '/'
end

get '/details/:post_id' do
  post_id = params[:post_id] # parameter from url
  results = @db.execute 'select * from Posts where id = ?', [post_id]
    @row = results[0]
    @comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]
    @error = params[:error]
    erb :details
end

post '/details/:post_id' do
  @post_id = params[:post_id]
  @comment = params[:comment]

  if @comment.length <= 0
    @error = "Type comment text"
    return redirect to('/details/' + @post_id)
  end

  @db.execute 'insert into Comments
  (
    content,
    created_date,
    post_id
  )
  values(?,datetime(),?)', [@comment, @post_id]

  redirect to('/details/' + @post_id)
end
