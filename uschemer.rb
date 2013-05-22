#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'stringio'
require './parser'

class USchemeR
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
  
  class Eval
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
      if lambda?(exp) then
        eval_lambda(exp, env)
      elsif let?(exp) then
        eval_let(exp, env)
      elsif if?(exp) then
        eval_if(exp, env)
      elsif letrec?(exp) then
        eval_letrec(exp, env)
      elsif define?(exp) then
        eval_define(exp, env)
      elsif cond?(exp) then
        eval_cond(exp, env)
      elsif and?(exp) then
        eval_and(exp, env)
      elsif or?(exp) then
        eval_or(exp, env)
      elsif not?(exp) then
        eval_not(exp, env)
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
      params, values, body = let_to_params_values_body(exp)
      new_exp = [[:lambda, params, body], *values]
      eval(new_exp, env)
    end
    
    def let_to_params_values_body(exp)
      bind_list = exp[1]
      params, values = bind_list_to_params_values(bind_list)
      body = exp[2]
      [params, values, body]
    end
    
    def eval_if(exp, env)
      test_form, then_form, else_form = if_to_test_then_else(exp)
      if eval(test_form, env) then
        eval(then_form, env)
      else
        eval(else_form, env)
      end
    end
    
    def if_to_test_then_else(exp)
      [exp[1], exp[2], exp[3]]
    end
    
    def eval_letrec(exp, env)
      params, values, body = letrec_to_params_values_body(exp)
      closures = values.map {|value| eval(value, env)}
      new_env = extend_env(params, closures, env)
      
      bind_hash = car(new_env)
      closures.each {|closure| extend_closure_env!(closure, bind_hash)}
      
      eval(body, new_env)
    end
    
    def extend_closure_env!(closure, bind_hash)
      closure_env = closure[3]
      closure_env.push(bind_hash)
    end
    
    def letrec_to_params_values_body(exp)
      bind_list = exp[1]
      params, values = bind_list_to_params_values(bind_list)
      body = exp[2]
      [params, values, body]
    end
    
    def bind_list_to_params_values(bind_list)
      params = bind_list.map {|bind| bind[0]}
      values = bind_list.map {|bind| bind[1]}
      [params, values]
    end
    
    def eval_define(exp, env)
      if define_with_param?(exp) then
        var, val = define_with_param_to_var_val(exp)
      else
        var, val = define_to_var_val(exp)
      end
      val = eval(val, env)
      define!(var, val, env)
      [var, val]
    end
    
    def define_with_param?(exp)
      list?(exp[1])
    end
    
    def define_with_param_to_var_val(exp)
      var = car(exp[1])
      params = exp[1][1..-1]
      body = exp[2]
      val = [:lambda, params, body]
      [var, val]
    end
    
    def define_to_var_val(exp)
      var = exp[1]
      val = exp[2]
      [var, val]
    end
    
    def define!(var, val, env)
      bind_hash = lookup_bind_hash(var, env)
      if bind_hash.nil? then
        extend_env!([var], [val], env)
      else
        bind_hash[var] = val
      end
    end
    
    def lookup_bind_hash(var, env)
      env.find{|h| h.key?(var)}
    end
    
    def extend_env!(vars, vals, env)
      bind_hash = create_bind_hash(vars, vals)
      env.unshift(bind_hash)
    end
    
    def eval_cond(exp, env)
      pred_exp_list = cond_to_pre_exp_list(exp)
      pred_exp_list.each do |pred_exp|
        pred, exp = pred_exp
        if pred == :else || eval(pred, env) then
          return eval(exp, env)
        end
      end
      raise "cond: not match conditions"
    end
    
    def cond_to_pre_exp_list(exp)
      exp[1..-1]
    end

    def eval_and(exp, env)
      exp_list = and_to_exp_list(exp)
      last_exp = nil
      exp_list.each do |exp|
        last_exp = eval(exp, env)
        return false unless last_exp
      end
      last_exp
    end

    def and_to_exp_list(exp)
      exp[1..-1]
    end
    
    def eval_or(exp, env)
      exp_list = or_to_exp_list(exp)
      exp_list.each do |exp|
        last_exp = eval(exp, env)
        return last_exp if last_exp
      end
      false
    end

    def or_to_exp_list(exp)
      exp[1..-1]
    end

    def eval_not(exp, env)
      exp = not_to_exp(exp)
      not eval(exp, env)
    end

    def not_to_exp(exp)
      exp[1]
    end

    def special_form?(exp)
      lambda?(exp) || let?(exp) || if?(exp) || letrec?(exp) || 
        define?(exp) || cond?(exp) || and?(exp) || or?(exp) || not?(exp)
    end
    
    def lambda?(exp)
      car(exp) == :lambda
    end
    
    def let?(exp)
      car(exp) == :let
    end
    
    def if?(exp)
      car(exp) == :if
    end
    
    def letrec?(exp)
      car(exp) == :letrec
    end
    
    def define?(exp)
      car(exp) == :define
    end
    
    def cond?(exp)
      car(exp) == :cond
    end
    
    def and?(exp)
      car(exp) == :and
    end

    def or?(exp)
      car(exp) == :or
    end

    def not?(exp)
      car(exp) == :not
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
    
    def string?(value)
      value.is_a?(String)
    end
    
    def car(exp)
      exp[0]
    end
    
    def cdr(exp)
      exp[1..-1]
    end
  end

  class << self
    def parse_string(string)
      Parser.new(Lexer.new(StringIO.new(string))).parse
    end
  end
end
