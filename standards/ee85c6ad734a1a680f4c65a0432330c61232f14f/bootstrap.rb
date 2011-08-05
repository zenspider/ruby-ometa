# Automatically generated. DO NOT MODIFY.
puts "aoeuouea"
OMeta = Class.new(OMetaCore) do
@name = "OMeta"
def _dot_

_apply("anything")
end

def regch
regex = c = nil
(regex = _apply("anything");c = _apply("char");_pred(Regexp.new("[#{regex}]").match(c));c)
end

def perhaps
expr = nil
(expr = _apply("anything");_or(proc { _applyWithArgs("apply", expr) }, proc { _apply("empty") }))
end

def end

_xnot { _apply("_dot_") }
end

def empty

true
end

def endline

_or(proc { (_xmany1 { _applyWithArgs("token", "\r") };_applyWithArgs("token", "\n")) }, proc { _applyWithArgs("token", "\r") }, proc { _applyWithArgs("token", "\n") })
end

def char
c = nil
(c = _apply("_dot_");_pred(Character === c );c)
end

def space
c = nil
(c = _apply("char");_pred(c[0]<=32);c)
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

def Rule
name = ls = body = nil
(name = _apply("anything");ls = _apply("anything");body = _apply("trans"); ['Rule', name, ls, body] )
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
t = xs = ys = x = xs = nil
(t = _apply("anything");_or(proc { (_xform { (_applyWithArgs("exactly", t);xs = _applyWithArgs("transInside", t)) };ys = _applyWithArgs("transInside", t);_apply("setHelped");xs + ys ) }, proc { (x = _apply("trans");xs = _applyWithArgs("transInside", t);[x, *xs] ) }, proc { []  }))
end
end

OMetaOptimizer = Class.new(OMeta) do
@name = "OMetaOptimizer"
def optimizeGrammar
n = sn = rs = nil
(_xform { (_applyWithArgs("exactly", "Grammar");n = _apply("anything");sn = _apply("anything");rs = _xmany { _apply("optimizeRule") }) }; ['Grammar', n, sn, *rs] )
end

def optimizeRule
r = r = nil
(r = _apply("anything");_xmany { r = _applyWithArgs("foreign", AndOrOptimizer, "optimize", r) }; r )
end
end

BSRubyParser = Class.new(OMeta) do
@name = "BSRubyParser"
def eChar
c = nil
_or(proc { (_applyWithArgs("exactly", "\\");c = _apply("char"); unescapeChar c ) }, proc { _apply("char") })
end

def tsString
xs = nil
(_applyWithArgs("exactly", "'");xs = _xmany { (_xnot { _applyWithArgs("exactly", "'") };_apply("eChar")) };_applyWithArgs("exactly", "'"); xs.join('') )
end

def nonBraChar

(_xnot { _applyWithArgs("exactly", "(") };_xnot { _applyWithArgs("exactly", ")") };_apply("char"))
end

def insideBra

_or(proc { _apply("innerBra") }, proc { _apply("nonBraChar") })
end

def innerBra
xs = nil
(_applyWithArgs("exactly", "(");xs = _xmany { _apply("insideBra") };_applyWithArgs("exactly", ")"); "{#{xs.join('')}}" )
end

def outerBra
xs = nil
(_applyWithArgs("exactly", "(");xs = _xmany { _apply("insideBra") };_applyWithArgs("exactly", ")"); xs.join('') )
end

def expr

_apply("outerBra")
end

def semAction1
xs = nil
(_apply("spaces");xs = _xmany { (_xnot { _applyWithArgs("seq", "\n") };_apply("anything")) }; xs.join('') )
end

def nonBraceChar

(_xnot { _applyWithArgs("exactly", "{") };_xnot { _applyWithArgs("exactly", "}") };_apply("char"))
end

def inside

_or(proc { _apply("innerBraces") }, proc { _apply("nonBraceChar") })
end

