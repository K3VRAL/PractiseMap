(defun arguments ()
	(defvar *input* NIL)
	(defvar *output* NIL)

	(defvar *start* 0)
	(defvar *end* 1)

	(defvar *rng* 0)
	(defvar *hardrock* 0)
	(defvar *begobj_time_amount* (cons NIL NIL))

	#+CLISP *args*

	(defvar *set_arg* NIL)
	(loop for i in *args* do
		(if (equal NIL *set_arg*)
			(progn
				(if (or (equal "-i" i) (equal "--input" i))
					(setq *set_arg* "i")
				)

				(if (or (equal "-o" i) (equal "--output" i))
					(setq *set_arg* "o")
				)
				
				(if (or (equal "-s" i) (equal "--start" i))
					(setq *set_arg* "s")
				)
				
				(if (or (equal "-e" i) (equal "--end" i))
					(setq *set_arg* "e")
				)
				
				(if (or (equal "-r" i) (equal "--rng" i))
					(setq *rng* 1)
				)
				
				(if (or (equal "-h" i) (equal "--hardrock" i))
					(setq *hardrock* 1)
				)
				
				(if (or (equal "-b" i) (equal "--beginning-objects" i))
					(setq *set_arg* "b")
				)
			)
			(progn
				(if (not (equal "b" *set_arg*))
					(progn
						(if (equal "i" *set_arg*)
							(setq *input* i)
						)

						(if (equal "o" *set_arg*)
							(setq *output* i)
						)
						
						(if (equal "s" *set_arg*)
							(setq *start* (parse-integer i))
						)
						
						(if (equal "e" *set_arg*)
							(setq *end* (parse-integer i))
						)

						(setq *set_arg* NIL)
					)
					(if (equal "b" *set_arg*)
						(progn
							(if (equal NIL (car *begobj_time_amount*))
								(setq *begobj_time_amount* (cons (read (make-string-input-stream i)) NIL))
								(progn
									(setq *begobj_time_amount* (cons (car *begobj_time_amount*) (read (make-string-input-stream i))))
									(setq *set_arg* NIL)
								)
							)
						)
					)
				)
			)
		)
	)
)