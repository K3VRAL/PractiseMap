;; TODO load C library https://z0ltan.wordpress.com/2016/09/16/interop-mini-series-calling-c-and-c-code-from-common-lisp-using-cffi-part-1/
;; TODO load C library with shell command `pkg-config` https://stackoverflow.com/questions/3019142/running-shell-commands-with-gnu-clisp
;; (ql:quickload :cffi) 
;; (require 'cffi)
;; (defpackage :lisp-to-c-user
;; 	(:use :cl :cffi))
;; (in-package :lisp-to-c-user)
;; (define-foreign-library libsysteminfo
;; 	(:unix "libosu.so"))

(defun practise ()
	(format t "Hello ~%")
)