def innerBraces
xs = nil
(_applyWithArgs("exactly", "{");xs = _xmany { _apply("inside") };_applyWithArgs("exactly", "}"); "{#{xs.join('')}}" )
end

def outerBraces
xs = nil
(_applyWithArgs("exactly", "{");xs = _xmany { _apply("inside") };_applyWithArgs("exactly", "}"); xs.join('') )
end

def semAction2

(_apply("spaces");_apply("outerBraces"))
end

def semAction

_or(proc { _apply("semAction2") }, proc { _apply("semAction1") })
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

def tsName
xs = nil
(xs = _applyWithArgs("firstAndRest", "nameFirst","nameRest");leterize(xs.join('')) )
end

def name

(_apply("spaces");_apply("tsName"))
end

def eChar
c = nil
_or(proc { (_applyWithArgs("exactly", "\\");c = _apply("char");unescapeChar c ) }, proc { _apply("char") })
end

def tsString
xs = nil
(_applyWithArgs("exactly", "'");xs = _xmany { (_xnot { _applyWithArgs("exactly", "'") };_apply("eChar")) };_applyWithArgs("exactly", "'");xs.join('') )
end

def characters
xs = nil
(_applyWithArgs("exactly", "`");_applyWithArgs("exactly", "`");xs = _xmany { (_xnot { (_applyWithArgs("exactly", "'");_applyWithArgs("exactly", "'")) };_apply("eChar")) };_applyWithArgs("exactly", "'");_applyWithArgs("exactly", "'");['App', 'seq',     xs.join('').inspect] )
end

def sCharacters
xs = nil
(_applyWithArgs("exactly", "\"");xs = _xmany { (_xnot { _applyWithArgs("exactly", "\"") };_apply("eChar")) };_applyWithArgs("exactly", "\"");['App', 'token',   xs.join('').inspect] )
end

def string
xs = nil
(xs = _or(proc { (_or(proc { _applyWithArgs("exactly", "#") }, proc { _applyWithArgs("exactly", "`") });_apply("tsName")) }, proc { _apply("tsString") });['App', 'exactly', xs.inspect] )
end

def number
sign = ds = nil
(sign = _or(proc { _applyWithArgs("exactly", "-") }, proc { (_apply("empty"); '' ) });ds = _xmany1 { _apply("digit") };['App', 'exactly', sign + ds.join('')] )
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
_or(proc { (xs = _apply("hostExpr");xs ) }, proc { (_apply("empty");"" ) })
end

def application
klas = rule = as = rule = as = nil
_or(proc { (klas = _apply("name");_applyWithArgs("token", "::");rule = _apply("name");as = _apply("args");['App', 'foreign',klas,rule.inspect, *as] ) }, proc { (rule = _apply("name");as = _apply("args");['App', rule, *as] ) })
end

def expr
xs = nil
(xs = _applyWithArgs("listOf", "expr4", "|");(xs.size==1 ? xs[0] : ['Or',        *xs] ))
end

def expr4
xs = nil
(xs = _xmany { _apply("expr3") };(xs.size==1 ? xs[0] : ['And',       *xs] ))
end

def optIter
x = nil
(x = _apply("anything");_or(proc { (_applyWithArgs("token", "*");['Many',        x]) }, proc { (_applyWithArgs("token", "+");['Many1',       x] ) }, proc { (_applyWithArgs("token", "?");_xnot { _apply("inlineHostExpr") };['App','perhaps', x] ) }, proc { (_apply("empty");x ) }))
end

def expr3
x = x = n = n = nil
_or(proc { (x = _apply("expr2");x = _applyWithArgs("optIter", x);_or(proc { (_applyWithArgs("exactly", ":");n = _apply("name");(@locals << n; ['Set', n, x]) ) }, proc { (_apply("empty");x) })) }, proc { (_applyWithArgs("token", ":");n = _apply("name");(@locals << n; ['Set', n, ['App', 'anything']]) ) })
end

