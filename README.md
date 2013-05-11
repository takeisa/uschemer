# uschemer

Micro Scheme on Ruby

## Sample code
<pre>
eval_print("
(letrec ((fact 
         (lambda (x)
                 (if (= x 0)
                     1
                     (* x (fact (- x 1)))))))
  (fact 10))
")
(letrec ((fact 
         (lambda (x)
                 (if (= x 0)
                     1
                     (* x (fact (- x 1)))))))
  (fact 10))
 #=> 3628800
</pre>