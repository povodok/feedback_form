# frozen_string_literal: true

require 'pony'

class FeedbackService
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i.freeze
  EMAIL_OPTIONS = {
                    address:               'smtp.gmail.com',
                    port:                  '587',
                    enable_starttls_auto:  true,
                    user_name:             ENV['EMAIL_USER'],
                    password:              ENV['EMAIL_PASSWORD'],
                    authentication:        :plain,
                    domain:                'localhost.localdomain'
                  }.freeze

  attr_reader :name, :email, :message, :file, :errors

  def initialize(params = {})
    unless params[:name].is_a?(String) || params[:name].is_a?(String) || params[:name].is_a?(String)
     raise ArgumentError, 'Invalid params'
    end

    @name = params[:name].strip
    @email = params[:email].strip
    @message = params[:message].strip
    @file = params[:attached_file]
    @errors = {}
  end

  def valid?
    errors[:name] = 'minimum 3 characters, maximum 250 characters' if @name.length < 3 || @name.length > 250
    errors[:email] = 'invalid email' unless @email =~ VALID_EMAIL_REGEX
    errors[:message] = 'minimum 50 characters' if @message.length < 50

    errors.empty?
  end

  def send_mail
    Pony.override_options = { attachments: { @file[:filename] => File.read(@file[:tempfile], binmode: true) } } if @file

    Pony.mail(to:          'example@mail.com',
              from:        @email,
              body:        "My name is #{@name}. #{@message}",
              via:         :smtp,
              via_options: EMAIL_OPTIONS)
  end
end
