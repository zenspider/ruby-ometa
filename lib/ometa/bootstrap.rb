# Automatically generated. DO NOT MODIFY.

OMeta = Class.new(OMetaCore) do
@name = "OMeta"
def _dot_


_apply("anything")
end

def regch
regex = c = nil

(regex = _apply("anything");c = _apply("char");_pred(Regexp.new("[#{regex}]").match(c));c)
end

def end


_xnot { _apply("_dot_") }
end

def empty


true
end

def endline


_or(proc { (_applyWithArgs("token", "\r");_applyWithArgs("token", "\n")) }, proc { _applyWithArgs("token", "\r") }, proc { _applyWithArgs("token", "\n") })
end

def char
c = nil

(c = _apply("_dot_");_pred(Character === c );c)
end

def space


_applyWithArgs("regch", " \t\r\n\f")
end

def spaces


_xmany { _apply("space") }
end

def digit


_applyWithArgs("regch", "0-9")
end

def lower


_applyWithArgs("regch", "a-z")
end

def upper


_applyWithArgs("regch", "A-Z")
end

def letter


_or(proc { _apply("lower") }, proc { _apply("upper") })
end

def letterOrDigit


_or(proc { _apply("letter") }, proc { _apply("digit") })
end

def alpha


_apply("letter")
end

def alnum


_apply("letterOrDigit")
end

def xdigit


_applyWithArgs("regch", "0-9a-fA-F")
end

def word


_or(proc { _apply("alpha") }, proc { _applyWithArgs("seq", "_") })
end

def exactly
wanted = got = nil

(wanted = _apply("anything");got = _apply("anything");wanted == got ? wanted : (raise Fail))
end

def notLast
rule = r = nil

(rule = _apply("anything");r = _applyWithArgs("apply", rule);_xlookahead { _applyWithArgs("apply", rule) };r)
end

def token
cs = nil

(cs = _apply("anything");_apply("spaces");_applyWithArgs("seq", cs))
end

def firstAndRest
first = rest = f = r = nil

(first = _apply("anything");rest = _apply("anything");f = _applyWithArgs("apply", first);r = _xmany { _applyWithArgs("apply", rest) };r.unshift(f))
end

def listOf
rule = delim = f = r = nil

(rule = _apply("anything");delim = _apply("anything");_or(proc { (f = _applyWithArgs("apply", rule);r = _xmany { (_applyWithArgs("apply", delim);_applyWithArgs("apply", rule)) };r.unshift(f)) }, proc { (_apply("empty");[]) }))
end

def clas
cls = nil

(cls = _apply("anything");_pred(@input.stream.src.is_a? Class.const_get(cls)))
end

def foo


Aue.new()
end
end

NullOptimizer = Class.new(OMeta) do
@name = "NullOptimizer"
def setHelped


@_didSomething = true
end

def helped


_pred(@_didSomething)
end

def trans
t = ans = nil

_or(proc { (_xform { (t = _apply("anything");_pred(respond_to?(t));ans = _applyWithArgs("apply", t)) }; ans ) }, proc { _apply("anything") })
end

def optimize
x = nil

(x = _apply("trans");_apply("helped"); x )
end

def Or
xs = nil

(xs = _xmany { _apply("trans") }; ['Or',      *xs] )
end

def And
xs = nil

(xs = _xmany { _apply("trans") }; ['And',     *xs] )
end

def Many
x = nil

(x = _apply("trans"); ['Many',      x] )
end

def Many1
x = nil

(x = _apply("trans"); ['Many1',     x] )
end

def Set
n = v = nil

(n = _apply("anything");v = _apply("trans"); ['Set',    n, v] )
end

def Not
x = nil

(x = _apply("trans"); ['Not',       x] )
end

def Lookahead
x = nil

(x = _apply("trans"); ['Lookahead', x] )
end

def Form
x = nil

(x = _apply("trans"); ['Form',      x] )
end

def Key
name = x = nil

(name = _apply("anything");x = _apply("trans"); ['Key',name,			x] )
end

