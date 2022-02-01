;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/layout/types/base.el


;;------------------------------------------------------------------------------
;; Load all files tested by tests up above.
;;------------------------------------------------------------------------------

;;---
;; Testing Files:
;;---
(imp:test:load :filename "../base.el")


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------


;;------------------------------------------------------------------------------
;; Set-Up / Tear-Down
;;------------------------------------------------------------------------------

(defun test<keyboard/layout/types>:setup (_)
  "Set-up for 'layout/types/*.el' tests."
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


(defun test<keyboard/layout/types>:teardown (test-name)
  "Tear-down for 'layout/types/*.el' tests."
  )


;;------------------------------------------------------------------------------
;; Test Helpers
;;------------------------------------------------------------------------------

