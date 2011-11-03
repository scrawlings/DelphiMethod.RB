require "bundler/setup"
require 'sinatra'
require './surveys'
require './survey'

def admin?(user_name) 
  user_name == "administrator"
end

def destination(user_name)
  admin?(user_name) ? "./originals" : "./surveys"
end

get '/' do
  erb :index
end

get '/login' do
  redirect to("/delphi/#{params[:username]}")
end

get '/new_survey' do
  Survey.new("./surveys", params[:survey], "./originals").seed
  redirect to("/delphi/administrator")
end

get '/delphi/:username' do
  surveys = Surveys.new("./surveys", params[:username], "./originals")
  erb :user_select_survey, 
      :locals => {
        :available_surveys => surveys.available_surveys,
        :user_surveys => surveys.user_surveys,
        :username => params[:username],
        :admin => admin?(params[:username])
      }
end

get '/delphi/:username/:survey' do
  erb :user_survey, 
      :locals => {
        :survey => Submission.new(destination(params[:username]), params[:username], params[:survey], "./originals").load_survey,
        :username => params[:username],
        :admin => admin?(params[:username])
      }
end

get '/delphi/administrator/:survey/consolidate' do
  erb :user_survey, 
      :locals => {
        :survey => Survey.new("./surveys", params[:survey], "./originals").consolidate.export_synthesis,
        :username => "administrator",
        :admin => true
      }
end

get '/delphi/:username/:survey/reset' do
  Submission.new(destination(params[:username]), params[:username], params[:survey], "./originals").reset!
  redirect to("/delphi//#{params[:username]}/#{params[:survey]}")
end

get '/delphi/administrator/:survey/distribute' do
  Survey.new("./surveys", params[:survey], "./originals").distribute!
  redirect to("/delphi/administrator")
end

post '/delphi/:username/:survey' do
  Submission.new(destination(params[:username]), params[:username], params[:survey], "./originals").update_survey request.body.read
  "OK"
end