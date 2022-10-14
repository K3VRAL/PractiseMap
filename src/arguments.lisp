(defun arguments ()
	(defvar *input* NIL)
	(defvar *output* NIL)

	(defvar *start* 0)
	(defvar *end* 1)

	(defvar *rng* 0)
	(defvar *hardrock* 0)
	(defvar *begobj* 0)

	#+CLISP *args*

	(defvar *set_arg* NIL)
	(loop for i in *args* do
		(if (equal NIL *set_arg*)
			(progn
				(if (or (equal "-i" i) (equal "--input" i))
					(setf *set_arg* "i")
				)

				(if (or (equal "-o" i) (equal "--output" i))
					(setf *set_arg* "o")
				)
				
				(if (or (equal "-s" i) (equal "--start" i))
					(setf *set_arg* "s")
				)
				
				(if (or (equal "-e" i) (equal "--end" i))
					(setf *set_arg* "e")
				)
				
				(if (or (equal "-r" i) (equal "--rng" i))
					(setf *rng* 1)
				)
				
				(if (or (equal "-h" i) (equal "--hardrock" i))
					(setf *hardrock* 1)
				)
				
				(if (or (equal "-b" i) (equal "--beginning-objects" i))
					(setf *set_arg* "b")
				)
			)
			(progn
				(if (equal "i" *set_arg*)
					(setf *input* i)
				)

				(if (equal "o" *set_arg*)
					(setf *output* i)
				)
				
				(if (equal "s" *set_arg*)
					(setf *start* (parse-integer i))
				)
				
				(if (equal "e" *set_arg*)
					(setf *end* (parse-integer i))
				)
				
				(if (equal "b" *set_arg*)
					(setf *begobj* (parse-integer i))
				)
				
				(setf *set_arg* NIL)
			)
		)
	)
)