def Rule
name = ls = ar = body = nil

(name = _apply("anything");ls = _apply("anything");ar = _apply("anything");body = _apply("trans"); ['Rule', name, ls,ar, body] )
end

def initialize_hook


 @_didSomething = false 
end
end

AndOrOptimizer = Class.new(NullOptimizer) do
@name = "AndOrOptimizer"
def And
x = xs = nil

_or(proc { (x = _apply("trans");_apply("end");_apply("setHelped");x ) }, proc { (xs = _applyWithArgs("transInside", "And");['And', *xs] ) })
end

def Or
x = xs = nil

_or(proc { (x = _apply("trans");_apply("end");_apply("setHelped");x ) }, proc { (xs = _applyWithArgs("transInside", "Or");['Or',  *xs] ) })
end

def transInside
t = xs = ys = x = nil

(t = _apply("anything");_or(proc { (_xform { (_applyWithArgs("exactly", t);xs = _applyWithArgs("transInside", t)) };ys = _applyWithArgs("transInside", t);_apply("setHelped");xs + ys ) }, proc { (x = _apply("trans");xs = _applyWithArgs("transInside", t);[x, *xs] ) }, proc { []  }))
end
end

OMetaOptimizer = Class.new(OMeta) do
@name = "OMetaOptimizer"
def optimizeGrammar
n = sn = rs = nil

(_xform { (_applyWithArgs("seq", "Grammar");n = _apply("anything");sn = _apply("anything");rs = _xmany { _apply("optimizeRule") }) }; ['Grammar', n, sn, *rs] )
end

def optimizeRule
r = nil

(r = _apply("anything");_xmany { r = _applyWithArgs("foreign", AndOrOptimizer, "optimize", r) }; r )
end
end

BSRubyParser = Class.new(OMeta) do
@name = "BSRubyParser"
def eChar
c = nil

_or(proc { (_applyWithArgs("seq", "\\");c = _apply("char"); unescapeChar c ) }, proc { _apply("char") })
end

def tsString
xs = nil

(_applyWithArgs("seq", "'");xs = _xmany { (_xnot { _applyWithArgs("seq", "'") };_apply("eChar")) };_applyWithArgs("seq", "'"); xs.join('') )
end

def nonBraChar


(_xnot { _applyWithArgs("seq", "(") };_xnot { _applyWithArgs("seq", ")") };_apply("char"))
end

def insideBra
o = nil

_or(proc { (o = _apply("omproc");[o]) }, proc { _apply("innerBra") }, proc { _apply("nonBraChar") })
end

def innerBra
xs = nil

(_applyWithArgs("seq", "(");xs = _xmany { _apply("insideBra") };_applyWithArgs("seq", ")");"("+xs*"" +")" )
end

def outerBra
xs = nil

(_applyWithArgs("seq", "(");xs = _xmany { _apply("insideBra") };_applyWithArgs("seq", ")"); [ xs] )
end

def expr


_apply("outerBra")
end

def semAction1
xs = nil

(_apply("spaces");xs = _xmany { (_xnot { _applyWithArgs("seq", "\n") };_apply("anything")) }; xs.join('') )
end

def nonBraceChar


(_xnot { _applyWithArgs("seq", "{") };_xnot { _applyWithArgs("seq", "}") };_apply("char"))
end

def inside


_or(proc { _apply("innerBraces") }, proc { _apply("nonBraceChar") })
end

def innerBraces
xs = nil

(_applyWithArgs("seq", "{");xs = _xmany { _apply("inside") };_applyWithArgs("seq", "}"); "{#{xs.join('')}}" )
end

def outerBraces
xs = nil

(_applyWithArgs("seq", "{");xs = _xmany { _apply("inside") };_applyWithArgs("seq", "}"); xs.join('') )
end

def semAction2


(_apply("spaces");_apply("outerBraces"))
end

def semAction


_or(proc { _apply("semAction2") }, proc { _apply("semAction1") })
end

