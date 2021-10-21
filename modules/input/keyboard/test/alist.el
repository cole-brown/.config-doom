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
      nil
      nil

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
      nil
      nil

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


;;------------------------------
;; int<keyboard>:alist:update
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:alist:update ()
  "Test that `int<keyboard>:alist:update' will add/overwrite values in the alist correctly."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:alist:update"
      nil
      nil

    ;;===
    ;; Run the test.
    ;;===
    (let* ((alist/cons (list (cons :key-0 :value-0/initial)
                             (cons :key-1 :value-1/initial)
                             (cons :key-2 :value-2/initial)))
           (alist/list (list (list :key-0 :value-0/initial)
                             (list :key-1 :value-1/initial)
                             (list :key-2 :value-2/initial)))
           alist/updated
           value/get)

      ;;------------------------------
      ;; Add new key/values.
      ;;------------------------------
      (should-not (int<keyboard>:alist:get/value :key-3 alist/cons))
      (should-not (int<keyboard>:alist:get/value :key-3 alist/list))

      (test<keyboard>:should:marker test-name "cons: New Key/Value")
      (setq alist/updated (int<keyboard>:alist:update :key-3 :value-3/new alist/cons))
      (should alist/updated)
      ;; Our return value should be our alist.
      (should (eq alist/updated alist/cons))
      (setq value/get (int<keyboard>:alist:get/value :key-3 alist/cons))
      (should value/get)
      (should (keywordp value/get))
      (should (eq value/get :value-3/new))

      (test<keyboard>:should:marker test-name "list: New Key/Value")
      ;; Add the new value as a list, since it's the `alist/list'.
      (setq alist/updated (int<keyboard>:alist:update :key-3 '(:value-3/new) alist/list))
      (should alist/updated)
      ;; Our return value should be our alist.
      (should (eq alist/updated alist/list))
      (setq value/get (int<keyboard>:alist:get/value :key-3 alist/list))
      (should value/get)
      (should (listp value/get))
      (should (= 1 (length value/get)))
      (setq value/get (nth 0 value/get))
      (should (keywordp value/get))
      (should (eq value/get :value-3/new))

      ;;------------------------------
      ;; Update existing key's value.
      ;;------------------------------
      (let ((value/cons (int<keyboard>:alist:get/value :key-0 alist/cons))
            (value/list (int<keyboard>:alist:get/value :key-0 alist/list)))
        (should value/cons)
        (should value/list)
        (should (eq value/cons :value-0/initial))
        (should (equal value/list '(:value-0/initial)))

        (test<keyboard>:should:marker test-name "cons: Update Existing Key/Value")
        (setq alist/updated (int<keyboard>:alist:update :key-0 :value-0/updated alist/cons))
        (should alist/updated)
        ;; Our return value should be our alist.
        (should (eq alist/updated alist/cons))
        (setq value/get (int<keyboard>:alist:get/value :key-0 alist/cons))
        (should value/get)
        (should (keywordp value/get))
        (should (eq value/get :value-0/updated))

        (test<keyboard>:should:marker test-name "list: Update Existing Key/Value")
        ;; Add the new value as a list, since it's the `alist/list'.
        (setq alist/updated (int<keyboard>:alist:update :key-0 '(:value-0/updated) alist/list))
        (should alist/updated)
        ;; Our return value should be our alist.
        (should (eq alist/updated alist/list))
        (setq value/get (int<keyboard>:alist:get/value :key-0 alist/list))
        (should value/get)
        (should (listp value/get))
        (should (= 1 (length value/get)))
        (setq value/get (nth 0 value/get))
        (should (keywordp value/get))
        (should (eq value/get :value-0/updated))))))


;;------------------------------
;; int<keyboard>:alist:delete
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:alist:delete ()
  "Test that `int<keyboard>:alist:delete' will delete keys from the alist correctly."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:alist:delete"
      nil
      nil

    ;;===
    ;; Run the test.
    ;;===
    (let* ((alist/cons (list (cons :key-0 :value-0)
                             (cons :key-1 :value-1)
                             (cons :key-2 :value-2)))
           (alist/list (list (list :key-0 :value-0)
                             (list :key-1 :value-1)
                             (list :key-2 :value-2)))
           alist/deleted)

      ;;------------------------------
      ;; Delete keys from the alists.
      ;;------------------------------
      (test<keyboard>:should:marker test-name "cons: `:key-0'")
      (setq alist/deleted (int<keyboard>:alist:delete :key-0 alist/cons))
      (should alist/deleted)
      ;; Our return value should be our alist.
      (should (eq alist/deleted alist/cons))
      (should-not (int<keyboard>:alist:get/value :key-0 alist/cons))

      (test<keyboard>:should:marker test-name "list: `:key-0'")
      (setq alist/deleted (int<keyboard>:alist:delete :key-0 alist/list))
      (should alist/deleted)
      ;; Our return value should be our alist.
      (should (eq alist/deleted alist/list))
      (should-not (int<keyboard>:alist:get/value :key-0 alist/list)))))


;;------------------------------------------------------------------------------
;; Tests: String 'alist' Functions
;;------------------------------------------------------------------------------
;; Currently there are no tests as there are no 'alist/string' functions
;; defined/in-use.
;;------------------------------
