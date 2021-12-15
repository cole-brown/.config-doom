;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; output/nub/test/alist.el

;;------------------------------------------------------------------------------
;; Test Requirements
;;------------------------------------------------------------------------------

(load! "base.el")


;;------------------------------------------------------------------------------
;; Test Debugging Helpers
;;------------------------------------------------------------------------------

;;------------------------------
;; Global Scoped Variable
;;------------------------------

(setq test<alist>:alist/nil    nil)
(setq test<alist>:alist/values nil)


(defun test<alist>:get (type &optional local-symbol-name)
  "Function call that will return some alist based on TYPE.

TYPE:
  - :local
    + Returns LOCAL-SYMBOL-NAME.
  - :global/nil
    + Returns `test<alist>:alist/nil'.
  - :global/values
    + Returns `test<alist>:alist/values'.

Usage:
  (test<alist>:get :global)
    -> `test<nub/alist>:alist'
  (test<alist>:get :local 'some-local-symbol-name)
    -> `some-local-symbol-name'"
  (cond ((eq type :local)
         local-symbol-name)
        ((eq type :global/nil)
         'test<alist>:alist/nil)
        ((eq type :global/values)
         'test<alist>:alist/values)
        (t
         (should-not "wrong input, idiot."))))
;; (test<alist>:get :global/values)
;; (let ((alist/local '((:k . :v)))) (test<alist>:get :local 'alist/local))


;;------------------------------
;; Set-Up / Tear-Down
;;------------------------------

(defun test<nub/alist>:setup (_)
  "Create a global-scoped alist (as opposed to function scoped w/ `let') for some tests to use."
  (setq test<alist>:alist/values (list (cons :key-0 :value-0/initial)
                                       (cons :key-1 :value-1/initial)
                                       (cons :key-2 :value-2/initial)
                                       (cons :key-3 :value-3/initial)
                                       (cons :key-4 :value-4/initial)
                                       (cons :key-5 :value-5/initial)))
  (setq test<alist>:alist/nil nil)
  ;; (message "setup: %S" test<nub/alist>:alist)
  )


(defun test<nub/alist>:teardown (test-name)
  "Leave the global-scoped alists hanging around w/ whatever values tests modified to?"
  ;; (makunbound 'test<nub/alist>:alist)
  ;; (unintern 'test<nub/alist>:alist)
  ;; (message "teardown: %S" (condition-case _
  ;;                             test<nub/alist>:alist
  ;;                           (void-variable "<void>")))
  )


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠══════════╤══════════════════╧═══════════╧══════════════════╤══════════════╣
;; ╟──────────┤ Because Emacs needs to give Alists some love... ├──────────────╢
;; ╚══════════╧═════════════════════════════════════════════════╧══════════════╝


;;------------------------------------------------------------------------------
;; Tests: Standard/General 'alist' Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; alist:alist?
;;------------------------------

(ert-deftest test<nub/alist>::alist:alist? ()
  "Test that `alist:alist?' behaves appropriately."
  (test<nub>:fixture
   ;;===
   ;; Test name, setup & teardown func.
   ;;===
   "test<nub/alist>::alist:alist?"
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
     (should-not (alist:alist? t))
     (should-not (alist:alist? :jeff))
     (should-not (alist:alist? #'ignore))
     (should-not (alist:alist? 'some-symbol))

     ;; Quoting our vars is just providing a symbol name, which is
     ;; not providing an alist to the predicate function.
     (should-not (alist:alist? 'alist/cons))
     (should-not (alist:alist? 'alist/list))

     ;;------------------------------
     ;; Are alists.
     ;;------------------------------
     ;; `nil' is a valid (empty) list, and empty lists are valid alists.
     (should (alist:alist? nil))

     ;; Our alist vars should be alists.
     (should (alist:alist? alist/cons))
     (should (alist:alist? alist/list))

     ;; Alists themselves should also be alists.
     (should (alist:alist? (list (cons :key-0 :value-0)
                                 (cons :key-1 :value-1)
                                 (cons :key-2 :value-2))))
     (should (alist:alist? (list (list :key-0 :value-0)
                                 (list :key-1 :value-1)
                                 (list :key-2 :value-2))))

     ;; Alists which have more than one thing as the value: still alists.
     (should (alist:alist? (list (cons :key-0 '(:value-00 :value-01 :value-02))
                                 (cons :key-1 '(:value-11 :value-11 :value-12))
                                 (cons :key-2 '(:value-22 :value-21 :value-22)))))
     (should (alist:alist? (list (list :key-0 :value-00 :value-01 :value-02)
                                 (list :key-1 :value-11 :value-11 :value-12)
                                 (list :key-2 :value-22 :value-21 :value-22)))))))


;;------------------------------
;; alist:get/value
;;------------------------------

(ert-deftest test<nub/alist>::alist:get/value ()
  "Test that `alist:get/value' behaves appropriately."
  (test<nub>:fixture
   ;;===
   ;; Test name, setup & teardown func.
   ;;===
   "test<nub/alist>::alist:get/value"
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
     (test<nub>:should:marker test-name "cons: key-0")
     (setq value/get (alist:get/value :key-0 alist/cons))
     (should value/get)
     (should (stringp value/get))
     (should (string= value/get value/expected:0))

     (test<nub>:should:marker test-name "cons: key-1")
     (setq value/get (alist:get/value :key-1 alist/cons))
     (should value/get)
     (should (keywordp value/get))
     (should (eq value/get value/expected:1))

     (test<nub>:should:marker test-name "cons: key-2")
     (setq value/get (alist:get/value :key-2 alist/cons))
     (should value/get)
     (should (integerp value/get))
     (should (= value/get value/expected:2))

     ;;------------------------------
     ;; Check the 'list' alist.
     ;;------------------------------
     (test<nub>:should:marker test-name "list: key-0")
     (setq value/get (alist:get/value :key-0 alist/list))
     (should value/get)
     (should (listp value/get))
     (should (= 1 (length value/get)))
     (setq value/get (nth 0 value/get))
     (should (stringp value/get))
     (should (string= value/get value/expected:0))

     (test<nub>:should:marker test-name "list: key-1")
     (setq value/get (alist:get/value :key-1 alist/list))
     (should value/get)
     (should (listp value/get))
     (should (= 1 (length value/get)))
     (setq value/get (nth 0 value/get))
     (should (keywordp value/get))
     (should (eq value/get value/expected:1))

     (test<nub>:should:marker test-name "list: key-2")
     (setq value/get (alist:get/value :key-2 alist/list))
     (should value/get)
     (should (listp value/get))
     (should (= 1 (length value/get)))
     (setq value/get (nth 0 value/get))
     (should (integerp value/get))
     (should (= value/get value/expected:2)))))


;;------------------------------
;; alist:get/pair
;;------------------------------

(ert-deftest test<nub/alist>::alist:get/pair ()
  "Test that `alist:get/pair' behaves appropriately."
  (test<nub>:fixture
   ;;===
   ;; Test name, setup & teardown func.
   ;;===
   "test<nub/alist>::alist:get/pair"
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
       (test<nub>:should:marker test-name "cons: key-0")
       (setq value/get (alist:get/pair expected:key alist/cons))
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
       (test<nub>:should:marker test-name "cons: key-1")
       (setq value/get (alist:get/pair expected:key alist/cons))
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
       (test<nub>:should:marker test-name "cons: key-2")
       (setq value/get (alist:get/pair expected:key alist/cons))
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
       (test<nub>:should:marker test-name "list: key-0")
       (setq value/get (alist:get/pair expected:key alist/list))
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
       (test<nub>:should:marker test-name "list: key-1")
       (setq value/get (alist:get/pair expected:key alist/list))
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
       (test<nub>:should:marker test-name "list: key-2")
       (setq value/get (alist:get/pair expected:key alist/list))
       (should value/get)
       (should (listp value/get))
       (setq value/get:key   (nth 0 value/get)
             value/get:value (nth 1 value/get))
       (should (keywordp value/get:key))
       (should (eq value/get:key expected:key))
       (should (integerp value/get:value))
       (should (= value/get:value expected:value))))))


;;------------------------------
;; alist:update - local alist (defined in a `let')
;;------------------------------

(ert-deftest test<nub/alist>::alist:update::local ()
  "Test that `alist:update' will add/overwrite values in a local alist correctly."
  (test<nub>:fixture
   ;;===
   ;; Test name, setup & teardown func.
   ;;===
   "test<nub/alist>::alist:update::local"
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
     (should-not (alist:get/value :key-3 alist/cons))
     (should-not (alist:get/value :key-3 alist/list))

     (test<nub>:should:marker test-name "cons: New Key/Value")
     (setq alist/updated (alist:update :key-3 :value-3/new alist/cons))
     (should alist/updated)

     ;; Our return value should be our alist.
     (should (eq alist/updated alist/cons))
     (setq value/get (alist:get/value :key-3 alist/cons))
     (should value/get)
     (should (keywordp value/get))
     (should (eq value/get :value-3/new))

     (test<nub>:should:marker test-name "list: New Key/Value")
     ;; Add the new value as a list, since it's the `alist/list'.
     (setq alist/updated (alist:update :key-3 '(:value-3/new) alist/list))
     (should alist/updated)
     ;; Our return value should be our alist.
     (should (eq alist/updated alist/list))
     (setq value/get (alist:get/value :key-3 alist/list))
     (should value/get)
     (should (listp value/get))
     (should (= 1 (length value/get)))
     (setq value/get (nth 0 value/get))
     (should (keywordp value/get))
     (should (eq value/get :value-3/new))

     ;;------------------------------
     ;; Update existing key's value.
     ;;------------------------------
     (let ((value/cons (alist:get/value :key-0 alist/cons))
           (value/list (alist:get/value :key-0 alist/list)))
       (should value/cons)
       (should value/list)
       (should (eq value/cons :value-0/initial))
       (should (equal value/list '(:value-0/initial)))

       (test<nub>:should:marker test-name "cons: Update Existing Key/Value")
       (setq alist/updated (alist:update :key-0 :value-0/updated alist/cons))
       (should alist/updated)
       ;; Our return value should be our alist.
       (should (eq alist/updated alist/cons))
       (setq value/get (alist:get/value :key-0 alist/cons))
       (should value/get)
       (should (keywordp value/get))
       (should (eq value/get :value-0/updated))

       (test<nub>:should:marker test-name "list: Update Existing Key/Value")
       ;; Add the new value as a list, since it's the `alist/list'.
       (setq alist/updated (alist:update :key-0 '(:value-0/updated) alist/list))
       (should alist/updated)
       ;; Our return value should be our alist.
       (should (eq alist/updated alist/list))
       (setq value/get (alist:get/value :key-0 alist/list))
       (should value/get)
       (should (listp value/get))
       (should (= 1 (length value/get)))
       (setq value/get (nth 0 value/get))
       (should (keywordp value/get))
       (should (eq value/get :value-0/updated))))))


;;------------------------------
;; alist:update - non-local alist
;;------------------------------

(ert-deftest test<nub/alist>::alist:update::global ()
  "Test that `alist:update' will add/overwrite values in a global alist correctly."
  (test<nub>:fixture
   ;;===
   ;; Test name, setup & teardown func.
   ;;===
   "test<nub/alist>::alist:update::global"
   (lambda (_)
     "Set up globals for this test."
     (setq test<alist>:alist/cons (list (cons :key-0 :value-0/initial)
                                        (cons :key-1 :value-1/initial)
                                        (cons :key-2 :value-2/initial)))
     (setq test<alist>:alist/list (list (list :key-0 :value-0/initial)
                                        (list :key-1 :value-1/initial)
                                        (list :key-2 :value-2/initial)))
     )
   (lambda (_)
     "Clean up the alist of lists."
     ;; (unintern test<alist>:alist/cons)
     ;; (unintern test<alist>:alist/list)
     )

   ;;===
   ;; Run the test.
   ;;===
   (let* (alist/updated
          value/get)

     ;;------------------------------
     ;; Add new key/values.
     ;;------------------------------
     (should-not (alist:get/value :key-3 test<alist>:alist/cons))
     (should-not (alist:get/value :key-3 test<alist>:alist/list))

     (test<nub>:should:marker test-name "cons: New Key/Value")
     (setq alist/updated (alist:update :key-3 :value-3/new test<alist>:alist/cons))
     (should alist/updated)

     ;; Our return value should be our alist.
     (should (eq alist/updated test<alist>:alist/cons))
     (setq value/get (alist:get/value :key-3 test<alist>:alist/cons))
     (should value/get)
     (should (keywordp value/get))
     (should (eq value/get :value-3/new))

     (test<nub>:should:marker test-name "list: New Key/Value")
     ;; Add the new value as a list, since it's the `test<alist>:alist/list'.
     (setq alist/updated (alist:update :key-3 '(:value-3/new) test<alist>:alist/list))
     (should alist/updated)
     ;; Our return value should be our alist.
     (should (eq alist/updated test<alist>:alist/list))
     (setq value/get (alist:get/value :key-3 test<alist>:alist/list))
     (should value/get)
     (should (listp value/get))
     (should (= 1 (length value/get)))
     (setq value/get (nth 0 value/get))
     (should (keywordp value/get))
     (should (eq value/get :value-3/new))

     ;;------------------------------
     ;; Update existing key's value.
     ;;------------------------------
     (let ((value/cons (alist:get/value :key-0 test<alist>:alist/cons))
           (value/list (alist:get/value :key-0 test<alist>:alist/list)))
       (should value/cons)
       (should value/list)
       (should (eq value/cons :value-0/initial))
       (should (equal value/list '(:value-0/initial)))

       (test<nub>:should:marker test-name "cons: Update Existing Key/Value")
       (setq alist/updated (alist:update :key-0 :value-0/updated test<alist>:alist/cons))
       (should alist/updated)
       ;; Our return value should be our alist.
       (should (eq alist/updated test<alist>:alist/cons))
       (setq value/get (alist:get/value :key-0 test<alist>:alist/cons))
       (should value/get)
       (should (keywordp value/get))
       (should (eq value/get :value-0/updated))

       (test<nub>:should:marker test-name "list: Update Existing Key/Value")
       ;; Add the new value as a list, since it's the `test<alist>:alist/list'.
       (setq alist/updated (alist:update :key-0 '(:value-0/updated) test<alist>:alist/list))
       (should alist/updated)
       ;; Our return value should be our alist.
       (should (eq alist/updated test<alist>:alist/list))
       (setq value/get (alist:get/value :key-0 test<alist>:alist/list))
       (should value/get)
       (should (listp value/get))
       (should (= 1 (length value/get)))
       (setq value/get (nth 0 value/get))
       (should (keywordp value/get))
       (should (eq value/get :value-0/updated))))))


;;------------------------------
;; alist:delete - local alist (defined in a `let')
;;------------------------------

(ert-deftest test<nub/alist>::alist:delete::local ()
  "Test that `alist:delete' will delete keys from the alist correctly."
  (test<nub>:fixture
   ;;===
   ;; Test name, setup & teardown func.
   ;;===
   "test<nub/alist>::alist:delete::local"
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
     (test<nub>:should:marker test-name "cons: `:key-0'")
     (setq alist/deleted (alist:delete :key-0 alist/cons))
     (should alist/deleted)
     ;; Our return value should be our alist.
     (should (eq alist/deleted alist/cons))
     (should-not (alist:get/value :key-0 alist/cons))

     (test<nub>:should:marker test-name "list: `:key-0'")
     (setq alist/deleted (alist:delete :key-0 alist/list))
     (should alist/deleted)
     ;; Our return value should be our alist.
     (should (eq alist/deleted alist/list))
     (should-not (alist:get/value :key-0 alist/list)))))


;;------------------------------
;; alist:delete - global alist
;;------------------------------

(ert-deftest test<nub/alist>::alist:delete::global ()
  "Test that `alist:delete' will delete keys from the alist correctly."
  (test<nub>:fixture
   ;;===
   ;; Test name, setup & teardown func.
   ;;===
   "test<nub/alist>::alist:delete::global"
   (lambda (_)
     "Set up globals for this test."
     (setq test<alist>:alist/cons (list (cons :key-0 :value-0/initial)
                                        (cons :key-1 :value-1/initial)
                                        (cons :key-2 :value-2/initial)))
     (setq test<alist>:alist/list (list (list :key-0 :value-0/initial)
                                        (list :key-1 :value-1/initial)
                                        (list :key-2 :value-2/initial)))
     )
   (lambda (_)
     "Clean up the alist of lists."
     ;; (unintern test<alist>:alist/cons)
     ;; (unintern test<alist>:alist/list)
     )

   ;;===
   ;; Run the test.
   ;;===
   (let* (alist/deleted)

     ;;------------------------------
     ;; Delete keys from the alists.
     ;;------------------------------
     (test<nub>:should:marker test-name "cons: `:key-0'")
     (setq alist/deleted (alist:delete :key-0 test<alist>:alist/cons))
     (should alist/deleted)
     ;; Our return value should be our alist.
     (should (eq alist/deleted test<alist>:alist/cons))
     (should-not (alist:get/value :key-0 test<alist>:alist/cons))

     (test<nub>:should:marker test-name "list: `:key-0'")
     (setq alist/deleted (alist:delete :key-0 test<alist>:alist/list))
     (should alist/deleted)
     ;; Our return value should be our alist.
     (should (eq alist/deleted test<alist>:alist/list))
     (should-not (alist:get/value :key-0 test<alist>:alist/list)))))


;;------------------------------------------------------------------------------
;; Tests: Regression Tests
;;----------
;; Test that bugs don't resurface.
;;------------------------------------------------------------------------------

;;------------------------------
;; alist:update
;;------------------------------

(ert-deftest test<nub/alist>::alist:update::regression/call-for-alist ()
  "Test that `alist:update' can work if you use a macro call that
returns a symbol-name as a parameter.

Bug came from:
  (int<nub>:layout:unbind :debug :testing :common '(:n \"s\" :layout:common:undefined))

----------

[BUG]:
  Calling with a function call (that returns an alist's symbol name) raises an error.

[FIX]:
  - Simplified macros for update and delete a lot: moved updating/deleting to a
    helper function and macro just saves results back to provided symbol."
  (test<nub>:fixture
   ;;===
   ;; Test name, setup & teardown func.
   ;;===
   "test<nub/alist>::alist:update::regression/call-for-alist"
   #'test<nub/alist>:setup
   #'test<nub/alist>:teardown

   ;;===
   ;; Run the test.
   ;;===
   (should test<alist>:alist/values)
   (should-error alist/values)

   (let* ((alist/values (list (cons :key-0 :value-0/initial)
                              (cons :key-1 :value-1/initial)
                              (cons :key-2 :value-2/initial)))
          (alist/nil nil))

     ;;------------------------------
     ;; Update should work when passing in the symbol itself.
     ;;------------------------------
     (should (alist:update :key-3
                           :value-3/00
                           ;; Passes in value of `alist/values'.
                           alist/values))
     (should (alist:update :key-3
                           :value-3/01
                           ;; Passes in value of `alist/nil'.
                           alist/nil))
     (should (alist:update :key-3
                           :value-3/02
                           ;; Passes in value of `alist/nil'.
                           test<alist>:alist/values))

     ;;------------------------------
     ;; Update should work w/ a macro call which returns the symbol name.
     ;;------------------------------
     (should (eq 'alist/values
                 (test<alist>:get :local 'alist/values)))
     (should (eq 'test<alist>:alist/nil
                 (test<alist>:get :global/nil)))
     (should (eq 'test<alist>:alist/values
                 (test<alist>:get :global/values)))

     ;; Dunno how to get lexicals to work? :(
     (should-error (alist:update :key-3
                                 :value-3/07
                                 (test<alist>:get :local 'alist/values)))

     ;; Should update a list if given the values variable name.
     (should (alist:update :key-3
                           :value-3/08
                           (test<alist>:get :global/values)))
     (should (eq :value-3/08
                 (alist:get/value :key-3 test<alist>:alist/values)))

     ;; Should create a list if given the nil variable name.
     (should (eq nil
                 test<alist>:alist/nil))
     (should (alist:update :key-3
                           :value-3/09
                           (test<alist>:get :global/nil)))
     (should (eq :value-3/09
                 (alist:get/value :key-3 test<alist>:alist/nil))))))


;;------------------------------------------------------------------------------
;; Tests: String 'alist' Functions
;;------------------------------------------------------------------------------
;; Currently there are no tests as there are no 'alist/string' functions
;; defined/in-use.
;;------------------------------
