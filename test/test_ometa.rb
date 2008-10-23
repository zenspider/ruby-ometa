require 'ometa'
require 'test/unit'
require 'pp'

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
    ast = OMetaParser.parsewith(grammar, 'grammar')
    ruby = RubyOMetaTranslator.matchwith(ast, 'trans')
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

class Calc < Ometa::Grammar('./doc/grammars/calc.ometa')
  def self.calc str
    matchAllwith str, 'expr'
  end
end

class TestCalc < Test::Unit::TestCase
  def test_basic_calc
    n = 20
    expr = (1..n).to_a.join("+")
    expected = (n**2+n)/2
    assert_equal expected, Calc.calc(expr)
  end

  def test_basic_calc_bad
    n = 20
    expr = "*" + (1..n).to_a.join("+")
    expected = (n**2+n)/2

    assert_raises Fail do
      Calc.calc(expr)
    end
  end
end

__END__

class JSParser < Ometa::Grammar('./doc/grammars/js_parser.ometa')

  KEYWORDS = %w(break case catch continue default delete do else
    finally for function if in instanceof new return switch this throw
    try typeof var void while with ometa)

  KEYWORDS_HASH = {}
  KEYWORDS.each do |k|
    KEYWORDS_HASH[k] = true
  end

  def self._isKeyword k
    KEYWORDS_HASH[k.to_s]
  end
end

# p JSParser.parsewith("  x  += 1;\n", 'expr')

