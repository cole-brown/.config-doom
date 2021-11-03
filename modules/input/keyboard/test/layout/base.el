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
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst test<keyboard/layout>:registrar :debug
  "Always use the debug registar in the layout tests.")


(defvar test<keyboard/layout>:bind:counter nil
  "Alist for counting calls to keybind test functions.")


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


;;------------------------------------------------------------------------------
;; Keybind Functions
;;------------------------------------------------------------------------------

(defun test<keyboard/layout>:bind:count/get (call/keyword)
  "Get the current call count for CALL/KEYWORD keyword from `test<keyboard/layout>:bind:counter' alist."
  ;; Always return a number, so 0 if not found.
  (or (int<keyboard>:alist:get/value call/keyword
                                     test<keyboard/layout>:bind:counter)
      0))
;; (setq test<keyboard/layout>:bind:counter nil)
;; test<keyboard/layout>:bind:counter
;; (test<keyboard/layout>:bind:count/get :test)
;; (setq test<keyboard/layout>:bind:counter '((:test . 42)))
;; (test<keyboard/layout>:bind:count/get :test)


(defun test<keyboard/layout>:bind:count/increment (call/keyword)
  "Increment count for CALL/KEYWORD keyword in `test<keyboard/layout>:bind:counter' alist."
  ;; Get & increment.
  (let ((count/updated (1+ (test<keyboard/layout>:bind:count/get call/keyword))))
    ;; Set new value.
    (int<keyboard>:alist:update call/keyword
                                count/updated
                                test<keyboard/layout>:bind:counter)
    ;; Return the current count
    count/updated))


(defun test<keyboard/layout>:bind:count/00 ()
  "A function to keybind for counting calls to it."
  (test<keyboard/layout>:bind:count/increment :count/00))
;; (setq test<keyboard/layout>:bind:counter nil)
;; test<keyboard/layout>:bind:counter
;; (test<keyboard/layout>:bind:count/00)
;; test<keyboard/layout>:bind:counter


(defun test<keyboard/layout>:bind:count/01 ()
  "A function to keybind for counting calls to it."
  (test<keyboard/layout>:bind:count/increment :count/01))


(defun test<keyboard/layout>:bind:count/02 ()
  "A function to keybind for counting calls to it."
  (test<keyboard/layout>:bind:count/increment :count/02 meb))


(defun test<keyboard/layout>:bind:make (test-name init? config? binds unbinds)
  "A function to create some keybinds to the count funcs.

Returns a cons of two lists to use in `test<keyboard/layout>:assert:registrar-vars'.
  cons is: '(binds . unbinds)"
  (let* ((registrar :debug)
         (layout    :testing)
         (type      :evil)
         (unbound   (if (null unbinds)
                        nil
                      (test<keyboard/layout>:bind:vars-to-binds type unbinds)))
         (bound     (if (null binds)
                        nil
                      (test<keyboard/layout>:bind:vars-to-binds type binds))))

    ;;------------------------------
    ;; Initialize the (un)binds.
    ;;------------------------------
    (when init?
      (let ((state/before nil)
            (state/after  :init))
        (test<keyboard/layout>:assert:registrar-vars
         test-name
         state/before
         nil
         nil)

        (when unbinds
          (test<keyboard>:should:marker test-name "Making unbinds.")
          (should (int<keyboard>:layout:unbind registrar
                                               layout
                                               type
                                               unbinds)))

        (when binds
          (test<keyboard>:should:marker test-name "Making binds.")
          (should (int<keyboard>:layout:bind registrar
                                             layout
                                             type
                                             binds)))

        (test<keyboard/layout>:assert:registrar-vars
         test-name
         state/after
         bound
         unbound)))

    ;;------------------------------
    ;; Configure the (un)binds.
    ;;------------------------------
    (when config?
      (let ((state/before :init)
            (state/after  :config)
            (bind/unbind  :full))
        ;; Config doesn't really do anything except the state change...
        (should (int<keyboard>:layout:config registrar
                                             bind/unbind
                                             layout))

        (test<keyboard/layout>:assert:registrar-vars
         test-name
         state/after
         bound
         unbound)))

    ;;------------------------------
    ;; Return what is (un)bound.
    ;;------------------------------
    (cons unbound bound)))
