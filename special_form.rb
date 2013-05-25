module USchemeR
  class BaseEval
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
    
    def bind_list_to_params_values(bind_list)
      params = bind_list.map {|bind| bind[0]}
      values = bind_list.map {|bind| bind[1]}
      [params, values]
    end

    def car(exp)
      exp[0]
    end
    
    def cdr(exp)
      exp[1..-1]
    end

    def list?(exp)
      exp.is_a?(Array)
    end
  end

  class LambdaEval < BaseEval
    def eval(exp, env, exp_eval)
      create_closure(exp, env)
    end
    
    def create_closure(exp, env)
      params, body = lambda_to_params_body(exp)
      [:closure, params, body, env]
    end
    
    def lambda_to_params_body(exp)
      [exp[1], exp[2]]
    end
  end

  class LetEval < BaseEval
    def eval(exp, env, exp_eval)
      params, values, body = let_to_params_values_body(exp)
      new_exp = [[:lambda, params, body], *values]
      exp_eval.eval(new_exp, env)
    end
    
    def let_to_params_values_body(exp)
      bind_list = exp[1]
      params, values = bind_list_to_params_values(bind_list)
      body = exp[2]
      [params, values, body]
    end
  end

  class LetrecEval < BaseEval
    def eval(exp, env, exp_eval)
      params, values, body = letrec_to_params_values_body(exp)
      closures = values.map {|value| exp_eval.eval(value, env)}
      new_env = extend_env(params, closures, env)
      bind_hash = car(new_env)
      closures.each {|closure| extend_closure_env!(closure, bind_hash)}
      exp_eval.eval(body, new_env)
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
  end

  class DefineEval < BaseEval
    def eval(exp, env, exp_eval)
      if define_with_param?(exp) then
        var, val = define_with_param_to_var_val(exp)
      else
        var, val = define_to_var_val(exp)
      end
      val = exp_eval.eval(val, env)
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
  end
  
  class IfEval < BaseEval
    def eval(exp, env, exp_eval)
      test_form, then_form, else_form = if_to_test_then_else(exp)
      if exp_eval.eval(test_form, env) then
        exp_eval.eval(then_form, env)
      else
        exp_eval.eval(else_form, env)
      end
    end
    
    def if_to_test_then_else(exp)
      [exp[1], exp[2], exp[3]]
    end
  end

  class CondEval < BaseEval
    def eval(exp, env, exp_eval)
      pred_exp_list = cond_to_pre_exp_list(exp)
      pred_exp_list.each do |pred_exp|
        pred, exp = pred_exp
        if pred == :else || exp_eval.eval(pred, env) then
          return exp_eval.eval(exp, env)
        end
      end
      raise "cond: not match conditions"
    end
    
    def cond_to_pre_exp_list(exp)
      exp[1..-1]
    end
  end

  class AndEval < BaseEval
    def eval(exp, env, exp_eval)
      exp_list = and_to_exp_list(exp)
      last_exp = nil
      exp_list.each do |exp|
        last_exp = exp_eval.eval(exp, env)
        return false unless last_exp
      end
      last_exp
    end

    def and_to_exp_list(exp)
      exp[1..-1]
    end
  end

  class OrEval < BaseEval
    def eval(exp, env, exp_eval)
      exp_list = or_to_exp_list(exp)
      exp_list.each do |exp|
        last_exp = exp_eval.eval(exp, env)
        return last_exp if last_exp
      end
      false
    end

    def or_to_exp_list(exp)
      exp[1..-1]
    end
  end

  class NotEval < BaseEval
    def eval(exp, env, exp_eval)
      exp = not_to_exp(exp)
      not exp_eval.eval(exp, env)
    end

    def not_to_exp(exp)
      exp[1]
    end
  end
end
