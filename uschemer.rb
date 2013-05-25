#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'stringio'
require './parser'
require './special_form'

module USchemeR
  DEBUG = false
  
  FUNCS = {
    :+ => [:primitive, lambda {|*xs| xs.reduce(0) {|a, x| a + x}}],
    :- => [:primitive, lambda {|*xs| if xs.size == 1 then -xs[0] else xs.reduce {|a, x| a - x} end}],
    :* => [:primitive, lambda {|*xs| xs.reduce(1) {|a, x| a * x}}],
    :'/' => [:primitive, lambda {|*xs| if xs.size == 1 then 1 / xs[0] else xs.reduce {|a, x| a / x} end}],
    :'=' => [:primitive, lambda {|x, y| x == y}],
    :< => [:primitive, lambda {|x, y| x < y}],
    :> => [:primitive, lambda {|x, y| x > y}],
    :<= => [:primitive, lambda {|x, y| x <= y}],
    :>= => [:primitive, lambda {|x, y| x >= y}]
  }
  
  KEYWORDS = {
    :true => true,
    :false => false
  }

  SP_FORM_EVAL = {
    :lambda => LambdaEval.new,
    :let => LetEval.new,
    :letrec => LetrecEval.new,
    :define => DefineEval.new,
    :if => IfEval.new,
    :cond => CondEval.new,
    :and => AndEval.new,
    :or => OrEval.new,
    :not => NotEval.new
  }

  class Eval < BaseEval
    def eval(exp, env)
      if DEBUG then
        print "eval\n"
        print "  env=" + PP.pp(env[0..-3], '')
        print "  exp=" + PP.pp(exp, '')
      end
      if list?(exp)
        if special_form?(exp) then
          eval_special_form(exp, env)
        else
          eval_func(exp, env)
        end
      else
        if immidiate_value?(exp) then
          exp
        else
          lookup_var(exp, env)
        end
      end
    end
    
    def eval_special_form(exp, env)
      eval_obj = SP_FORM_EVAL[car(exp)]
      eval_obj.eval(exp, env, self)
    end
    
    def special_form?(exp)
      SP_FORM_EVAL.has_key?(car(exp))
    end
    
    def immidiate_value?(exp)
      number?(exp) || string?(exp)
    end
    
    def lookup_var(exp, env)
      var_hash = env.find {|h| h.key?(exp)}
      if var_hash.nil? then
        raise "undefined variable: #{exp}"
      end
      var_hash[exp]
    end
    
    def eval_func(exp, env)
      if DEBUG then
        print "eval_func\n"
      end
      func = eval(car(exp), env)
      if func.nil? then
        raise "call nil func: #{exp}"
      end
      
      args = eval_list(cdr(exp), env)
      
      if primitive?(func) then
        func_apply(func, args)
      else
        lambda_apply(func, args)
      end
    end
    
    def primitive?(func)
      func[0] == :primitive
    end
    
    def func_apply(func, args)
      func[1].call(*args)
    end
    
    def lambda_apply(func, args)
      params, body, env = closure_to_params_body_env(func)
      new_env = extend_env(params, args, env)
      if DEBUG then
        print "lambda_apply\n"
        print "  new_env=" + PP.pp(new_env[0..-3], '')
        print "  closure:params=" + PP.pp(params, '')
        print "  closure:body=" + PP.pp(body, '')
        print "  closure:env=" + PP.pp(env[0..-3], '')
      end
      eval(body, new_env)
    end
    
    def closure_to_params_body_env(func)
      func[1..3]
    end
    
    def eval_list(list, env)
      list.map {|item| eval(item, env)}
    end
    
    def number?(value)
      value.is_a?(Numeric)
    end
    
    def string?(value)
      value.is_a?(String)
    end
  end

  class << self
    def parse_string(string)
      Parser.new(Lexer.new(StringIO.new(string))).parse
    end
  end
end
