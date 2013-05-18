#!/usr/bin/env ruby

require './parser'

def test_lexer
  lexer = Lexer.new(STDIN)
  
  while TRUE do
    token = lexer.get_token
    print "token=[#{token}]\n"
  end
end

parser = Parser.new(Lexer.new(STDIN))
p parser.parse

# require 'stringio'

# parser = Parser.new(Lexer.new(StringIO.new('(hello 1 "hello" 3)')))
# p parser.parse
