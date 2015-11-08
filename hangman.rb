require 'yaml'

module Hangman
	class Game
		attr_accessor :word, :game_state, :misses

		MISSES_ALLOWED = 6
		DICT = "dict.txt"

		def initialize
			main
		end

		def random_word(dict)
			dict = File.readlines(DICT)
			five_to_twelve = dict.select {|w| w.length >= 5 && w.length <= 12}
			word = five_to_twelve.sample.chomp
		end

		def print_state
			puts "You have #{MISSES_ALLOWED - @misses} incorrect guesses remaining"
			puts "Current state:"
			@game_state.each {|letter|
				if letter.nil?
					print "_ "
				else
					print letter + " "
				end
			}
			puts
		end

		def user_command(input)
			if ('a'..'z').cover?(input) && input.length == 1
				make_guess(input)
			elsif input == "save"
				save_game
			else
				puts "Invalid input."
			end
		end

		def make_guess(guess)
			matches = 0
			@word.each_char.with_index {|l,i|
				if l == guess
					@game_state[i] = l
					matches += 1
				end
			}
			if matches == 0
				puts "Miss!"
				@misses += 1
			end
		end

		def new_game
			@misses = 0
			@word = random_word(@dictionary)
			@game_state = Array.new(@word.length)
		end

		def save_game
			puts "Name of saved file?"
			file_name = gets.chomp
			game_file = YAML.dump(self)
			File.open(file_name,'w+') do |file|
    		file.puts game_file
  		end
		end

		def load_game(file)
			game_file = YAML.load_file(file)
			@word = game_file.word
			@misses = game_file.misses
			@game_state = game_file.game_state
		end

		def start_game
			puts "Enter one of the following:"
			puts "1) New game"
			puts "2) Load game"
			input = gets.to_i
			if input == 1
				new_game
			elsif input == 2
				puts "Enter file name to load"
				to_load = gets.chomp
				load_game(to_load)
			else
				puts "Invalid input. Try again."
				start_game
			end
		end

		def game_over?
			if !@game_state.include?(nil)
				puts "Game over! You win."
				puts "You had #{MISSES_ALLOWED - @misses} incorrect guesses remaining"
				true
			elsif @misses > MISSES_ALLOWED
				puts "Game over! You lose."
				puts "Word = #{@word}"
				true
			else
				false
			end
		end



		def main
			#New game or load game?
			start_game
			loop do
				print_state
				break if game_over?
				puts "Make a guess or save game!"
				input = gets.chomp.downcase
				user_command(input)
				if input == "save"
					puts "See you next time!"
					break
				end
			end
		end

	end
end