def omproc
x = nil

(_applyWithArgs("seq", "`");x = _applyWithArgs("foreign", OMetaParser, "expr");_applyWithArgs("seq", "`");x)
end
end

BSRubyTranslator = Class.new(OMeta) do
@name = "BSRubyTranslator"
def trans


_apply("anything")
end
end

OMetaParser = Class.new(OMeta) do
@name = "OMetaParser"
def nameFirst


_or(proc { _applyWithArgs("regch", "_$.^") }, proc { _apply("letter") })
end

def nameRest


_or(proc { _apply("nameFirst") }, proc { _apply("digit") })
end

def className

xs = []
(_append(xs , _apply("upper"));_append(xs , _xmany { _apply("nameRest") });leterize(xs.join('')))
end

def tsName

xs = []
(_append(xs , _apply("nameFirst"));_append(xs , _xmany { _apply("nameRest") });leterize(xs.join('')) )
end

def name


(_apply("spaces");_apply("tsName"))
end

def eChar
c = nil

_or(proc { (_applyWithArgs("seq", "\\");c = _apply("char");unescapeChar c ) }, proc { _apply("char") })
end

def tsString
xs = nil

(_applyWithArgs("seq", "'");xs = _xmany { (_xnot { _applyWithArgs("seq", "'") };_apply("eChar")) };_applyWithArgs("seq", "'");xs.join('') )
end

def characters
s = nil

(s = _apply("tsString");['App', 'seq',     s.inspect] )
end

def sCharacters
xs = nil

(_applyWithArgs("seq", "\"");xs = _xmany { (_xnot { _applyWithArgs("seq", "\"") };_apply("eChar")) };_applyWithArgs("seq", "\"");['App', 'token',   xs.join('').inspect] )
end

def string
xs = nil

(xs = (_applyWithArgs("seq", "#");_apply("tsName"));['App', 'exactly', xs.inspect] )
end

def number
sign = ds = nil

(sign = _or(proc { _applyWithArgs("seq", "-") }, proc { (_apply("empty"); '' ) });ds = _xmany1 { _apply("digit") };['App', 'exactly', sign + ds.join('')] )
end

def keyword
xs = nil

(xs = _apply("anything");_applyWithArgs("token", xs);_xnot { _apply("letterOrDigit") };xs )
end

def hostExpr
r = nil

(r = _applyWithArgs("foreign", BSRubyParser, "expr");_applyWithArgs("foreign", BSRubyTranslator, "trans", r))
end

def atomicHostExpr
r = nil

(r = _applyWithArgs("foreign", BSRubyParser, "semAction");_applyWithArgs("foreign", BSRubyTranslator, "trans", r))
end

def inlineHostExpr
r = nil

(r = _applyWithArgs("foreign", BSRubyParser, "semAction2");_applyWithArgs("foreign", BSRubyTranslator, "trans", r))
end

def args
xs = nil

_or(proc { (_xnot { _apply("space") };xs = _apply("hostExpr");xs ) }, proc { (_apply("empty");"" ) })
end

def application
klas = rule = as = nil

_or(proc { (klas = _apply("name");_applyWithArgs("token", "::");rule = _apply("name");as = _apply("args");['App', 'foreign',klas,rule.inspect, *as] ) }, proc { (rule = _apply("name");as = _apply("args");['App', rule, *as] ) })
end

def expr
xs = nil

(xs = _applyWithArgs("listOf", "expr4", proc { _applyWithArgs("token", "|") });(xs.size==1 ? xs[0] : ['Or',        *xs] ))
end

def expr4
xs = nil

(xs = _xmany { _apply("expr3") };(xs.size==1 ? xs[0] : ['And',       *xs] ))
end

def optIter
x = nil

(x = _apply("anything");_or(proc { (_applyWithArgs("token", "*");['Many',        x]) }, proc { (_applyWithArgs("token", "+");['Many1',       x] ) }, proc { (_applyWithArgs("token", "?");_xnot { _apply("inlineHostExpr") };['Or', x,['App','empty']] ) }, proc { (_apply("empty");x ) }))
end

