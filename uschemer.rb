#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

module USchemeR
    FUNCS = {
      :+ => [:built_in, lambda {|x, y| x + y}],
      :- => [:built_in, lambda {|x, y| x - y}],
      :* => [:built_in, lambda {|x, y| x * y}],
      :/ => [:built_in, lambda {|x, y| x / y}]
    }

  class << self
    def eval(exp, env)
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
      if lambda?(exp) then
        eval_lambda(exp, env)
      elsif let?(exp) then
        eval_let(exp, env)
      end
    end

    def eval_lambda(exp, env)
      create_closure(exp, env)
    end

    def create_closure(exp, env)
      params, body = lambda_to_params_body(exp)
      [:closure, params, body, env]
    end

    def lambda_to_params_body(exp)
      [exp[1], exp[2]]
    end

    def eval_let(exp, env)
      params, body, values = let_to_params_body_values(exp)
      new_exp = [[:lambda, params, body], *values]
      eval(new_exp, env)
    end

    def let_to_params_body_values(exp)
      bind_list = exp[1]
      params = bind_list.map {|bind| bind[0]}
      values = bind_list.map {|bind| bind[1]}
      body = exp[2]
      [params, body, values]
    end

    def special_form?(exp)
      lambda?(exp) || let?(exp)
    end

    def lambda?(exp)
      car(exp) == :lambda
    end

    def let?(exp)
      car(exp) == :let
    end

    def immidiate_value?(exp)
      number?(exp)
    end

    def lookup_var(exp, env)
      var_hash = env.find {|h| h.key?(exp)}
      if var_hash.nil? then
        raise "undefined variable: #{exp}"
      end
      var_hash[exp]
    end

    def eval_func(exp, env)
      func = eval(car(exp), env)
      if func.nil? then
        raise "call nil func: #{exp}"
      end

      args = eval_list(cdr(exp), env)

      if built_in?(func) then
        func_apply(func, args)
      else
        lambda_apply(func, args)
      end
    end

    def built_in?(func)
      func[0] == :built_in
    end

    def func_apply(func, args)
      func[1].call(*args)
    end

    def lambda_apply(func, args)
      params, body, env = closure_params_body_env(func)
      new_env = extend_env(params, args, env)
      eval(body, new_env)
    end

    def closure_params_body_env(func)
      func[1..3]
    end

    def extend_env(params, args, env)
      bind_hash = create_bind_hash(params, args)
      [bind_hash] + env
    end

    def create_bind_hash(params, args)
      bind_list = params.zip(args)
      bind_hash = {}
      bind_list.each do |bind|
        bind_hash[bind[0]] = bind[1]
      end
      bind_hash
    end

    def eval_list(list, env)
      list.map {|item| eval(item, env)}
    end

    def list?(exp)
      exp.is_a?(Array)
    end

    def number?(value)
      value.is_a?(Numeric)
    end

    def car(exp)
      exp[0]
    end

    def cdr(exp)
      exp[1..-1]
    end

    def parse(sexp)
      sexp.gsub!(/[_a-zA-Z\+\*\-\/][_a-zA-Z0-9\+\*\-\/]*/, ':\\0')
      sexp.gsub!(/\s+/, ',')
      sexp.gsub!(/\(/, '[')
      sexp.gsub!(/\)/, ']')
      Kernel.eval(sexp)
    end
  end
end

# test code

require "pp"

def eval_print(sexp, env)
  print sexp
  result = USchemeR.eval(USchemeR.parse(sexp), env)
  print " #=> "
  print PP.pp(result, '')
  print "\n"
end

env = [USchemeR::FUNCS]

eval_print("(let ((a 1) (b 1)) (+ a b))", env)
eval_print("(let ((a 1)) (lambda (x) (+ a x)))", env)
eval_print("((let ((a 1)) (lambda (x) (+ a x))) 2)", env)
