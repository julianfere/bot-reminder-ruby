# frozen_string_literal: true

# Discord Reminder bot

require 'discordrb'
require 'working_hours'
require 'json'

bot = Discordrb::Bot.new token: ENV['TOKEN']

def check_state
  File.open('data.json', 'r') do |file|
    data = JSON.parse(file.read)
    return data['sended'] == 'true'
  end
end

def update_state(state)
  File.open('data.json', 'w') do |file|
    data = { sended: state.to_s }
    JSON.dump(data, file)
  end
end

def parse_time
  ini_hour, ini_minute = ENV['INI_TIME'].split(':').to_i
  end_hour, end_minute = ENV['END_TIME'].split(':').to_i
  { ini_hour: ini_hour, ini_minute: ini_minute, end_hour: end_hour, end_minute: end_minute }
end

bot.heartbeat do |event|
  today = Time.now
  today_argentina = Time.new(today.year,today.month,today.day,today.hour-3,today.min,today.sec)
  sended = check_state
  if today.working_day?
    ini = Time.new(today.year, today.month, today.day, 16, 30, 0)
    fin = Time.new(today.year, today.month, today.day, 16, 59, 0)
    hour_range = (ini..fin)
    if hour_range.include?(today_argentina)
      unless sended
        bot.send_message(ENV['CHANNEL'], ENV['REMINDER'])
        update_state(true)
      end
    else
      update_state(false)
    end
  else
    update_state(false)
    puts 'Hoy no'
  end
end

bot.run

