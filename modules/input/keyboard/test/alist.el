;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/alist.el

;;------------------------------------------------------------------------------
;; Test Requirements
;;------------------------------------------------------------------------------

;;---
;; Testing Files:
;;---
(imp:test:load :filename "base.el")

;;---
;; Keyboard Files:
;;---
(imp:test:load :feature:post '(:input keyboard alist)
               :filename     "../alist.el")


;;------------------------------------------------------------------------------
;; Test Debugging Helpers
;;------------------------------------------------------------------------------

;;------------------------------
;; Global Scoped Variable
;;------------------------------

(setq test<keyboard/alist>:alist/nil    nil)
(setq test<keyboard/alist>:alist/values nil)

(defun test<keyboard/alist>:alist:get (type &optional local-symbol-name)
  "Function call that will return something based on TYPE.

TYPE:
  - :local
    + Returns LOCAL-SYMBOL-NAME.
  - :global/nil
    + Returns `test<keyboard/alist>:alist/nil'.
  - :global/values
    + Returns `test<keyboard/alist>:alist/values'.


Usage:
  (test<keyboard/alist>:alist:get :global)
    -> `test<keyboard/alist>:alist'
  (test<keyboard/alist>:alist:get :local 'some-local-symbol-name)
    -> `some-local-symbol-name'"
  (cond ((eq type :local)
         local-symbol-name)
        ((eq type :global/nil)
         'test<keyboard/alist>:alist/nil)
        ((eq type :global/values)
         'test<keyboard/alist>:alist/values)
        (t
         (should-not "wrong input, idiot."))))
;; (test<keyboard/alist>:alist:get :global/values)
;; (let ((alist/local '((:k . :v)))) (test<keyboard/alist>:alist:get :local 'alist/local))


;;------------------------------
;; Set-Up / Tear-Down
;;------------------------------

(defun test<keyboard/alist>:setup (_)
  "Create a global-scoped alist (as opposed to function scoped w/ `let') for some tests to use."
  (setq test<keyboard/alist>:alist/values (list (cons :key-0 :value-0/initial)
                                                (cons :key-1 :value-1/initial)
                                                (cons :key-2 :value-2/initial)
                                                (cons :key-3 :value-3/initial)
                                                (cons :key-4 :value-4/initial)
                                                (cons :key-5 :value-5/initial)))
  (setq test<keyboard/alist>:alist/nil nil)
  ;; (message "setup: %S" test<keyboard/alist>:alist)
  )

(defun test<keyboard/alist>:teardown (test-name)
  "Leave the global-scoped alists hanging around w/ whatever values tests modified to?"
  ;; (makunbound 'test<keyboard/alist>:alist)
  ;; (unintern 'test<keyboard/alist>:alist)
  ;; (message "teardown: %S" (condition-case _
  ;;                             test<keyboard/alist>:alist
  ;;                           (void-variable "<void>")))
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
;; int<keyboard>:alist:alist?
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:alist:alist? ()
  "Test that `int<keyboard>:alist:alist?' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:alist:alist?"
      nil
      nil

    ;;===
    ;; Run the test.
    ;;===
    (let ((alist/cons (list (cons :key-0 :value-0)
                            (cons :key-1 :value-1)
                            (cons :key-2 :value-2)))
          (alist/list (list (list :key-0 :value-0)
                            (list :key-1 :value-1)
                            (list :key-2 :value-2))))

      ;;------------------------------
      ;; Not alists.
      ;;------------------------------
      (should-not (int<keyboard>:alist:alist? t))
      (should-not (int<keyboard>:alist:alist? :jeff))
      (should-not (int<keyboard>:alist:alist? #'ignore))
      (should-not (int<keyboard>:alist:alist? 'some-symbol))

      ;; Quoting our vars is just providing a symbol name, which is
      ;; not providing an alist to the predicate function.
      (should-not (int<keyboard>:alist:alist? 'alist/cons))
      (should-not (int<keyboard>:alist:alist? 'alist/list))

      ;;------------------------------
      ;; Are alists.
      ;;------------------------------
      ;; `nil' is a valid (empty) list, and empty lists are valid alists.
      (should (int<keyboard>:alist:alist? nil))

      ;; Our alist vars should be alists.
      (should (int<keyboard>:alist:alist? alist/cons))
      (should (int<keyboard>:alist:alist? alist/list))

      ;; Alists themselves should also be alists.
      (should (int<keyboard>:alist:alist? (list (cons :key-0 :value-0)
                                                (cons :key-1 :value-1)
                                                (cons :key-2 :value-2))))
      (should (int<keyboard>:alist:alist? (list (list :key-0 :value-0)
                                                (list :key-1 :value-1)
                                                (list :key-2 :value-2))))

      ;; Alists which have more than one thing as the value: still alists.
      (should (int<keyboard>:alist:alist? (list (cons :key-0 '(:value-00 :value-01 :value-02))
                                                (cons :key-1 '(:value-11 :value-11 :value-12))
                                                (cons :key-2 '(:value-22 :value-21 :value-22)))))
      (should (int<keyboard>:alist:alist? (list (list :key-0 :value-00 :value-01 :value-02)
                                                (list :key-1 :value-11 :value-11 :value-12)
                                                (list :key-2 :value-22 :value-21 :value-22)))))))


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
;; int<keyboard>:alist:update - local alist (defined in a `let')
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:alist:update::local ()
  "Test that `int<keyboard>:alist:update' will add/overwrite values in a local alist correctly."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:alist:update::local"
      nil
      nil

    ;;===
    ;; Run the test.
    ;;===
    (let ((alist/cons (list (cons :key-0 :value-0/initial)
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
;; int<keyboard>:alist:update - non-local alist
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:alist:update::global ()
  "Test that `int<keyboard>:alist:update' will add/overwrite values in a global alist correctly."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:alist:update::global"
      (lambda (_)
        "Set up globals for this test."
        (setq test<keyboard/alist>:alist/cons (list (cons :key-0 :value-0/initial)
                                                    (cons :key-1 :value-1/initial)
                                                    (cons :key-2 :value-2/initial)))
        (setq test<keyboard/alist>:alist/list (list (list :key-0 :value-0/initial)
                                                    (list :key-1 :value-1/initial)
                                                    (list :key-2 :value-2/initial)))
        )
      (lambda (_)
        "Clean up the alist of lists."
        ;; (unintern test<keyboard/alist>:alist/cons)
        ;; (unintern test<keyboard/alist>:alist/list)
        )

    ;;===
    ;; Run the test.
    ;;===
    (let* (alist/updated
           value/get)

      ;;------------------------------
      ;; Add new key/values.
      ;;------------------------------
      (should-not (int<keyboard>:alist:get/value :key-3 test<keyboard/alist>:alist/cons))
      (should-not (int<keyboard>:alist:get/value :key-3 test<keyboard/alist>:alist/list))

      (test<keyboard>:should:marker test-name "cons: New Key/Value")
      (setq alist/updated (int<keyboard>:alist:update :key-3 :value-3/new test<keyboard/alist>:alist/cons))
      (should alist/updated)

      ;; Our return value should be our alist.
      (should (eq alist/updated test<keyboard/alist>:alist/cons))
      (setq value/get (int<keyboard>:alist:get/value :key-3 test<keyboard/alist>:alist/cons))
      (should value/get)
      (should (keywordp value/get))
      (should (eq value/get :value-3/new))

      (test<keyboard>:should:marker test-name "list: New Key/Value")
      ;; Add the new value as a list, since it's the `test<keyboard/alist>:alist/list'.
      (setq alist/updated (int<keyboard>:alist:update :key-3 '(:value-3/new) test<keyboard/alist>:alist/list))
      (should alist/updated)
      ;; Our return value should be our alist.
      (should (eq alist/updated test<keyboard/alist>:alist/list))
      (setq value/get (int<keyboard>:alist:get/value :key-3 test<keyboard/alist>:alist/list))
      (should value/get)
      (should (listp value/get))
      (should (= 1 (length value/get)))
      (setq value/get (nth 0 value/get))
      (should (keywordp value/get))
      (should (eq value/get :value-3/new))

      ;;------------------------------
      ;; Update existing key's value.
      ;;------------------------------
      (let ((value/cons (int<keyboard>:alist:get/value :key-0 test<keyboard/alist>:alist/cons))
            (value/list (int<keyboard>:alist:get/value :key-0 test<keyboard/alist>:alist/list)))
        (should value/cons)
        (should value/list)
        (should (eq value/cons :value-0/initial))
        (should (equal value/list '(:value-0/initial)))

        (test<keyboard>:should:marker test-name "cons: Update Existing Key/Value")
        (setq alist/updated (int<keyboard>:alist:update :key-0 :value-0/updated test<keyboard/alist>:alist/cons))
        (should alist/updated)
        ;; Our return value should be our alist.
        (should (eq alist/updated test<keyboard/alist>:alist/cons))
        (setq value/get (int<keyboard>:alist:get/value :key-0 test<keyboard/alist>:alist/cons))
        (should value/get)
        (should (keywordp value/get))
        (should (eq value/get :value-0/updated))

        (test<keyboard>:should:marker test-name "list: Update Existing Key/Value")
        ;; Add the new value as a list, since it's the `test<keyboard/alist>:alist/list'.
        (setq alist/updated (int<keyboard>:alist:update :key-0 '(:value-0/updated) test<keyboard/alist>:alist/list))
        (should alist/updated)
        ;; Our return value should be our alist.
        (should (eq alist/updated test<keyboard/alist>:alist/list))
        (setq value/get (int<keyboard>:alist:get/value :key-0 test<keyboard/alist>:alist/list))
        (should value/get)
        (should (listp value/get))
        (should (= 1 (length value/get)))
        (setq value/get (nth 0 value/get))
        (should (keywordp value/get))
        (should (eq value/get :value-0/updated))))))


;;------------------------------
;; int<keyboard>:alist:delete - local alist (defined in a `let')
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:alist:delete::local ()
  "Test that `int<keyboard>:alist:delete' will delete keys from the alist correctly."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:alist:delete::local"
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


;;------------------------------
;; int<keyboard>:alist:delete - global alist
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:alist:delete::global ()
  "Test that `int<keyboard>:alist:delete' will delete keys from the alist correctly."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:alist:delete::global"
      (lambda (_)
        "Set up globals for this test."
        (setq test<keyboard/alist>:alist/cons (list (cons :key-0 :value-0/initial)
                                                    (cons :key-1 :value-1/initial)
                                                    (cons :key-2 :value-2/initial)))
        (setq test<keyboard/alist>:alist/list (list (list :key-0 :value-0/initial)
                                                    (list :key-1 :value-1/initial)
                                                    (list :key-2 :value-2/initial)))
        )
      (lambda (_)
        "Clean up the alist of lists."
        ;; (unintern test<keyboard/alist>:alist/cons)
        ;; (unintern test<keyboard/alist>:alist/list)
        )

    ;;===
    ;; Run the test.
    ;;===
    (let* (alist/deleted)

      ;;------------------------------
      ;; Delete keys from the alists.
      ;;------------------------------
      (test<keyboard>:should:marker test-name "cons: `:key-0'")
      (setq alist/deleted (int<keyboard>:alist:delete :key-0 test<keyboard/alist>:alist/cons))
      (should alist/deleted)
      ;; Our return value should be our alist.
      (should (eq alist/deleted test<keyboard/alist>:alist/cons))
      (should-not (int<keyboard>:alist:get/value :key-0 test<keyboard/alist>:alist/cons))

      (test<keyboard>:should:marker test-name "list: `:key-0'")
      (setq alist/deleted (int<keyboard>:alist:delete :key-0 test<keyboard/alist>:alist/list))
      (should alist/deleted)
      ;; Our return value should be our alist.
      (should (eq alist/deleted test<keyboard/alist>:alist/list))
      (should-not (int<keyboard>:alist:get/value :key-0 test<keyboard/alist>:alist/list)))))


;;------------------------------------------------------------------------------
;; Tests: Regression Tests
;;----------
;; Test that bugs don't resurface.
;;------------------------------------------------------------------------------

;;------------------------------
;; int<keyboard>:alist:update
;;------------------------------

(ert-deftest test<keyboard/alist>::int<keyboard>:alist:update::regression/call-for-alist ()
  "Test that `int<keyboard>:alist:update' can work if you use a macro call that
returns a symbol-name as a parameter.

Bug came from:
  (int<keyboard>:layout:unbind :debug :testing :common '(:n \"s\" :layout:common:undefined))

----------

[BUG]:
  Calling with a function call (that returns an alist's symbol name) raises an error.

[FIX]:
  - Simplified macros for update and delete a lot: moved updating/deleting to a
    helper function and macro just saves results back to provided symbol."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:alist:update::regression/call-for-alist"
      #'test<keyboard/alist>:setup
      #'test<keyboard/alist>:teardown

    ;;===
    ;; Run the test.
    ;;===
    (should test<keyboard/alist>:alist/values)
    (should-error alist/values)

    (let* ((alist/values (list (cons :key-0 :value-0/initial)
                               (cons :key-1 :value-1/initial)
                               (cons :key-2 :value-2/initial)))
           (alist/nil nil))

      ;;------------------------------
      ;; Update should work when passing in the symbol itself.
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
                                          test<keyboard/alist>:alist/values))

      ;;------------------------------
      ;; Update should work w/ a macro call which returns the symbol name.
      ;;------------------------------
      (should (eq 'alist/values
                  (test<keyboard/alist>:alist:get :local 'alist/values)))
      (should (eq 'test<keyboard/alist>:alist/nil
                  (test<keyboard/alist>:alist:get :global/nil)))
      (should (eq 'test<keyboard/alist>:alist/values
                  (test<keyboard/alist>:alist:get :global/values)))

      ;; Dunno how to get lexicals to work? :(
      (should-error (int<keyboard>:alist:update :key-3
                                                :value-3/07
                                                (test<keyboard/alist>:alist:get :local 'alist/values)))

      ;; Should update a list if given the values variable name.
      (should (int<keyboard>:alist:update :key-3
                                          :value-3/08
                                          (test<keyboard/alist>:alist:get :global/values)))
      (should (eq :value-3/08
                  (int<keyboard>:alist:get/value :key-3 test<keyboard/alist>:alist/values)))

      ;; Should create a list if given the nil variable name.
      (should (eq nil
                  test<keyboard/alist>:alist/nil))
      (should (int<keyboard>:alist:update :key-3
                                          :value-3/09
                                          (test<keyboard/alist>:alist:get :global/nil)))
      (should (eq :value-3/09
                  (int<keyboard>:alist:get/value :key-3 test<keyboard/alist>:alist/nil))))))


;;------------------------------------------------------------------------------
;; Tests: String 'alist' Functions
;;------------------------------------------------------------------------------
;; Currently there are no tests as there are no 'alist/string' functions
;; defined/in-use.
;;------------------------------
