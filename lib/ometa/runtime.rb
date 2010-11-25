UNDEFINED = Object.new

class Fail < StandardError
  attr_accessor :matcher
  attr_accessor :failPos
end

class Klass
	attr_accessor :name,:args
	def initialize(nam,arg)
		@name=nam;@args=arg
	end
end

class Character < String
  undef_method :each if ''.respond_to?(:each)

  class StringWrapper
    include Enumerable

    def initialize str
      @str = str
    end

    def length
      @str.length
    end

    def [] i
      Character.new @str[i..i]
    end

    def each
      length.times { |i| yield self[i] }
    end

    def to_s
      @str.to_s
    end

    def inspect
      @str.inspect
    end
  end

  # make them display with single quotes
  def inspect
    "'" + super[1..-2] + "'"
  end
end

class Stream
  attr_reader :src,:stream
	def copy
    self
  end
end

class ReadStream < Stream
  attr_reader :pos
  def initialize obj
    if String === obj
      #         puts 'note, wrapping string in a string wrapper'
      obj = Character::StringWrapper.new obj
    end
    @src = obj
    @pos = 0
  end

  def eof?
		return true unless @src.respond_to? :length
    @pos >= @src.length
  end

  def next
    @pos += 1
    @src[@pos-1]
  end
end

class LazyStream < Stream
  def self.new head, tail, stream
    if stream and stream.eof?
      LazyInputStreamEnd.new stream
    else
      LazyInputStream.new head, tail, stream
    end
  end
end

class LazyInputStream < Stream
  attr_reader :memo
  def initialize head=UNDEFINED, tail=UNDEFINED, stream=nil
    @head = head
    @tail = tail
    @stream = stream
    @memo = {}
  end

  def head
    if @head == UNDEFINED
      @head = @stream.next
    end
    @head
  end

  def tail
    if @tail == UNDEFINED
      @tail = LazyStream.new UNDEFINED, UNDEFINED, @stream
    end
    @tail
  end

  # also interesting, due to backtracking, would possibly be to store
  # @stream.pos in initialize, which would presumably be the actual stream
  # pos at which any potential error occurred.
  def realPos
    @stream.pos
  end
end

class LazyInputStreamEnd < Stream
  attr_reader :memo

  def initialize stream
    @stream = stream
    @memo = {}
  end

  def realPos
    @stream.pos
  end

  def head
    #throw :fail, true #raise Fail #EOFError
    raise Fail
  end

  def tail
    raise NoMethodError
  end
end

class LazyStreamWrapper < Stream
  attr_reader :memo, :stream
  def initialize stream
    @stream = stream
    @memo = {}
  end

  def realPos
    @stream.pos
  end

  def head
    @stream.head
  end

  def tail
    self.class.new @stream.tail
  end
end

class LeftRecursion
  attr_accessor :detected
end

#// the OMeta "class" and basic functionality
#// TODO: make apply support indirect left recursion

