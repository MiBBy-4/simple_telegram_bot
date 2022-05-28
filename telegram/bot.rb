require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'

Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_TOKEN']) do |bot|
  bot.listen do |message|
    puts 'HELLO WORLD'
  end
end