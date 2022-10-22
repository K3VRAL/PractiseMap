;; TODO load C library https://z0ltan.wordpress.com/2016/09/16/interop-mini-series-calling-c-and-c-code-from-common-lisp-using-cffi-part-1/
;; TODO load C library with shell command `pkg-config` https://stackoverflow.com/questions/3019142/running-shell-commands-with-gnu-clisp
(load "~/quicklisp/setup.lisp")
(ql:quickload :cffi) 
(defpackage :libosu-cffi
	(:use :cl :cffi)
)
(in-package :libosu-cffi)
(define-foreign-library libosu
	(:unix (run-program "pkg-config" :arguments '("--libs" "libosu")))
)
(use-foreign-library libosu)

(require "src/arguments.lisp")
(require "src/practise.lisp")

(defun main ()
	(arguments)
	(practise)
)

(main)