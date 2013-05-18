require 'strscan'
require './token'

class Tokenizer
  def initialize
    @pattern_operations = []
    yield self if block_given?
  end

  def match(pattern, &operation)
    @pattern_operations.push [pattern, operation]
  end

  def scan(string)
    @tokens = []
    scanner = StringScanner.new(string)
    until scanner.eos?
      matched = false
      @pattern_operations.each do |pattern_operaion|
        pattern, operation = pattern_operaion
        val = scanner.scan(pattern)
        if val then
          token = operation.call(val)
          @tokens.push(token) if token
          matched = true
          break
        end
      end
      unless matched
        raise "invalid token error"
      end
    end
    @tokens
  end
end

class Lexer
  def initialize(stream)
    @stream = stream
    @tokens = []

    @tokenizer = Tokenizer.new do |t|
      t.match(/\s+/) do |val|
        # skip
      end

      t.match(/(?:(?:-?[1-9][0-9]*)|0)(?:\.[0-9]+)?/) do |val|
        Token.new(:numeric, eval(val))
      end

      t.match(/"([^"]*)"/) do |val|
        Token.new(:string, val[1..-2])
      end

      t.match(/\(|\)/) do |val|
        Token.new(val.to_sym)
      end

      t.match(/[^\s\(\)]+/) do |val|
        Token.new(:ident, :"#{val}")
      end
    end
  end

  def get_token
    if @tokens.empty? then
      read_tokens
    end
    @tokens.shift
  end

  def read_tokens
    while @tokens.empty?
      line = @stream.readline.chomp
      next if line.empty?
      @tokens = @tokenizer.scan(line)
    end
  end

  def unget_token(token)
    @tokens.unshift(token)
  end
end
