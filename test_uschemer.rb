#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# test code

require "./uschemer"
require "pp"

@env = [USchemeR::KEYWORDS, USchemeR::FUNCS]

def eval_print(string)
  print string
  exp = USchemeR.parse_string(string)
  eval = USchemeR::Eval.new
  result = eval.eval(exp, @env)
  print ";=> "
  print PP.pp(result, '')
  print "\n"
end

eval_print("
(define (fact n)
  (if (= n 0)
      1
      (* n (fact (- n 1)))))
")

eval_print("
(fact 1)
")
