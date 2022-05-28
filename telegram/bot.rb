require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'

Telegram::Bot::Client.run('5497432561:AAGNlDX-s8qfomIAKs4jai7pJdKncSeMN0w') do |bot|
    bot.listen do |message|
        if !User.exists?(telegram_id: message.chat.id)
            user = User.create(telegram_id: message.from.id, name: message.from.first_name)
        else
            user = User.find_by(telegram_id: message.chat.id)
        end

        case user.step
        when 'add'
            user.bots.create(username: message.text)
            user.step = 'description'
            user.save
        when 'description'
            bot.api.send_message(chat_id: message.chat.id, text: 'Send me description')
            new_bot = user.bots.last
            new_bot.description = message.text
            new_bot.save
            user.step = nil
            user.save
        when 'delete'
            if user.bots.map { |user_bot| user_bot.username }.include?(message.text)
                Bot.find_by(username: message.text).destroy
                bot.api.send_message(chat_id: message.chat.id, text:'Bot destroyed')
            else
                bot.api.send_message(chat_id: message.chat.id, text:'Uncorrect bot name')
            end
            user.step = nil
            user.save
        when 'search'
            bots = Bot.where('description LIKE ?', "%#{message.text}%")
            bot.api.send_message(chat_id: message.chat.id, text:'Search results:')
            if !bots.size.zero?
                bots.each do |found_bot|
                    bot.api.send_message(chat_id: message.chat.id, text: "#{found_bot.username}: #{found_bot.description}")
                end
            else
                bot.api.send_message(chat_id: message.chat.id, text:'Absolutly nothing')
            end
            user.step = nil
            user.save
        end
                

        case message.text
        when '/add'
            user.step = 'add'
            user.save
            bot.api.send_message(chat_id: message.chat.id, text:'Send me bot username')
        when '/delete'
            user.step = 'delete'
            user.save
            user_bots = user.bots.map { |user_bot| user_bot.username }
            markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: user_bots)
            bot.api.send_message(chat_id: message.chat.id, text:'Pick bot to delete', reply_markup: markup)
        when '/search'
            user.step = 'search'
            user.save
            bot.api.send_message(chat_id: message.chat.id, text:'Type something to search')
        end
    end
end