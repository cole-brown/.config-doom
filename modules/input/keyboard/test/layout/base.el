;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/layout/base.el


;;------------------------------------------------------------------------------
;; Load all files tested by tests one folder up.
;;------------------------------------------------------------------------------

;;---
;; Testing Files:
;;---
(load! "../base.el")

;;---
;; Keyboard Files:
;;---
(load! "../../output.el")
(load! "../../debug.el")
(load! "../../utils.el")
(load! "../../alist.el")
(load! "../../vars.el")
(load! "../../load.el")
(load! "../../alist.el")
(load! "../../registrars.el")


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst test<keyboard/layout>:registrar :debug
  "Always use the debug registar in the layout tests.")


;;------------------------------------------------------------------------------
;; Set-Up / Tear-Down
;;------------------------------------------------------------------------------

(defun test<keyboard/layout>:setup (_)
  "Set-up for 'layout/*.el' tests."
  ;; Start off in a fresh state.
  (int<keyboard>:registrar:set test<keyboard/layout>:registrar
                               :state
                               nil)
  (int<keyboard>:registrar:set test<keyboard/layout>:registrar
                               :keybinds
                               nil)
  (int<keyboard>:registrar:set test<keyboard/layout>:registrar
                               :unbinds
                               nil))


(defun test<keyboard/layout>:teardown (test-name)
  "Tear-down for 'layout/*.el' tests."
  )


;;------------------------------------------------------------------------------
;; Test Helpers
;;------------------------------------------------------------------------------

(defun test<keyboard/layout>:bind:vars-to-binds (type binds)
  "Turns bind vars you supply to e.g. `int<keyboard>:layout:bind' into an alist
you can use in `test<keyboard/layout>:assert:registrar-vars'.

Does not check for duplicate keys in the binds cons."
  ;; The `binds' should be a list and not a cons.
  (should (listp binds))
  ;; Unfortunately, can't use `consp' since lists are cons? So how do you...
  (should (proper-list-p binds)) ;; Oh elisp... the fuck are you drinking?

  ;; Create an alist from the type and the binds.
  ;; Does not check for duplicate keys.
  (list (cons type binds)))
;; (test<keyboard/layout>:bind:vars-to-binds :common '(:n "s" :keyword))
;; (test<keyboard/layout>:bind:vars-to-binds :common '(:v "a" #'function))


(defun test<keyboard/layout>:assert:registrar-vars (test-name &optional state keybinds unbinds)
  "Assert all the registrar variables are `equal' to the parameters."

  (test<keyboard>:should:marker test-name "Assert registar variables.")

  (should (equal state
                 (int<keyboard>:registrar:get test<keyboard/layout>:registrar
                                              :state)))
  (should (equal keybinds
                 (int<keyboard>:registrar:get test<keyboard/layout>:registrar
                                              :keybinds)))
  (should (equal unbinds
                 (int<keyboard>:registrar:get test<keyboard/layout>:registrar
                                              :unbinds))))
