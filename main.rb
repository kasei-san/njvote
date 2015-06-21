require 'rubygems'
require 'twitter'
require 'yaml'
require 'json'
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

result = {}

# 無効票
result[:invalid] = {}
result[:invalid][:no_member] = invalid.map do |tweet|
  {
    name: tweet.user.screen_name,
    text: tweet.full_text,
    icon: tweet.user.profile_image_url_https.to_s,
    url: "https://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}"
  }
end

# 有効票
result[:valid] = {}
result[:invalid][:multi_vote] = []
users = Hash.new(0)
entry_counter = Hash.new(0)
valid.each do |tweet|
  users[tweet.user.screen_name] += 1
  if users[tweet.user.screen_name] > 2 # 2票以上の投票
    result[:invalid][:multi_vote] << {
      name: tweet.user.screen_name,
      text: tweet.full_text,
      icon: tweet.user.profile_image_url_https.to_s,
      url: "https://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}"
    }
  else
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
end

result[:rank] = []

members = %w[マディソンおばあちゃん アンクル・ストマック船長 イビルヤモト 大男 キツネ・ウエスギ卿 カラルド ミスター・ウィルキンソン  ザザ ハワード・キングスレイ(ストライカーのヘンドリクス役のひと フィメール・ザ・ヴァーティゴ 逆噴射聡一郎 こそつき(魚が好き) シーライフのあれ ブロンディ 死と虚無の王(覚悟が必要)]
result[:rank] = entry_counter.sort{|a,b| a[1]<=>b[1]}.each_with_index.map do |(k,v), i|
  {
    rank: i,
    name: members[k-1],
    vortes: v
  }
end

File.open(File.join(__dir__, 'tmp', 'result.json'), 'w') do |file|
  JSON.dump(result, file)
end
