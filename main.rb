require 'rubygems'
require 'twitter'
require 'yaml'
require File.join(__dir__, 'entry.rb')

credential =  YAML.load_file('config/credential.yml')
client = Twitter::REST::Client.new(credential)
search_results = client.search('#njvoteV -rt', lang: 'ja')

result = Hash.new([])

# オフィシャルをフィルタリング
search_results = search_results.reject do |tweet|
  tweet.user.screen_name == 'NJSLYR'
end

# 有効票をフィルタリング
valid, invalid = search_results.partition do |tweet|
  Entry.search_entry(tweet.full_text)
end

result = Hash.new([])

# 無効票
result[:invalid] = invalid.map do |tweet|
  {
    name: tweet.user.screen_name,
    text: tweet.full_text,
    icon: tweet.user.profile_image_url_https.to_s,
    url: "https://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}"
  }
end

# 有効票
users = Hash.new(0)
entry_counter = Hash.new(0)
valid.each do |tweet|

  users[tweet.user.screen_name] += 1
  if users[tweet.user.screen_name] > 2
    result[:invald] << {
      name: tweet.user.screen_name,
      text: tweet.full_text,
      icon: tweet.user.profile_image_url_https.to_s,
      url: "https://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}"
    }
  end

  entry_id = Entry.search_entry(tweet.full_text)
  entry_counter[entry_id] += 1
  result[:valid][entry_id] ||= []
  result[:valid][entry_id] << {
    name: tweet.user.screen_name,
    text: tweet.full_text,
    icon: tweet.user.profile_image_url_https.to_s,
    url: "https://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}"
  }
end

members = %w[マディソンおばあちゃん アンクル・ストマック船長 イビルヤモト 大男 キツネ・ウエスギ卿 カラルド ミスター・ウィルキンソン  ザザ ハワード・キングスレイ(ストライカーのヘンドリクス役のひと フィメール・ザ・ヴァーティゴ 逆噴射聡一郎 こそつき(魚が好き) シーライフのあれ ブロンディ 死と虚無の王(覚悟が必要)]
entry_counter.sort{|a,b| a[1]<=>b[1]}.each_with_index do |(k,v), i|
  puts "#{15-i}位 : #{members[k-1]} : #{v}票"
end

puts "==========無効票=========="
result[:invalid].each do |tweet|
  puts tweet.inspect
end
