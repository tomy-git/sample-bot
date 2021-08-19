class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["CHANNEL_SECRET"]
      config.channel_token = ENV["CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      # event.message['text]でLINEに送られてきたメッセージを取得
      if event.message['text'].include?("おはよう")
        respons = "おはよう！今日も元気だね"
      elsif event.message['text'].include?("こんにちは")
        respons = "もうお昼だね！ご飯食べた？"
      elsif event.message['text'].include?("こんばんは")
        respons = "もうすっかり暗くなったね"
      elsif event.message['text'].include?("好き")
        respons = "私も･･･好きだよ"
      else
        respons = event.message['text']
      end

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            # text: event.message['text']
            text: respons
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end
end
