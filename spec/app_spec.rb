ENV['RACK_ENV'] = 'test'

require 'spec_helper'
require 'rack/test'
require './app'

RSpec.describe 'App' do
  include Rack::Test::Methods

  before do
    allow_any_instance_of(FeedbackService).to receive(:send_mail).and_return(true)
  end

  let(:valid_params) { { name: 'name', email: 'example@mail.com', message: ('a' * 50) } }
  let(:invalid_params) { { name: '', email: 'invalid_email', message: ('a' * 49) } }
  let(:invalid_email_params) { { name: 'name', email: 'invalid_email', message: ('a' * 50) } }

  def app
    Sinatra::Application
  end

  it '/ action' do
    get '/'

    expect(last_response).to be_ok
  end

  context '/send_mail action' do
    it 'with valid params' do
      post '/send_feedback', valid_params

      expect(last_response.body).to include('Your feedback was sent.')
    end

    it 'with all invalid params' do
      post '/send_feedback', invalid_params

      expect(last_response.body).to include('minimum 3 characters, maximum 250 characters')
      expect(last_response.body).to include('invalid email')
      expect(last_response.body).to include('minimum 50 characters')
    end

    it 'with invalid email params' do
      post '/send_feedback', invalid_email_params

      expect(last_response.body).not_to include('minimum 3 characters, maximum 250 characters')
      expect(last_response.body).to include('invalid email')
      expect(last_response.body).not_to include('minimum 50 characters')
    end

    it 'with invalid verifying recaptcha' do
      Recaptcha.configuration.skip_verify_env.delete('test')

      Recaptcha.configure do |config|
        config.site_key = '6LceubYUAAAAAPROHJHlzX0oFV-5HKt2Ksh87SAT'
        config.secret_key = '6LceubYUAAAAAAfvvkhWwmMtI2EkgJxGh2hZvxiK'
      end

      post '/send_feedback', valid_params

      expect(last_response.body).not_to include('minimum 3 characters, maximum 250 characters')
      expect(last_response.body).not_to include('invalid email')
      expect(last_response.body).not_to include('minimum 50 characters')
    end
  end
end
