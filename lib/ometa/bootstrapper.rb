D=File.new("_debug.rb","w")
module Bootstrapper
  module Annotation
    attr_accessor :source, :previous
  end

  @@count = 0

  # Evolve the bootstrap for n iterations, starting from scratch. Returns
  # a module that contains OMetaParser, OMetaOptimizer, and
  # RubyOMetaTranslator classes. The module is annotated, and provides #source
  # and #previous methods that return the original Ruby source and the
  # previous evolution's module.

  def self.evolve(files, iterations)
    result = Module.new
    iterations.times { result = to_module(files, result) }
    result
  end

  def self.to_module(files, previous=Module.new)
    name = "Dyn_#{@@count += 1}"
    ruby = to_ruby(files, previous)

    eval <<-END
        module #{name}
          extend Annotation

          #{ruby}
        end
      END

    mod = const_get(name.to_sym)
    mod.source = ruby
    mod.previous = previous

    mod
  end

  def self.to_ruby(files, previous=Module.new)
    parser     = previous.const_get('OMetaParser')
    optimizer  = previous.const_get('OMetaOptimizer')
    translator = previous.const_get('RubyOMetaTranslator')

    sources = Array(files).collect do |glob|
      Dir[glob].collect do |filename|
        source    = IO.read(filename)
D.puts source
			source = source.gsub(/\n\s*\n/,"\n,\n")

				parsed    = parser.parsewith(source, 'grammar')
D.puts parsed.inspect
				optimized = optimizer.matchwith(parsed, 'optimizeGrammar')
D.puts optimized.inspect
        ruby      = translator.matchwith(optimized, 'trans')
D.puts ruby
        # this hack remains at the moment...
        ruby.gsub! /initialize/, 'initialize_hook'

        # test its evaluable
        klass = eval(ruby)

        # that gives us its name
        name = klass.instance_variable_get(:@name)
        "#{name} = #{ruby}"
      end
    end

    sources.flatten.join("\n\n")
  end
end