def expr2
x = x = nil
_or(proc { (_applyWithArgs("token", "~");x = _apply("expr2");['Not',         x] ) }, proc { (_applyWithArgs("token", "&");_xnot { _apply("inlineHostExpr") };x = _apply("expr1");['Lookahead',   x] ) }, proc { _apply("expr1") })
end

def expr1
x = x = x = x = x = nil
_or(proc { _apply("application") }, proc { (_applyWithArgs("token", "->");x = _apply("atomicHostExpr");['Act',         x]) }, proc { (_applyWithArgs("token", "&");x = _apply("inlineHostExpr");['Pred',        x]) }, proc { (_apply("spaces");_or(proc { _apply("characters") }, proc { _apply("sCharacters") }, proc { _apply("string") }, proc { _apply("number") })) }, proc { (_applyWithArgs("token", "[");x = _apply("expr");_applyWithArgs("token", "]");['Form', x] ) }, proc { (_applyWithArgs("token", "<");x = _xmany1 { (_xnot { _applyWithArgs("token", ">") };_apply("eChar")) };_applyWithArgs("token", ">");['App', 'regch', x.join('').inspect] ) }, proc { (_applyWithArgs("token", "(");x = _apply("expr");_applyWithArgs("token", ")");x ) })
end

def ruleName

_or(proc { _apply("name") }, proc { (_apply("spaces");_apply("tsString")) })
end

def rule
n = x = xs = nil
(_xlookahead { n = _apply("ruleName") };@locals = [];x = _applyWithArgs("rulePart", n);xs = _xmany { (_applyWithArgs("token", ",");_applyWithArgs("rulePart", n)) };['Rule', n, @locals, ['Or', x, *xs]] )
end

def rulePart
rn = n = b1 = b2 = nil
(rn = _apply("anything");n = _apply("ruleName");_pred(n == rn);b1 = _apply("expr4");_or(proc { (_applyWithArgs("token", "=");b2 = _apply("expr");['And', b1, b2] ) }, proc { (_apply("empty");b1 ) }))
end

def grammar
n = sn = rs = nil
(_applyWithArgs("keyword", "ometa");n = _apply("name");sn = _or(proc { (_applyWithArgs("token", "<:");_apply("name")) }, proc { (_apply("empty"); 'OMeta' ) });_applyWithArgs("token", "{");rs = _applyWithArgs("listOf", "rule", ",");_applyWithArgs("token", "}");['Grammar', n, sn, *rs] )
end
end

RubyOMetaTranslator = Class.new(OMeta) do
@name = "RubyOMetaTranslator"
def trans
t = ans = nil
(_xform { (t = _apply("anything");ans = _applyWithArgs("apply", t)) }; ans )
end

def App
args = rule = args = rule = nil
_or(proc { (_applyWithArgs("exactly", "super");args = _xmany1 { _apply("anything") }; "_superApplyWithArgs(#{args * ', '})" ) }, proc { (rule = _apply("anything");args = _xmany1 { _apply("anything") }; "_applyWithArgs(#{rule.inspect}, #{args * ', '})" ) }, proc { (rule = _apply("anything"); "_apply(#{rule.inspect})" ) })
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

def Rule
name = ls = body = nil
(name = _apply("anything");ls = _apply("locals");body = _apply("trans"); "def #{name}\n#{ls}\n#{body}\nend\n" )
end

def Grammar
name = sName = rules = nil
(name = _apply("anything");sName = _apply("anything");rules = _xmany { _apply("trans") }; "Class.new(#{sName}) do\n@name = #{name.inspect}\n#{rules * "\n"}end" )
end

def locals
vs = nil
_or(proc { (_xform { vs = _xmany1 { _apply("anything") } }; vs.map { |v| "#{v} = " }.join('') + 'nil' ) }, proc { (_xform { proc {} }; '' ) })
end

def transFn
x = nil
(x = _apply("trans"); "proc { #{x} }" )
end
end
