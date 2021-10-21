;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/alist.el

;;------------------------------------------------------------------------------
;; Test Debugging Helpers
;;------------------------------------------------------------------------------

;;---
;; Testing Files:
;;---
(load! "base.el")

;;---
;; Keyboard Files:
;;---
(load! "../output.el")
(load! "../debug.el")
;; (load! "../load.el")
(load! "../alist.el")


;;------------------------------------------------------------------------------
;; Test Variables: Alist
;;------------------------------------------------------------------------------

;; TODO: delete if none

;;------------------------------------------------------------------------------
;; Test Helpers: Alist
;;------------------------------------------------------------------------------

;;------------------------------
;; Set-Up / Tear-Down
;;------------------------------

(defun test<keyboard/alist>:setup (test-name)
  "Set-up for 'alist.el' tests."
  )


(defun test<keyboard/alist>:teardown (test-name)
  "Tear-down for 'alist.el' tests."
  )


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠═════════════════════╤═══════╧═══════════╧════════╤════════════════════════╣
;; ╟─────────────────────┤ Input: Keyboards & Layouts ├────────────────────────╢
;; ╚═════════════════════╧════════════════════════════╧════════════════════════╝


;;------------------------------------------------------------------------------
;; Tests: Standard/General 'alist' Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<keyboard>:alist:get/value
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:alist:get/value ()
  "Test that `int<keyboard>:alist:get/value' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:alist:get/value"
      #'test<keyboard/alist>:setup
      #'test<keyboard/alist>:teardown

    ;;===
    ;; Run the test.
    ;;===
    (let* ((value/expected:0 "42")
           (value/expected:1 :1337)
           (value/expected:2 9001)
           (alist/cons (list (cons :key-0 value/expected:0)
                             (cons :key-1 value/expected:1)
                             (cons :key-2 value/expected:2)))
           (alist/list (list (list :key-0 value/expected:0)
                             (list :key-1 value/expected:1)
                             (list :key-2 value/expected:2)))
           value/get)

      ;;------------------------------
      ;; Check the 'cons' alist.
      ;;------------------------------
      (test<keyboard>:should:marker test-name "cons: key-0")
      (setq value/get (int<keyboard>:alist:get/value :key-0 alist/cons))
      (should value/get)
      (should (stringp value/get))
      (should (string= value/get value/expected:0))

      (test<keyboard>:should:marker test-name "cons: key-1")
      (setq value/get (int<keyboard>:alist:get/value :key-1 alist/cons))
      (should value/get)
      (should (keywordp value/get))
      (should (eq value/get value/expected:1))

      (test<keyboard>:should:marker test-name "cons: key-2")
      (setq value/get (int<keyboard>:alist:get/value :key-2 alist/cons))
      (should value/get)
      (should (integerp value/get))
      (should (= value/get value/expected:2))

      ;;------------------------------
      ;; Check the 'list' alist.
      ;;------------------------------
      (test<keyboard>:should:marker test-name "list: key-0")
      (setq value/get (int<keyboard>:alist:get/value :key-0 alist/list))
      (should value/get)
      (should (listp value/get))
      (should (= 1 (length value/get)))
      (setq value/get (nth 0 value/get))
      (should (stringp value/get))
      (should (string= value/get value/expected:0))

      (test<keyboard>:should:marker test-name "list: key-1")
      (setq value/get (int<keyboard>:alist:get/value :key-1 alist/list))
      (should value/get)
      (should (listp value/get))
      (should (= 1 (length value/get)))
      (setq value/get (nth 0 value/get))
      (should (keywordp value/get))
      (should (eq value/get value/expected:1))

      (test<keyboard>:should:marker test-name "list: key-2")
      (setq value/get (int<keyboard>:alist:get/value :key-2 alist/list))
      (should value/get)
      (should (listp value/get))
      (should (= 1 (length value/get)))
      (setq value/get (nth 0 value/get))
      (should (integerp value/get))
      (should (= value/get value/expected:2)))))


