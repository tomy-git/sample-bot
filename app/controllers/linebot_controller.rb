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

    # callback_list = []
    # callback_list.push("こんにちは")
    # callback_list.push("おはよう")
    # callback_list.push("こんばんは")
    # callback_list.push("ありがとう")
    # callback_list.push("愛してる")


    # if callback_list.index(message)
    #   callback_message = callback_list[callback_list.index(message)]
    # else
    #   callback_message = event.message['text']
    # end

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
            # text: callback_message
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end
end
