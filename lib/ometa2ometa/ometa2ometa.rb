$:.unshift("lib")
require 'ometa'

# class OMeta
#   @@tally = Hash.new 0

#   alias :old_apply :_apply
#   at_exit {
#     at_exit {
#       pp @@tally.sort_by { |k,v| -v }.first(20)
#     }
#   }

#   def _apply rule
#     @@tally[caller.first] += 1
#     old_apply rule
#   end
# end

# later on the idea is to add a Ometa::Grammar function or something
# similar to wrap up the process of creating a ruby class object from
# an ometa grammar file.
#
# as an example (this is missing the optimization pass):
class Ometa
  def self.Grammar(filename)
    grammar = File.read(filename)
		grammar = grammar.gsub(/\n\s*\n/,"\n,\n")
		lines = grammar.split("\n")
		if /^#standard *(.*)$/.match(lines[0])
			$std = $1.strip
			puts $std
			
			require "standards/#{$std}/bootstrap.rb"
			
			lines.shift
			grammar =lines *"\n"
		end

		puts grammar
    parsed = OMetaParser.parsewith(grammar, 'grammar')
		optimized = OMetaOptimizer.matchwith(parsed, 'optimizeGrammar')
		$parsed=optimized
		ruby = RubyOMetaTranslator.matchwith(optimized, 'trans')
    #ruby = File.read('_debug.rb')
    begin
      open('_debug.rb', 'w') { |f| f << ruby }
      eval ruby
    rescue SyntaxError
      puts '* error compiling grammar'
      puts '* ast:'
      require 'pp'
      pp ast
      puts '* ruby:'
      puts ruby
      open('_debug.rb', 'w') { |f| f << ruby }
      raise
    end
  end
end

class Parser < Ometa::Grammar('ometa/ometa2ometa.ometa')
  def self.parse str
    matchwith str, 'trans'
  end
end
grammar=Parser.parse($parsed)
puts grammar 
parsed = OMetaParser.parsewith(grammar, 'grammar')
parsed = OMetaOptimizer.matchwith(parsed, 'optimizeGrammar')

puts parsed.inspect
puts $parsed.inspect
puts parsed ==$parsed
[["And", ["App", "anything"], ["App", "anything"]] ,["Grammar", "RubyOMeta2OMeta", "OMeta", ["Rule", "trans", ["t", "ans"], ["Or", ["And", ["And", ["Form", ["Or", ["And", ["Set", "t", ["App", "anything"]], ["Set", "ans", ["App", "apply", "t"]]]]]]]]]] ].each{|s| puts Parser.parse(s).inspect}

