#!/usr/bin/env ruby

require './uschemer'

def eval(string, env)
  exp = USchemeR.parse_string(string)
  eval = USchemeR::Eval.new
  eval.eval(exp, env)
end

describe '+ operator' do
  before do
    @env = [USchemeR::KEYWORDS, USchemeR::FUNCS]
  end

  context 'one parameter' do
    it { eval("(+ 1)", @env).should eq 1 }
  end

  context 'two parameters' do
    it { eval("(+ 1 2)", @env).should eq 3 }
  end

  context 'many parameters' do
    it { eval("(+ 1 2 3 4 5)", @env).should eq 15 }
  end
end

describe '- operator' do
  before do
    @env = [USchemeR::KEYWORDS, USchemeR::FUNCS]
  end

  context 'one parameter' do
    it { eval("(- 1)", @env).should eq -1 }
  end

  context 'two parameters' do
    it { eval("(- 1 2)", @env).should eq -1 }
  end

  context 'many parameters' do
    it { eval("(- 1 2 3 4 5)", @env).should eq -13 }
  end
end

describe '* operator' do
  before do
    @env = [USchemeR::KEYWORDS, USchemeR::FUNCS]
  end

  context 'one parameter' do
    it { eval("(* 1)", @env).should eq 1 }
  end

  context 'two parameters' do
    it { eval("(* 2 3)", @env).should eq 6 }
  end

  context 'many parameters' do
    it { eval("(* 1 2 3 4 5)", @env).should eq 120 }
  end
end

describe '/ operator' do
  before do
    @env = [USchemeR::KEYWORDS, USchemeR::FUNCS]
  end

  context 'one parameter' do
    it { eval("(/ 2.0)", @env).should eq (1 / 2.0) }
  end

  context 'two parameters' do
    it { eval("(/ 12 4)", @env).should eq 3 }
  end

  context 'many parameters' do
    it { eval("(/ 24 6 2)", @env).should eq 2 }
  end
end

describe 'and' do
  before do
    @env = [USchemeR::KEYWORDS, USchemeR::FUNCS]
  end

  context 'all true' do
    it { eval("(and true true)", @env).should eq true }
  end

  context 'all false' do
    it { eval("(and false false)", @env).should eq false }
  end

  context 'all number' do
    it { eval("(and (+ 1 2) (+ 3 4))", @env).should eq 7 }
  end

  context 'all one parameter false' do
    it { eval("(and (+ 1 2) false)", @env).should eq false }
  end
end

describe 'or' do
  before do
    @env = [USchemeR::KEYWORDS, USchemeR::FUNCS]
  end

  context 'all true' do
    it { eval("(or true true)", @env).should eq true }
  end

  context 'all false' do
    it { eval("(or false false)", @env).should eq false }
  end

  context 'all number' do
    it { eval("(or (+ 1 2) (+ 3 4))", @env).should eq 3 }
  end

  context 'all first parameter false' do
    it { eval("(or false (+ 3 4))", @env).should eq 7 }
  end
end

describe 'not' do
  before do
    @env = [USchemeR::KEYWORDS, USchemeR::FUNCS]
  end

  context 'true' do
    it { eval("(not true)", @env).should eq false }
  end

  context 'false' do
    it { eval("(not false)", @env).should eq true }
  end

  context 'number' do
    it { eval("(not 1)", @env).should eq false }
  end
end

describe 'let' do
  before do
    @env = [USchemeR::KEYWORDS, USchemeR::FUNCS]
  end

  context 'var bind' do
    it { eval("(let ((a 1) (b 2)) (+ a b))", @env).should eq 3 }
  end
end

describe 'if' do
  before do
    @env = [USchemeR::KEYWORDS, USchemeR::FUNCS]
  end

  context 'pred true' do
    it { eval('(if true "true" "false")', @env).should eq "true" }
  end

  context 'pred false' do
    it { eval('(if false "true" "false")', @env).should eq "false" }
  end
end

describe 'lambda' do
  before do
    @env = [USchemeR::KEYWORDS, USchemeR::FUNCS]
  end

  context 'function' do
    it { eval('((lambda (a b) (+ a b)) 1 2)', @env).should eq 3 }
  end
end

describe 'letrec' do
  before do
    @env = [USchemeR::KEYWORDS, USchemeR::FUNCS]
  end

  context 'recursive' do
    it { eval('(letrec ((fact (lambda (n) (if (= n 0) 1 (* n (fact (- n 1))))))) (fact 5))', @env).should eq 120 }
  end
end

describe 'define' do
  before do
    @env = [USchemeR::KEYWORDS, USchemeR::FUNCS]
    eval('(define a 123)', @env)
    eval('(define (add a b) (+ a b))', @env)
  end

  context 'define var' do
    it { eval('a', @env).should eq 123 }
  end

  context 'define function' do
    it { eval('(add 1 2)', @env).should eq 3 }
  end
end

describe 'cond' do
  before do
    @env = [USchemeR::KEYWORDS, USchemeR::FUNCS]
  end

  context 'match first' do
    it { eval('(cond (true 1) (false 2) (else 3))', @env).should eq 1 }
  end

  context 'match second' do
    it { eval('(cond (false 1) (true 2) (else 3))', @env).should eq 2 }
  end

  context 'not match' do
    it { eval('(cond (false 1) (false 2) (else 3))', @env).should eq 3 }
  end
end
