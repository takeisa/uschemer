require './lexer'

class Parser
  def initialize(lexer)
    @lexer = lexer
  end

  def parse
    parse_sexp
  end

  def parse_sexp
    parse_list || parse_atom
  end

  def parse_list
    token = @lexer.get_token
    unless token.type == :'('
      @lexer.unget_token(token)
      return nil
    end
    list = []
    while TRUE
      token = @lexer.get_token
      if token.type == :')' then
        return list
      end
      @lexer.unget_token(token)
      list.push(parse_sexp)
    end
    list
  end

  def parse_atom
    token = @lexer.get_token
    token.value
  end
end

