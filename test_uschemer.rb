#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# test code

require "./uschemer"
require "stringio"
require "pp"

@env = [USchemeR::KEYWORDS, USchemeR::FUNCS]

def eval_print(string)
  print string
  parser = Parser.new(Lexer.new(StringIO.new(string)))
  exp = parser.parse
# p exp
# p @env
  result = USchemeR.eval(exp, @env)
  print " ;=> "
  print PP.pp(result, '')
  print "\n"
end

def test_parse_stdin
  print Parser.new(Lexer.new(STDIN)).parse
end

eval_print("
(define (abs x)
  (cond ((< x 0) (* -1 x))
        ((= x 0) 0)
        (else x)))
")

eval_print("
(abs -10)
")

eval_print("
(abs 0)
")

eval_print("
(abs 10)
")


# test_parse_stdin

# eval_print("
# (define (hello) \"こんにちは、世界\")
# ")

# eval_print("
# (hello)
# ")

# eval_print("
# (define Y
#   (lambda (f)
#     ((lambda (g)
#        (f (lambda (arg) ((g g) arg))))
#      (lambda (g)
#        (f (lambda (arg) ((g g) arg)))))))
# ")

# eval_print("
# (define fact
#   (lambda (f)
#     (lambda (n)
#       (if (= n 0)
#           1
#           (* n (f (- n 1)))))))
# ")

# eval_print("
# ((Y fact) 10)
# ")

# eval_print("
# (define one 1)
# ")

# eval_print("
# one
# ")

# eval_print("
# (define (fact n)
#   (if (= n 0)
#       1
#       (* n (fact (- n 1)))))
# ")

# eval_print("
# (fact 10)
# ")

# eval_print("
# (define (fib n)
#   (if (<= n 2)
#       1
#       (+ (fib (- n 2)) (fib (- n 1)))))
# ")

# eval_print("
# (fib 15)
# ")

# eval_print("
# (letrec ((fact 
#          (lambda (x)
#                  (if (= x 0)
#                      1
#                      (* x (fact (- x 1)))))))
#   (fact 10))
# ")

# eval_print("
# (letrec ((fact 
#          (lambda (x)
#                  (if (= x 0)
#                      1
#                      (* x (fact (- x 1)))))))
#   (fact 100))
# ")
