;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/layout/spydez.el


;;------------------------------------------------------------------------------
;; Test Layout
;;------------------------------------------------------------------------------

;; For `cl-search' (searching for a subsequence in a sequence).
(require 'cl-seq)


;;---
;; Test Files:
;;---
;; "test/layout/base.el" will load "test/base.el" and all tested files from "test/__.el" level.
(load! "base.el")

;;---
;; Keyboard Layout Files:
;;---


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst test<keyboard/layout+layout>:cache:disable-start-up-init
  int<keyboard>:testing:disable-start-up-init
  "Save disable start-up init flag to restore after tests.")


;;------------------------------------------------------------------------------
;; Set-Up / Tear-Down
;;------------------------------------------------------------------------------

(defun test<keyboard/layout/+layout/spydez>:setup (test-name)
  "Set-up for 'layout/+<layout>/*.el' tests."
  (setq test<keyboard/layout+layout>:cache:disable-start-up-init
        int<keyboard>:testing:disable-start-up-init)
  ;; Make sure we're actually loading files...
  (setq int<keyboard>:testing:disable-start-up-init nil)
  ;; Clear out registrar vars for `test<keyboard/layout>:registrar' registrar.
  ;; Set `test<keyboard/layout/+layout>:layout/keyword' to `:spydez'.
  (test<keyboard/layout/+layout>:setup test-name :spydez))


(defun test<keyboard/layout/+layout/spydez>:teardown (test-name)
  "Tear-down for 'layout/+<layout>/*.el' tests."
  (setq int<keyboard>:testing:disable-start-up-init
        test<keyboard/layout+layout>:cache:disable-start-up-init)
  (test<keyboard/layout>:teardown test-name))


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠═════════════════════╤═══════╧═══════════╧════════╤════════════════════════╣
;; ╟─────────────────────┤ Input: Keyboards & Layouts ├────────────────────────╢
;; ╚═════════════════════╧════════════════════════════╧════════════════════════╝


;;------------------------------------------------------------------------------
;; Tests: init.el
;;------------------------------------------------------------------------------

;;------------------------------
;; Test that init.el creates unbinds & keybinds.
;;------------------------------

(ert-deftest test<keyboard>::layout/+spydez:init ()
  "Test the `:spydez' layout's init.el."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard>::layout/+spydez:init"
      ;; Clear out keybinds before test.
      #'test<keyboard/layout/+layout/spydez>:setup
      #'test<keyboard/layout/+layout/spydez>:teardown

    ;;===
    ;; Run the test.
    ;;===

    ;;------------------------------
    ;; Define unbinds/keybinds.
    ;;------------------------------

    (should (eq int<keyboard>:testing:disable-start-up-init nil))
    ;; Define the binds; should return truthy to indicate it loaded a file.
    (should (int<keyboard>:load:file :spydez "init"))

    ;; Did we set the keyboard layout and state?
    (should (eq int<keyboard>:layout:desired
                :spydez))
    (should (eq int<keyboard>:layout:desired
                int<keyboard>:layout:active))
    (should (eq (int<keyboard>:registrar:get :actual :state)
                :init))

    ;; Do we have something in binds and unbinds?
    (should (int<keyboard>:registrar:get :actual :unbinds))
    (should (int<keyboard>:registrar:get :actual :keybinds))

    ;;------------------------------
    ;; Check unbinds/keybinds.
    ;;------------------------------

    ;; Should have some evil unbinds & keybinds.
    (should (int<keyboard>:alist:get/value :evil (int<keyboard>:registrar:get :actual :unbinds)))
    (should (int<keyboard>:alist:get/value :evil (int<keyboard>:registrar:get :actual :keybinds)))

    ;; Find a particular unbind.
    ;; This one is a list in the main list, so we just have to search for it as an element in the unbinds.
    (let ((unbind/find '(:after evil-snipe
                         :map (evil-snipe-mode-map evil-snipe-local-mode-map)
                         :nvm "s" :layout:common:undefined))
          (unbinds/evil (int<keyboard>:alist:get/value :evil
                                                       (int<keyboard>:registrar:get :actual :unbinds))))
      (should (seq-reduce (lambda (reduction unbind)
                            "Check for specific `unbind' in unbinds."
                            (or reduction
                                (equal unbind unbind/find)))
                          unbinds/evil
                          nil)))

    ;; Find a particular keybind.
    ;; This one should just be a sequence in the main list.
    (let ((keybind/find-seq '(:m (:derive 'shift :layout:evil:char-prev) :layout:evil:word-prev-end))
          (keybinds/evil (int<keyboard>:alist:get/value :evil
                                                        (int<keyboard>:registrar:get :actual :keybinds))))
      (should (cl-search keybind/find-seq keybinds/evil
                         :test #'equal)))))


;;------------------------------------------------------------------------------
;; Tests: config.el
;;------------------------------------------------------------------------------

;;------------------------------
;; Test that config.el applies unbinds & keybinds.
;;------------------------------

(ert-deftest test<keyboard>::layout/+spydez:config ()
  "Test the `:spydez' layout's config.el."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard>::layout/+spydez:config"
      ;; Clear out keybinds before test.
      #'test<keyboard/layout/+layout/spydez>:setup
      #'test<keyboard/layout/+layout/spydez>:teardown

    ;;===
    ;; Run the test.
    ;;===

    ;;------------------------------
    ;; Define unbinds/keybinds.
    ;;------------------------------

    ;; Define the binds; should return truthy to indicate it loaded a file.
    (should (int<keyboard>:load:file :spydez "init"))
    ;; Did we set the keyboard layout and state?
    (should (eq int<keyboard>:layout:desired
                :spydez))
    (should (eq int<keyboard>:layout:desired
                int<keyboard>:layout:active))
    (should (eq (int<keyboard>:registrar:get :actual :state)
                :init))

    ;; Configure the binds; should return truthy to indicate it loaded a file.
    (should (int<keyboard>:load:file :spydez "config"))
    ;; Did we set the keyboard layout and state?
    (should (eq int<keyboard>:layout:desired
                :spydez))
    (should (eq int<keyboard>:layout:desired
                int<keyboard>:layout:active))
    (should (eq (int<keyboard>:registrar:get :actual :state)
                :config))

    ;; Do we have something in binds and unbinds?
    (should (int<keyboard>:registrar:get :actual :unbinds))
    (should (int<keyboard>:registrar:get :actual :keybinds))

    ;;------------------------------
    ;; Test config-specific stuff.
    ;;------------------------------
    ;; ...currently there is nothing special for config.
    ;; Hopefully will change - would be nice to get rid of the finalize delay.
    ))


;;------------------------------------------------------------------------------
;; Tests: Finalize & Apply
;;------------------------------------------------------------------------------

;;------------------------------
;; Test that init'd & config'd keybinds can be applied.
;;------------------------------

;; TODO: This test.