;;------------------------------
;; int<keyboard>:alist:get/pair
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:alist:get/pair ()
  "Test that `int<keyboard>:alist:get/pair' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:alist:get/pair"
      #'test<keyboard/alist>:setup
      #'test<keyboard/alist>:teardown

    ;;===
    ;; Run the test.
    ;;===
    (let* ((value/expected:0 "42")
           (value/expected:1 :1337)
           (value/expected:2 9001)
           (alist/cons (list (cons :key-0 value/expected:0)
                             (cons :key-1 value/expected:1)
                             (cons :key-2 value/expected:2)))
           (alist/list (list (list :key-0 value/expected:0)
                             (list :key-1 value/expected:1)
                             (list :key-2 value/expected:2)))
           value/get
           value/get:key
           value/get:value)

      ;;------------------------------
      ;; Check the 'cons' alist.
      ;;------------------------------
      (let ((expected:key  :key-0)
            (expected:value value/expected:0))
        (test<keyboard>:should:marker test-name "cons: key-0")
        (setq value/get (int<keyboard>:alist:get/pair expected:key alist/cons))
        (should value/get)
        (should (consp value/get))
        (should (listp value/get)) ;; Cons are also lists.
        (setq value/get:key   (car value/get)
              value/get:value (cdr value/get))
        (should (keywordp value/get:key))
        (should (eq value/get:key expected:key))
        (should (stringp value/get:value))
        (should (string= value/get:value expected:value)))

      (let ((expected:key  :key-1)
            (expected:value value/expected:1))
        (test<keyboard>:should:marker test-name "cons: key-1")
        (setq value/get (int<keyboard>:alist:get/pair expected:key alist/cons))
        (should value/get)
        (should (consp value/get))
        (should (listp value/get)) ;; Cons are also lists.
        (setq value/get:key   (car value/get)
              value/get:value (cdr value/get))
        (should (keywordp value/get:key))
        (should (eq value/get:key expected:key))
        (should (keywordp value/get:value))
        (should (eq value/get:value expected:value)))

      (let ((expected:key  :key-2)
            (expected:value value/expected:2))
        (test<keyboard>:should:marker test-name "cons: key-2")
        (setq value/get (int<keyboard>:alist:get/pair expected:key alist/cons))
        (should value/get)
        (should (consp value/get))
        (should (listp value/get)) ;; Cons are also lists.
        (setq value/get:key   (car value/get)
              value/get:value (cdr value/get))
        (should (keywordp value/get:key))
        (should (eq value/get:key expected:key))
        (should (integerp value/get:value))
        (should (= value/get:value expected:value)))

      ;;------------------------------
      ;; Check the 'list' alist.
      ;;------------------------------
      (let ((expected:key  :key-0)
            (expected:value value/expected:0))
        (test<keyboard>:should:marker test-name "list: key-0")
        (setq value/get (int<keyboard>:alist:get/pair expected:key alist/list))
        (should value/get)
        (should (listp value/get))
        (setq value/get:key   (nth 0 value/get)
              value/get:value (nth 1 value/get))
        (should (keywordp value/get:key))
        (should (eq value/get:key expected:key))
        (should (stringp value/get:value))
        (should (string= value/get:value expected:value)))

      (let ((expected:key :key-1)
            (expected:value value/expected:1))
        (test<keyboard>:should:marker test-name "list: key-1")
        (setq value/get (int<keyboard>:alist:get/pair expected:key alist/list))
        (should value/get)
        (should (listp value/get))
        (setq value/get:key   (nth 0 value/get)
              value/get:value (nth 1 value/get))
        (should (keywordp value/get:key))
        (should (eq value/get:key expected:key))
        (should (keywordp value/get:value))
        (should (eq value/get:value expected:value)))

      (let ((expected:key :key-2)
            (expected:value value/expected:2))
        (test<keyboard>:should:marker test-name "list: key-2")
        (setq value/get (int<keyboard>:alist:get/pair expected:key alist/list))
        (should value/get)
        (should (listp value/get))
        (setq value/get:key   (nth 0 value/get)
              value/get:value (nth 1 value/get))
        (should (keywordp value/get:key))
        (should (eq value/get:key expected:key))
        (should (integerp value/get:value))
        (should (= value/get:value expected:value))))))


;;------------------------------------------------------------------------------
;; Tests: String 'alist' Functions
;;------------------------------------------------------------------------------
;; Currently there are no tests as there are no 'alist/string' functions
;; defined/in-use.
;;------------------------------
