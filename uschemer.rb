#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

module USchemeR
  class << self
    FUNCS = {
      :+ => lambda {|x, y| x + y},
      :- => lambda {|x, y| x - y},
      :* => lambda {|x, y| x * y},
      :/ => lambda {|x, y| x / y}
    }

    def eval(exp)
      if list?(exp)
        eval_func(exp)
      else
        eval_value(exp)
      end
    end

    def eval_func(exp)
      args = eval_args(cdr(exp))
      func = eval(car(exp))
      apply_func(func, args)
    end

    def apply_func(func, args)
      func.call(*args)
    end

    def eval_value(value)
      if number?(value)
        value
      else
        find_func(value)
      end
    end

    def eval_args(args)
      args.map {|arg| eval(arg)}
    end

    def find_func(symbol)
      FUNCS[symbol]
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
  end
end

# test code

require "pp"

def eval_print(exp)
  print PP.pp(exp, '').chomp
  result = USchemeR.eval(exp)
  print " #=> "
  print PP.pp(result, '')
  print "\n"
end

eval_print(1)

eval_print(:+)

eval_print([:+, 1, 2])

eval_print([:+, [:+, 1, 2], [:+, 3, 4]])



