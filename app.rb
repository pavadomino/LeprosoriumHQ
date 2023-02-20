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
  validates :user, presence: true
  validates :content, presence: true
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

before do
  #@results = Post.all
end

get '/' do
  @results = Post.order "created_at DESC"
  erb :index
end

get '/new' do
  @post = Post.new
  erb :new
end

post '/new' do
  @post = Post.new params[:post]
  if @post.save
    erb "<h2>Your post was successfully sent</h2>"
  else
    @error = @post.errors.full_messages.first
    erb :new
  end
end

get '/details/:post_id' do
  #id = params[:post_id] # parameter from url
  @row = Post.find(params[:post_id])
  begin
    @comments = Comment.find(params[:post_id])
  rescue ActiveRecord::RecordNotFound => e
    @comments = []
  end
  erb :details
=begin
  results = @db.execute 'select * from Posts where id = ?', [post_id]
    @row = results[0]
    @comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]
    @error = params[:error]
    erb :details
=end
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
