;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; emacs/imp/test/alist.el


;;------------------------------------------------------------------------------
;; Tests: alist/general
;;------------------------------------------------------------------------------

;;------------------------------
;; iii:alist/general:get
;;------------------------------
(ert-deftest test<alist>:alist/general:get ()
  "Tests that `iii:alist/general:get' gets alist cdrs correctly."
  (let ((alist '((:keyword . :value0)
                 (symbol . :value1)
                 ;; String keys do not work with 'alist/general' functions.
                 ("string" . :value-invalid))))
    ;;---
    ;; Valid keys.
    ;;---
    (should (equal (iii:alist/general:get :keyword alist)
                   :value0))
    (should (equal (iii:alist/general:get 'symbol alist)
                   :value1))

    ;;---
    ;; Invalid keys.
    ;;---
    (should-error (iii:alist/general:get "string" alist))))


;;------------------------------
;; iii:alist/general:update
;;------------------------------
(ert-deftest test<alist>:alist/general:update ()
  "Tests that `iii:alist/general:get' gets alist cdrs correctly."
  (let ((alist '((:key0 . :value0)
                 (:key1 . :value1))))

    ;;---
    ;; Valid.
    ;;---
    ;; Replace a value.
    (should (equal (iii:alist/general:update :key1 :value-new alist)
                   '((:key0 . :value0)
                     (:key1 . :value-new))))

    ;; Create a new key/value.
    (should (equal (iii:alist/general:update :key2 :value2 alist)
                   '((:key2 . :value2)
                     (:key0 . :value0)
                     (:key1 . :value-new)))) ;; Updated last test.

    ;;---
    ;; Invalid.
    ;;---
    (should-error (iii:alist/general:update "key-invalid" :value-invalid alist))))


;;------------------------------
;; iii:alist/general:delete
;;------------------------------
(ert-deftest test<alist>:alist/general:delete ()
  "Tests that `iii:alist/general:get' gets alist cdrs correctly."
  (let ((alist '((:key0 . :value0)
                 (:key1 . :value1))))

    ;;---
    ;; Valid.
    ;;---
    (should (equal (iii:alist/general:delete :key1 alist)
                   '((:key0 . :value0))))
    (should (equal (iii:alist/general:delete :key-DNE alist)
                   '((:key0 . :value0))))

    ;;---
    ;; Invalid.
    ;;---
    (should-error (iii:alist/general:delete "key-invalid" :value-invalid alist))))


;;------------------------------------------------------------------------------
;; Tests: alist/string
;;------------------------------------------------------------------------------

;;------------------------------
;; iii:alist/string:get
;;------------------------------
(ert-deftest test<alist>:alist/string:get ()
  "Tests that `iii:alist/string:get' gets alist cdrs correctly."
  (let ((alist '(("string" . :value0)
                 ;; Non-string keys do not work for string alists.
                 (:keyword . :value1)
                 (symbol . :value2))))
    ;;---
    ;; Valid keys.
    ;;---
    (should (equal (iii:alist/string:get "string" alist)
                   :value0))


    ;;---
    ;; Invalid keys.
    ;;---
    (should-error (iii:alist/string:get :keyword alist))
    (should-error (iii:alist/string:get 'symbol alist))))


;;------------------------------
;; iii:alist/string:update
;;------------------------------
(ert-deftest test<alist>:alist/string:update ()
  "Tests that `iii:alist/string:get' gets alist cdrs correctly."
  (let ((alist '(("key0" . :value0)
                 ("key1" . :value1))))

    ;;---
    ;; Valid.
    ;;---
    ;; Replace a value.
    (should (equal (iii:alist/string:update "key1" :value-new alist)
                   '(("key0" . :value0)
                     ("key1" . :value-new))))

    ;; Create a new key/value.
    (should (equal (iii:alist/string:update "key2" :value2 alist)
                   '(("key2" . :value2)
                     ("key0" . :value0)
                     ("key1" . :value-new)))) ;; Updated last test.

    ;;---
    ;; Invalid.
    ;;---
    (should-error (iii:alist/string:update :key-invalid :value-invalid alist))))


;;------------------------------
;; iii:alist/string:delete
;;------------------------------
(ert-deftest test<alist>:alist/string:delete ()
  "Tests that `iii:alist/string:get' gets alist cdrs correctly."
  (let ((alist '(("key0" . :value0)
                 ("key1" . :value1))))

    ;;---
    ;; Valid.
    ;;---
    (should (equal (iii:alist/string:delete "key1" alist)
                   '(("key0" . :value0))))
    (should (equal (iii:alist/string:delete "key-DNE" alist)
                   '(("key0" . :value0))))

    ;;---
    ;; Invalid.
    ;;---
    (should-error (iii:alist/string:delete :key-invalid :value-invalid alist))))
