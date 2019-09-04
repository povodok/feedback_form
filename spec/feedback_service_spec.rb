require 'spec_helper'
require 'rack/test'
require './services/feedback_service'

RSpec.describe 'FeedbackService' do
  include Rack::Test::Methods

  let(:invalid_params) { { name: ['John', 'Dou'], email: 2, message: nil } }
  let(:params_extra_whitespaces) { { name: '  John Dou  ', email: '  example@mail.com  ', message: (' ' * 5 + 'a' * 50) } }
  let(:invalid_instance) { FeedbackService.new(name: 'JD', email:'example@com', message: ('a'*49)) }
  let(:valid_instance) { FeedbackService.new(params_extra_whitespaces)}

  context 'create new instance' do
    it 'when params are not specified' do
      expect{ FeedbackService.new }.to raise_error(ArgumentError, 'Invalid params')
    end

    it 'when params are invalid' do
      expect{ FeedbackService.new(invalid_params) }.to raise_error(ArgumentError, 'Invalid params')
    end

    it 'params with extra whitespaces' do
      feedback = FeedbackService.new(params_extra_whitespaces)

      expect(feedback.name).to eql('John Dou')
      expect(feedback.email).to eql('example@mail.com')
      expect(feedback.message).to eql('a' * 50)
    end
  end

  context 'validate instance' do
    context 'validate invalid instance' do
      before { invalid_instance.valid? }

      it 'will be false' do
       expect(invalid_instance.valid?).to be_falsey
      end

      it 'errors' do
        expect(invalid_instance.errors[:name]).to eql('minimum 3 characters, maximum 250 characters')
        expect(invalid_instance.errors[:email]).to eql('invalid email')
        expect(invalid_instance.errors[:message]).to eql('minimum 50 characters')
      end
    end

    context 'validate valid instance' do
      before { valid_instance.valid? }

      it 'will be true' do
        expect(valid_instance.valid?).to be_truthy
      end

      it 'no errors' do
        expect(invalid_instance.errors.empty?).to be_truthy
      end
    end
  end
end
