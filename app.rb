require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'sinatra/activerecord'

set :database, { adapter: "sqlite3", database: "leprosorium.db" }

class Post < ActiveRecord::Base
  has_many :comments, dependent: :destroy
  validates :user, presence: true
  validates :content, presence: true
end

class Comment < ActiveRecord::Base
  belongs_to :post
  validates :content, presence: true
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
  #@id = params[:post_id] # parameter from url
  @row = Post.find(params[:post_id])
  begin
    @comments = @row.comments.all #.where("post_id = ?", params[:post_id])
  rescue ActiveRecord::RecordNotFound => e
    @comments = []
  end
  erb :details
end

post '/details/:post_id' do
  @row = Post.find(params[:post_id])
  @comment = @row.comments.new
  @comment.content = params[:comment]
  if @comment.save
    redirect to('/details/' + params[:post_id])
  else
    @error = @comment.errors.full_messages.first
    begin
      @comments = @row.comments.all # # # .where("post_id = ?", params[:post_id])
    rescue ActiveRecord::RecordNotFound => e
      @comments = []
    end
    erb :details
  end
end
