require "./spec/spec_helper"
require "json"

describe 'The Word Counting App' do
  def app
    Sinatra::Application
  end

  test_string_1 = "Hello there! Hello there again...!?"
  test_string_2 = "foo FOO fOo!!! foO?"

  it "counts words correctly" do
    word_counter = WordCounter.new(test_string_1, true)
    expect(word_counter.word_count).to eq({"hello" => 2, "there" => 2, "again" => 1})
  end

  it "exclusion list should not include all the words" do
    word_counter_no_exp = WordCounter.new(test_string_1, true)
    1000.times do
      word_counter = WordCounter.new(test_string_1)
      expect(word_counter.exclude.length).to be < word_counter_no_exp.word_count.keys.length
    end
  end

  it "should have empty exclusion list when text only has one unique word" do
    100.times do
      word_counter = WordCounter.new(test_string_2)
      expect(word_counter.exclude).to eq([])
    end
  end

  it "accumulates answer keys correctly" do
    100.times { get '/' }
    expect(app.settings.counting_test_answer_key.keys.length).to eq(100)
  end

  it "returns 200 and has the right keys for get request to '/' without params" do
    get '/'
    expect(last_response).to be_ok
    parsed_response = JSON.parse(last_response.body)
    expect(parsed_response).to have_key("TEXT")
    expect(parsed_response).to have_key("EXCLUDE")
    expect(parsed_response).to have_key("ID")
  end

  it "returns 200 when the answer is correct" do
    key = app.settings.counting_test_answer_key.keys[0]
    answer = app.settings.counting_test_answer_key[key]

    params = {"TEXT" => "test", "EXCLUDE" => "[]", "ID" => key}
    answer.each do |key, value|
      params[key] = value
    end

    get '/', params
    expect(last_response).to be_ok
  end

  it "removes answer keys that have been answered" do
    count = app.settings.counting_test_answer_key.keys.length
    key = app.settings.counting_test_answer_key.keys[0]
    answer = app.settings.counting_test_answer_key[key]

    params = {"TEXT" => "test", "EXCLUDE" => "[]", "ID" => key}
    answer.each do |key, value|
      params[key] = value
    end

    get '/', params
    expect(app.settings.counting_test_answer_key.keys.length).to eq(count - 1)

    get '/', params
    expect(last_response).not_to be_ok
    expect(app.settings.counting_test_answer_key.keys.length).to eq(count - 1)
  end

  it "returns 400 when requesting without correct params" do
    get '/', "TEXT" => "test", "EXCLUDE" => "[]"
    expect(last_response).not_to be_ok

    get '/', "TEXT" => "test", "ID" => "123"
    expect(last_response).not_to be_ok

    get '/', "EXCLUDE" => "[]", "ID" => "123"
    expect(last_response).not_to be_ok
  end

  it "returns 400 when the answer is incorrect" do
    key = app.settings.counting_test_answer_key.keys[0]
    answer = app.settings.counting_test_answer_key[key]

    params = {"TEXT" => "test", "EXCLUDE" => "[]", "ID" => key}
    answer.each do |key, value|
      params[key] = value
    end

    params["test"] = 1000

    get '/', params
    expect(last_response).not_to be_ok
  end
end