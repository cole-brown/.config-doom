;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/alist.el

;;------------------------------------------------------------------------------
;; Test Requirements
;;------------------------------------------------------------------------------

;;---
;; Testing Files:
;;---
(load! "base.el")

;;---
;; Keyboard Files:
;;---
;; (load! "../vars.el")
;; (load! "../load.el")
(load! "../alist.el")


;;------------------------------------------------------------------------------
;; Test Debugging Helpers
;;------------------------------------------------------------------------------

;;------------------------------
;; Global Scoped Variable
;;------------------------------

(setq test<keyboard/alist>:alist nil)

(defun test<keyboard/alist>:alist:get (arg &optional local-symbol-name)
  "Function call that will return `test<keyboard/alist>:alist' symbol-name.

Usage:
  (test<keyboard/alist>:alist:get :valid/global)
    -> `test<keyboard/alist>:alist'
  (test<keyboard/alist>:alist:get :invalid/local 'some-local-symbol-name)
    -> `some-local-symbol-name'"
  (cond ((eq type :invalid/local)
         local-symbol-name)
        ((eq type :valid/global)
         'test<keyboard/alist>:alist)
        (t
         (should-not "wrong input, idiot."))))


;;------------------------------
;; Set-Up / Tear-Down
;;------------------------------

(defun test<keyboard/alist>:setup (_)
  "Create a global-scoped alist (as opposed to function scoped w/ `let') for some tests to use."
  (setq test<keyboard/alist>:alist (list (cons :key-0 :value-0/initial)
                                         (cons :key-1 :value-1/initial)
                                         (cons :key-2 :value-2/initial)
                                         (cons :key-3 :value-3/initial)
                                         (cons :key-4 :value-4/initial)
                                         (cons :key-5 :value-5/initial)))
  (message "setup: %S" test<keyboard/alist>:alist)
  )

(defun test<keyboard/alist>:teardown (test-name)
  "Delete the global-scoped alist."
  (makunbound 'test<keyboard/alist>:alist)
  ;; (unintern 'test<keyboard/alist>:alist)
  (message "teardown: %S" (condition-case _
                              test<keyboard/alist>:alist
                            (void-variable "<void>")))
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
;; int<keyboard>:alist:get/alist
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:alist:get/alist ()
  "Test that `int<keyboard>:alist:get/alist' will find the alist correctly."

  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:alist:update"
      #'test<keyboard/alist>:setup
      #'test<keyboard/alist>:teardown

    ;;===
    ;; Run the test.
    ;;===
    ;; Should have our non-lexical variable.
    (should test<keyboard/alist>:alist)

    ;; Should have some lexical variables as well.
    (let* ((alist/nil nil)
           (alist/cons (list (cons :key-0 :value-0/initial)
                             (cons :key-1 :value-1/initial)
                             (cons :key-2 :value-2/initial)))
           (symbol/alist 'test<keyboard/alist>:alist)
           (alist-fn/get-symbol-name (lambda (type)
                                       (cond ((eq type :invalid/lexical)
                                              'alist/cons)
                                             ((eq type :valid/dynamic)
                                              'test<keyboard/alist>:alist)
                                             (t
                                              (error "wrong input, idiot."))))))
      ;;------------------------------
      ;; Alist-by-Value
      ;;------------------------------
      (should (eq nil
                  (int<keyboard>:alist:get/alist alist/nil)))
      (should (eq alist/cons
                  (int<keyboard>:alist:get/alist alist/cons)))

      ;;------------------------------
      ;; Alist-by-Symbol
      ;;------------------------------
      (should (eq test<keyboard/alist>:alist
                  (int<keyboard>:alist:get/alist symbol/alist)))

      ;;------------------------------
      ;; Alist-by-Function
      ;;------------------------------
      ;; Funcall returns a lexical variable, which shouldn't be in the scope of `int<keyboard>:alist:get/alist', so it should error.
      (should-error (int<keyboard>:alist:get/alist (funcall alist-fn/get-symbol-name :invalid/lexical)))

      ;; Funcall returns a dynamic variable, which should be visible to `int<keyboard>:alist:get/alist', so it should _not_ error.
      ;; Should return the correct list of values for us to compare.
      (should (eq test<keyboard/alist>:alist
                  (int<keyboard>:alist:get/alist (funcall alist-fn/get-symbol-name :valid/dynamic)))))))


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
;; Tests: Regression Tests
;;----------
;; Test that bugs don't resurface.
;;------------------------------------------------------------------------------

;;------------------------------
;; int<keyboard>:alist:update
;;----------
;; [BUG]:
;;   Calling with a function call (that returns an alist's symbol name) raises an error.
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:alist:update::regression/func-call-for-alist ()
  "Test that `int<keyboard>:alist:update' can work if you use a function call that
returns a symbol-name as a parameter.

Bug example:
  (int<keyboard>:layout:unbind :debug :testing :common '(:n \"s\" :layout:common:undefined))
Becomes:
  (int<keyboard>:alist:update :common
                              '(:n \"s\" :layout:common:undefined)
                              (int<keyboard>:registrar:symbol :debug :unbinds))
[BUG]: Resulted in error message:
  \"if: Wrong type argument: listp, int<keyboard>:registrar<debug>:unbinds\"

[DESIRED]: Should act the same as providing an alist symbol:
(let ((alist nil))
  (int<keyboard>:alist:update :common
                              '(:n \"s\" :layout:common:undefined)
                              alist))"
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:alist:update"
      #'test<keyboard/alist>:setup
      #'test<keyboard/alist>:teardown

    (message "test: %S" test<keyboard/alist>:alist)

    ;;===
    ;; Run the test.
    ;;===
    (should test<keyboard/alist>:alist)
    (let* ((alist/values (list (cons :key-0 :value-0/initial)
                               (cons :key-1 :value-1/initial)
                               (cons :key-2 :value-2/initial)))
           (alist/nil nil)
           (alist-fn/get-symbol-name (lambda (type)
                                       (cond ((eq type :invalid/local)
                                              'alist/cons)
                                             ((eq type :valid/global)
                                              'test<keyboard/alist>:alist)
                                             (t
                                              (error "wrong input, idiot."))))))

      ;;------------------------------
      ;; Update should work w/ symbols, with lists as values.
      ;;------------------------------
      (should (int<keyboard>:alist:update :key-3
                                          :value-3/00
                                          ;; Passes in value of `alist/values'.
                                          alist/values))
      (should (int<keyboard>:alist:update :key-3
                                          :value-3/01
                                          ;; Passes in value of `alist/nil'.
                                          alist/nil))
      (should (int<keyboard>:alist:update :key-3
                                          :value-3/02
                                          ;; Passes in value of `alist/nil'.
                                          test<keyboard/alist>:alist))

      ;;------------------------------
      ;; Update should work w/ symbol, with symbols as values, with lists as values.
      ;;------------------------------

      ;; This should be effectively the same as passing in the funcall, so it should be allowed.
      (let ((alist/symbol/invalid (funcall alist-fn/get-symbol-name :invalid/local))
            (alist/symbol/valid (funcall alist-fn/get-symbol-name :valid/global)))
        (should-error (int<keyboard>:alist:update :key-3
                                                  :value-3/03
                                                  ;; Passes in symbol-name: `alist/cons'.
                                                  alist/symbol/invalid))
        (should (int<keyboard>:alist:update :key-3
                                            :value-3/04
                                            ;; Passes in symbol-name: `test<keyboard/alist>:alist'.
                                            alist/symbol/valid)))

      ;;------------------------------
      ;; Update should error w/ function call to local lambda.
      ;;   - Macro has no access to the local lambda?
      ;;------------------------------
      ;; Should error on not having access to the actual lambda.
      (should-error (int<keyboard>:alist:update :key-3
                                                  :value-3/05
                                                  ;; Passes in function that will return symbol-name `alist/cons'.
                                                  (funcall #'alist-fn/get-symbol-name :invalid/local)))
      ;; Should error on not having access to the actual lambda.
      (should-error (int<keyboard>:alist:update :key-3
                                                :value-3/06
                                                ;; Passes in function that will return symbol-name `test<keyboard/alist>:alist'.
                                                (funcall #'alist-fn/get-symbol-name :invalid/local)))

      ;;------------------------------
      ;; Update should work w/ function calls, with symbols as return values, with lists as values.
      ;;------------------------------
      )))
;; (defun test<keyboard/alist>:alist:get (arg &optional local-symbol-name)
;; ;; This is how the bug was found... and it should now work.
;;       (should (int<keyboard>:alist:update :key-3
;;                                           :value-3/06
;;                                           ;; Passes in function that will return symbol-name `test<keyboard/alist>:alist'.
;;                                           (funcall #'alist-fn/get-symbol-name :invalid/local)))


;;------------------------------------------------------------------------------
;; Tests: String 'alist' Functions
;;------------------------------------------------------------------------------
;; Currently there are no tests as there are no 'alist/string' functions
;; defined/in-use.
;;------------------------------
