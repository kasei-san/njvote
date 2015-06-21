require 'rubygems'
require 'twitter'
require 'yaml'
require File.join(__dir__, 'entry.rb')

credential =  YAML.load_file('config/credential.yml')
client = Twitter::REST::Client.new(credential)
search_results = client.search('#njvoteV -rt', lang: 'ja')

result = Hash.new(0)
search_results.each do |tweet|
  id = Entry.search_entry(tweet.full_text)
  if id
    result[id] += 1
  else
    puts "@#{tweet.user.screen_name}: #{tweet.full_text}"
  end
end

members = %w[マディソンおばあちゃん アンクル・ストマック船長 イビルヤモト 大男 キツネ・ウエスギ卿 カラルド ミスター・ウィルキンソン  ザザ ハワード・キングスレイ(ストライカーのヘンドリクス役のひと フィメール・ザ・ヴァーティゴ 逆噴射聡一郎 こそつき(魚が好き) シーライフのあれ ブロンディ 死と虚無の王(覚悟が必要)]
result.sort{|a,b| a[1]<=>b[1]}.each_with_index do |(k,v), i|
  puts "#{15-i}位 : #{members[k-1]} : #{v}票"
end




