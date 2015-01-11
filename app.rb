require 'sinatra'
require "sinatra/reloader" if development?

set :counting_test_answer_key, {}
set :port, 8000

get '/' do
	if params.keys.length == 0
	  files = %w(texts/0 texts/1 texts/2 texts/3 texts/4 texts/5)

	  text_file = files.sample
	  source_text = File.read(text_file).strip.downcase.gsub(/[^a-z\s]/, "")
	  text_array = source_text.split

	  word_count = Hash.new(0)
	  text_array.each do |text|
	  	word_count[text] += 1
	  end

	  word_num = word_count.keys.length
	  if word_num == 1
	  	exclude_num = 0
	  else
	  	exclude_num = rand(word_num - 1) + 1
	  end

	  exclude = []
	  exclude_num.times do |i|
	  	word = word_count.keys[rand(word_count.keys.length)]
	  	exclude << word
	  	word_count.delete(word)
	  end

	  id = Random.new_seed
	  while settings.counting_test_answer_key[id]
	  	id = Random.new_seed
	  end

	  settings.counting_test_answer_key[id] = word_count

	  # p settings.counting_test_answer_key

	  erb :"get.json", locals: { source_text: source_text, exclude: exclude, id: id }
	else
		["text", "exclude", "id"].each do |key|
			unless params.keys.include?(key)
				status 400
			end
		end
		p params["text"]
	  p params["exclude"]
	  p params["id"]
	  unless settings.counting_test_answer_key.keys.include?(params["id"])
	  	status 400
	  end
	end
end