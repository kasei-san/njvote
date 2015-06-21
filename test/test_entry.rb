require 'minitest/autorun'
require File.join(__dir__, '..', 'entry.rb')

class String
  def hex2bin
    s = self
    raise "Not a valid hex string" unless(s =~ /^[\da-fA-F]+$/)
    s = '0' + s if((s.length & 1) != 0)
    s.scan(/../).map{ |b| b.to_i(16) }.pack('C*')
  end
end

class TestEntry < MiniTest::Unit::TestCase
  def test_マディソンおばあちゃん
    assert_equal Entry.search_entry('マディソンおばあちゃん'), 1
  end

  def test_中黒は無視される
    assert_equal Entry.search_entry('キツネウ・エスギ'), 5
  end

  def test_no_hits
    assert_equal Entry.search_entry('あああああ'), nil
  end
end
