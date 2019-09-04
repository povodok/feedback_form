# frozen_string_literal: true

require 'sinatra'
require 'recaptcha'
require './services/feedback_service'

set :public_folder, File.dirname(__FILE__) + '/static'

Recaptcha.configure do |config|
  config.site_key = ENV['RECAPTCHA_SITE_KEY']
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY']
end

include Recaptcha::Adapters::ControllerMethods
include Recaptcha::Adapters::ViewMethods

get '/' do
  erb :feedback_form, layout: :application_layout
end

post '/send_feedback' do
  @feedback = FeedbackService.new(params)

  if @feedback.valid? && verify_recaptcha
    @feedback.send_mail
    erb :success, layout: :application_layout
  else
    erb :errors, layout: :application_layout
  end
end