class OMetaCore
  attr_reader :input

  def _apply(rule)
    #p rule
    memoRec = @input.memo[rule]
		if not memoRec then
			oldInput = @input
			lr = LeftRecursion.new
			@input.memo[rule] = memoRec = lr

			# should these be copies too?
			@input.memo[rule] = memoRec = [send(rule),  @input]

			if lr.detected
				sentinel = @input
				while true
					begin
						@input = oldInput
						ans = send rule
						raise Fail if @input == sentinel
						oldInput.memo[rule] = memoRec = [ ans,  @input]
					rescue Fail
						break
					end
				end
			end
		elsif LeftRecursion === memoRec
			memoRec.detected = true
      raise Fail
    end
    ans,@input = *memoRec
    return ans
  end

  def _applyWithArgs(rule, *args)
		oldInput = @input
		args.reverse_each do |arg|
			@input = LazyStream.new arg, @input, nil
		end
		send rule

  end

  def _superApplyWithArgs(rule, *args)
    #for (var idx = arguments.length - 1; idx > 1; idx--)
    #  $elf.input = makeOMInputStream(arguments[idx], $elf.input, null)
    #return this[rule].apply($elf)
    # would probably be easier to use realsuper in the caller, rather than do this
    ##classes = self.class.ancestors.select { |a| Class === a }
    #methods = classes.map { |a| a.instance_method rule rescue nil }.compact
    #method = methods.first.bind(self)
    args.reverse_each do |arg|
      @input = LazyStream.new arg, @input, nil
    end
    # we leverage the inbuild ruby super, by means of the block passed to this function
    # which calls super
    yield
    #method.call
  end

  def _pred(b)
    if (b)
      return true
    end
    raise Fail
  end

  def _xnot
    oldInput = @input.copy
    begin
      yield
    rescue Fail
      @input = oldInput
      return true
    end
    raise Fail
  end

  def _xlookahead
    oldInput = @input.copy
    r = yield
    @input = oldInput
    r
  end

  def _or(*args)
    oldInput = @input.copy
    args.each do |arg|
      begin
        @input = oldInput
        return arg.call
      rescue Fail
      end
    end
    raise Fail
  end

  def _xmany(*ans)
    while true
      oldInput = @input.copy
      begin
        ans << yield
        next
      rescue Fail
      end
      @input = oldInput
      break
    end
    ans
  end

  def _xmany1(&block)
    _xmany block.call, &block
  end
	def _key(key,block)
		oldInput = @input
		src=@input.stream.src
		v=src.instance_variable_get("@#{key}")
		v||=src.call(key) if src.respond_to? key
		v||=src[key] if src.respond_to? "[]"
		@input = LazyStream.new UNDEFINED, UNDEFINED, ReadStream.new([v])
		r =block.call
		_apply "end"
		@input = oldInput
		r
	end

  def _xform
    v = _apply "anything"
    oldInput = @input
    @input = LazyStream.new UNDEFINED, UNDEFINED, ReadStream.new(v)
    r = yield
    _apply "end"
    @input = oldInput
    r
  end

  #// some basic rules
  def anything
    r = @input.head
    @input = @input.tail
    return r
  end

	def apply
    p=_apply('anything')
		if p.is_a? Proc
			p.call
		else
			_apply p
		end
  end

  def foreign
    g   = _apply("anything")
    r   = _apply("anything")
    fis = LazyStreamWrapper.new @input
    gi = g.new(fis)
    ans = gi._apply(r)
    @input = gi.input.stream
    #p :foreign => ans
    return ans
  end

  #//  some useful "derived" rules

  def seq
    xs = _apply 'anything'
		_or(
			proc{
				_applyWithArgs('exactly',xs)
			}	, proc{
				if String === xs
					xs = Character::StringWrapper.new xs
				end
				xs.each { |obj| _applyWithArgs 'exactly', obj }
			}
		)
		xs
	end
	def _append(ar,it)
		if it.is_a? Array
			ar.concat(it) 
		else
			ar << it
		end
	end
  def initialize(input)
    @input = input
    initialize_hook
  end

  def initialize_hook
  end

  # #match:with: and #matchAll:with: are a grammar's "public interface"
  def self.genericMatch(input, rule, *args)
    m = new(input)
    e = nil
    begin
      if args.empty?
        return m._apply(rule)
      else
        return m._applyWithArgs(rule, *args)
      end
    rescue Fail
      e = $!
    end
    #e = Fail.new
    e.matcher = m
    pos = m.input.instance_variable_get(:@stream).pos.inspect
    e.message.replace "Unable to match at pos #{pos}"
    raise e
  end

  def self.matchwith(obj, rule, *args)
    genericMatch LazyStream.new(UNDEFINED, UNDEFINED, ReadStream.new([obj])), rule, *args
  end

  def self.matchAllwith(listyObj, rule, *args)
    genericMatch LazyStream.new(UNDEFINED, UNDEFINED, ReadStream.new(listyObj)), rule, *args
  end

  # ----

  def parse
    rule = _apply("anything"),
    ans  = _apply(rule)
    _apply("end")
    return ans
  end

  NICER_FAILURE_METHODS = {
    '_or' => 'No matching alternative',
    nil   => 'Failure'
  }

  def self.parsewith(text, rule)
    begin
      return matchAllwith(text, rule)
    rescue Fail => e
      e.failPos = e.matcher.input.realPos() - 1
      key = $@.first[/\`(.*?)\'/, 1]
      cause = NICER_FAILURE_METHODS[key] || NICER_FAILURE_METHODS[nil]
      rule = $@.find { |l| l !~ /runtime/ }[/\`(.*?)\'/, 1]
      lines = text[0, e.failPos].to_a
      lines = [''] if lines.empty?
      message = "#{cause} in rule #{rule.inspect}, at line #{lines.length} character #{lines.last.length + 1}"
      raise e, message #, $@
    end
  end

  def unescapeChar c
		eval ("\"\\"+c+"\"")
  end
end
