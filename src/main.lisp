(require "src/arguments.lisp")
(require "src/practise.lisp")

(defun main ()
	(arguments)
	(format t "~S ~S ~d ~d ~d ~d ~d ~%" *input* *output* *start* *end* *rng* *hardrock* *begobj*)
	(practise)
)

(main)