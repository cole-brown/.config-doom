;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/layout/+layout/base.el


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
(test<keyboard>:utils/path:load "layout/types/define.el")
(test<keyboard>:utils/path:load "layout/bind.el")
(test<keyboard>:utils/path:load "layout/bind-debug.el")
(test<keyboard>:utils/path:load "layout/derive.el")
(test<keyboard>:utils/path:load "layout/layout.el")


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst test<keyboard/layout/+layout>:layout/keyword nil
  "Layout being tested.")
;; (setq test<keyboard/layout/+layout>:layout/keyword :spydez)


;;------------------------------------------------------------------------------
;; Set-Up / Tear-Down
;;------------------------------------------------------------------------------

(defun test<keyboard/layout/+layout>:setup (test-name layout)
  "Set-up for 'layout/+<layout>/*.el' tests."
  ;; Clear out all vars of all registrars.
  (dolist (cons/registrar->vars int<keyboard>:registrars)
    (let ((registrar (car cons/registrar->vars))
          (vars      (cdr cons/registrar->vars)))
      (dolist (cons/keyword->symbol vars)
        (let ((keyword (car cons/keyword->symbol)))
          (int<keyboard>:registrar:set registrar keyword nil)))))

  ;; Define the types and their keywords.
  (test<keyboard>:utils/path:load "layout/types/common.el")
  (test<keyboard>:utils/path:load "layout/types/emacs.el")
  (test<keyboard>:utils/path:load "layout/types/evil.el")

  ;; Set the layout if it's valid.
  (setq int<keyboard>:layout:desired nil) ;; Unset desired so `int<keyboard>:layout:valid?' is checking less.
  (should (int<keyboard>:layout:valid? layout))
  (setq test<keyboard/layout/+layout>:layout/keyword layout)
  (setq int<keyboard>:layout:desired layout))
;; (test<keyboard/layout/+layout>:setup "test" :jeff)


(defun test<keyboard/layout/+layout>:teardown (test-name)
  "Tear-down for 'layout/+<layout>/*.el' tests."
  (test<keyboard/layout>:setup test-name))


;;------------------------------------------------------------------------------
;; Initialization / Configuration
;;------------------------------------------------------------------------------

;;------------------------------
;; Initialize unbinds/keybinds.
;;------------------------------

(defun test<keyboard/layout/+layout>:init (layout)
  "Load LAYOUT's 'init.el' file."
  (should (eq int<keyboard>:testing:disable-start-up-init nil))
  ;; Initialize the binds; should return truthy to indicate it loaded a file.
  (should (int<keyboard>:load:file layout "init"))

  ;; Did we set the keyboard layout and state?
  (should (eq int<keyboard>:layout:desired
              layout))
  (should (eq int<keyboard>:layout:desired
              int<keyboard>:layout:active))
  (should (eq (int<keyboard>:registrar:get :actual :state)
              :init))

  ;; Do we have something in binds and unbinds?
  (should (int<keyboard>:registrar:get :actual :unbinds))
  (should (int<keyboard>:registrar:get :actual :keybinds)))


;;------------------------------
;; Configure unbinds/keybinds.
;;------------------------------

(defun test<keyboard/layout/+layout>:config (layout)
  "Load LAYOUT's 'config.el' file."
  ;; Configure the binds; should return truthy to indicate it loaded a file.
  (should (int<keyboard>:load:file layout "config"))
  ;; Did we set the keyboard layout and state?
  (should (eq int<keyboard>:layout:desired
              layout))
  (should (eq int<keyboard>:layout:desired
              int<keyboard>:layout:active))
  (should (eq (int<keyboard>:registrar:get :actual :state)
              :config))

  ;; Do we have something in binds and unbinds?
  (should (int<keyboard>:registrar:get :actual :unbinds))
  (should (int<keyboard>:registrar:get :actual :keybinds)))