def binding
x = n = e = nil

(x = _apply("anything");_or(proc { (_applyWithArgs("seq", ":");n = _apply("name");_or(proc { (_applyWithArgs("seq", "[");_applyWithArgs("seq", "]");@arrays << n; ['Append', n, x] ) }, proc { (_apply("empty");@locals << n; ['Set', n, x]) })) }, proc { (_applyWithArgs("seq", ":");e = _apply("inlineHostExpr");@locals << "it";  ['And',['Set','it',x],['Pred',e]]) }))
end

def expr3
x = nil

_or(proc { (x = _apply("expr2");x = _applyWithArgs("optIter", x);_or(proc { _applyWithArgs("binding", x) }, proc { (_apply("empty");x) })) }, proc { (_apply("spaces"); x=['App','anything'];_applyWithArgs("binding", x)) })
end

def expr2
x = nil

_or(proc { (_applyWithArgs("token", "~");x = _apply("expr2");['Not',         x] ) }, proc { (_applyWithArgs("token", "&");_xnot { _apply("inlineHostExpr") };x = _apply("expr1");['Lookahead',   x] ) }, proc { _apply("expr1") })
end

def expr1
c = x = var = args = nil

_or(proc { (_apply("spaces");c = _apply("className");_applyWithArgs("seq", "[");x = _apply("expr");_applyWithArgs("token", "]");['Form',['And', ['App',"clas",c.inspect]  ,x]]) }, proc { _apply("application") }, proc { (_applyWithArgs("token", "@");var = _apply("name");x = _or(proc { (_applyWithArgs("token", "=>");_apply("application")) }, proc { (_apply("empty");['App',"anything"]) });['Key',  var,   x]) }, proc { (_applyWithArgs("token", "->");x = _apply("atomicHostExpr");['Act',         x]) }, proc { (_applyWithArgs("token", "&");x = _apply("inlineHostExpr");['Pred',        x]) }, proc { (_apply("spaces");_or(proc { _apply("characters") }, proc { _apply("sCharacters") }, proc { _apply("string") }, proc { _apply("number") })) }, proc { (_applyWithArgs("token", "[");x = _apply("expr");_applyWithArgs("token", "]");['Form', x]) }, proc { (_applyWithArgs("token", "%");c = _or(proc { _apply("className") }, proc { (_apply("empty");"Array") });_applyWithArgs("seq", "[");args = _apply("klasargs");_applyWithArgs("token", "]");Klass.new(c,args)) }, proc { (_applyWithArgs("token", "<");x = _xmany1 { (_xnot { _applyWithArgs("token", ">") };_apply("eChar")) };_applyWithArgs("token", ">");['App', 'regch', x.join('').inspect] ) }, proc { (_applyWithArgs("token", "(");x = _apply("expr");_applyWithArgs("token", ")");x ) })
end

def klasargs
a = nil

(a = _xmany { _applyWithArgs("regch", "^\\]") };a*"")
end

def ruleName


_or(proc { _apply("name") }, proc { (_apply("spaces");_apply("tsString")) })
end

def rule
n = x = xs = nil

(_xlookahead { n = _apply("ruleName") };@locals = []; @arrays = [];x = _applyWithArgs("rulePart", n);xs = _xmany { (_applyWithArgs("token", ",");_applyWithArgs("rulePart", n)) };['Rule', n, @locals.uniq,@arrays.uniq, ['Or', x, *xs]] )
end

def rulePart
rn = n = b1 = b2 = nil

(rn = _apply("anything");n = _apply("ruleName");_pred(n == rn);b1 = _apply("expr4");_or(proc { (_applyWithArgs("token", "=");b2 = _apply("expr");['And', b1, b2] ) }, proc { (_apply("empty");b1 ) }))
end

def grammar
n = sn = rs = nil

