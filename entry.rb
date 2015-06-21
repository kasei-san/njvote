class Entry
  Entries = {
    1 => [/マディソンおばあちゃん/, /マディソン/],
    2 => [/アンクルストマック船長/, /ストマック/],
    3 => [/イビルヤモト/,/イ(ビ|ヴィ)ヤモ/],
    4 => /大男/,
    5 => [/キツネウエスギ/, /ウエスギ/],
    6 => /カラルド/,
    7 => [/ミスタウィルキンソン/, /ウィルキンソン/],
    8 => /ザザ/,
    9 => [/ハワドキングスレイ/, /ハワド/],
    10 => /フィメルザ(ヴァ|バ)(テ|デ)ィゴ/,
    11 => [/逆噴射(聡一郎|総一郎)/, /逆噴射/],
    12 => /こそつき/,
    13 => /シライフ/,
    14 => /ブロンディ/,
    15 => /死と虚無の王/
  }

  def self.search_entry(str)
    # 中黒を削除 see: https://ja.wikipedia.org/wiki/%E4%B8%AD%E9%BB%92#.E7.AC.A6.E5.8F.B7.E4.BD.8D.E7.BD.AE
    str = str.gsub(/[[\u00B7][\u0387][\u2219][\u22C5][\u30FB][\uFF65]]/, '')
    # ザ・ヴァーティゴ=サン かんけいで、"ー" の表記ゆれが多いので消す
    str = str.gsub(/ー/, '')
    Entries.keys.find do |key|
      if Entries[key].is_a?(Array)
        Entries[key].find{|val| val =~ str}
      else
        Entries[key] =~ str
      end
    end
  end
end
