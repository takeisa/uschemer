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