(_applyWithArgs("keyword", "ometa");n = _apply("name");sn = _or(proc { (_applyWithArgs("token", "<:");_apply("name")) }, proc { (_apply("empty"); 'OMeta' ) });_applyWithArgs("token", "{");rs = _applyWithArgs("listOf", "rule", proc { _applyWithArgs("token", ",") });_applyWithArgs("token", "}");['Grammar', n, sn, *rs])
end
end

RubyOMetaTranslator = Class.new(OMeta) do
@name = "RubyOMetaTranslator"
def trans
name = args = t = ans = nil

_or(proc { (_xform { (_applyWithArgs("clas", "Klass");name = _key("name",proc { _apply("anything") });args = _key("args",proc { _apply("anything") })) };"#{name}.new(#{args})") }, proc { (_xform { (t = _apply("anything");ans = _applyWithArgs("apply", t)) }; ans ) })
end

def App
args = rule = nil

_or(proc { (_applyWithArgs("seq", "super");args = _xmany1 { _apply("arg") }; "_superApplyWithArgs(#{args*", "})" ) }, proc { (rule = _apply("anything");args = _xmany1 { _apply("arg") }; "_applyWithArgs(#{rule.inspect}, #{args*", "})" ) }, proc { (rule = _apply("anything"); "_apply(#{rule.inspect})" ) })
end

def arg
m = s = nil

_or(proc { (_xform { m = _xmany { _apply("ag") } };m*"") }, proc { (s = _apply("anything");_pred(s.is_a? String);s) })
end

def ag
t = nil

_or(proc { _apply("char") }, proc { (_xform { t = _apply("transFn") };t) })
end

def Act
expr = nil

(expr = _apply("anything"); expr )
end

def Pred
expr = nil

(expr = _apply("anything"); "_pred(#{expr})" )
end

def Or
xs = nil

(xs = _xmany { _apply("transFn") }; "_or(#{xs * ', '})" )
end

def And
xs = y = nil

_or(proc { (xs = _xmany { _applyWithArgs("notLast", "trans") };y = _apply("trans"); "(#{(xs + [y]) * ';'})" ) }, proc {  "proc {}"  })
end

def Many
x = nil

(x = _apply("trans"); "_xmany { #{x} }" )
end

def Many1
x = nil

(x = _apply("trans"); "_xmany1 { #{x} }" )
end

def Set
n = v = nil

(n = _apply("anything");v = _apply("trans"); "#{n} = #{v}" )
end

def Append
n = v = nil

(n = _apply("anything");v = _apply("trans"); "_append(#{n} , #{v})" )
end

def Not
x = nil

(x = _apply("trans"); "_xnot { #{x} }" )
end

def Lookahead
x = nil

(x = _apply("trans"); "_xlookahead { #{x} }" )
end

def Form
x = nil

(x = _apply("trans"); "_xform { #{x} }" )
end

def Key
name = x = nil

(name = _apply("anything");x = _apply("transFn");	"_key(#{name.inspect},#{x})"	)
end

def Rule
name = ls = ars = body = nil

(name = _apply("anything");ls = _apply("locals");ars = _apply("arrays");body = _apply("trans"); "def #{name}\n#{ls}\n#{ars}\n#{body}\nend\n" )
end

def Grammar
name = sName = rules = nil

(name = _apply("anything");sName = _apply("anything");rules = _xmany { _apply("trans") }; "Class.new(#{sName}) do\n@name = #{name.inspect}\n#{rules * "\n"}end" )
end

def locals
vs = nil

_or(proc { (_xform { vs = _xmany1 { _apply("anything") } }; vs.map { |v| "#{v} = " }.join('') + 'nil' ) }, proc { (_xform { proc {} }; '' ) })
end

def arrays
vs = nil

_or(proc { (_xform { vs = _xmany1 { _apply("anything") } }; vs.map { |v| "#{v} = " }.join('') + '[]' ) }, proc { (_xform { proc {} }; '' ) })
end

def transFn
x = nil

(x = _apply("trans"); "proc { #{x} }" )
end
end
