require 'sinatra'
require "sinatra/reloader" if development?

require 'literate_randomizer'

set :counting_test_answer_key, {}
set :port, 8000

get '/' do
	if params.keys.length == 0
	  mode = rand(3)

	  if mode == 0
	  	source_text = LiterateRandomizer.word
	  elsif mode == 1
	  	source_text = LiterateRandomizer.sentence
	  else
	  	source_text = LiterateRandomizer.paragraph
	  end

	  word_counter = WordCounter.new(source_text)

	  id = Random.new_seed
	  while settings.counting_test_answer_key[id]
	  	id = Random.new_seed
	  end

	  settings.counting_test_answer_key[id] = word_counter.word_count

	  erb :"get.json", locals: { source_text: source_text, exclude: word_counter.exclude, id: id }
	else
		["TEXT", "EXCLUDE", "ID"].each do |key|
			unless params.keys.include?(key)
				return status 400
			end
		end

	  unless settings.counting_test_answer_key.keys.include?(params["ID"].to_i)
	  	return status 400
	  end

	  answer_key = settings.counting_test_answer_key[params["ID"].to_i]
	  settings.counting_test_answer_key.delete(params["ID"].to_i)

	  unless params.keys.length - 3 == answer_key.keys.length
	  	return status 400
	  end

	  answer_key.each do |key, val|
	  	unless params[key].to_i == val
	  		return status 400
	  	end
	  end

	  status 200
	end
end

class WordCounter
	attr_reader :word_count, :exclude

	def initialize(source_text, no_exclusion = false)
		text_array = source_text.downcase.gsub(/[^a-z\s]/, "").split

		@word_count = Hash.new(0)
		@exclude = []

		self.count_word(text_array)
		self.excluder unless no_exclusion
	end

	def count_word(text_array)
	  text_array.each do |text|
	  	@word_count[text] += 1
	  end
	end

	def excluder
		word_num = @word_count.keys.length
	  if word_num == 1
	  	exclude_num = 0
	  else
	  	exclude_num = rand(word_num - 1) + 1
	  end

	  exclude_num.times do |i|
	  	word = @word_count.keys[rand(@word_count.keys.length)]
	  	@exclude << word
	  	@word_count.delete(word)
	  end
	end
end