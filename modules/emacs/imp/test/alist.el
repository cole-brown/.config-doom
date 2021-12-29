;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; emacs/imp/test/alist.el


;;------------------------------------------------------------------------------
;; Tests: alist
;;------------------------------------------------------------------------------

;;------------------------------
;; int<imp>:alist:get/value
;;------------------------------
(ert-deftest test<alist>:alist:get/value ()
  "Tests that `int<imp>:alist:get/value' gets alist cdrs correctly."
  (let ((alist '((:keyword . :value0)
                 (symbol . :value1)
                 ;; String keys do not work with 'alist' functions.
                 ("string" . :value-invalid))))
    ;;---
    ;; Valid keys.
    ;;---
    (should (equal (int<imp>:alist:get/value :keyword alist)
                   :value0))
    (should (equal (int<imp>:alist:get/value 'symbol alist)
                   :value1))

    ;;---
    ;; Invalid keys.
    ;;---
    (should-error (int<imp>:alist:get/value "string" alist))))


;; TODO: test get/pair
;; TODO: any other thnigs to test?

;;------------------------------
;; int<imp>:alist:update
;;------------------------------
(ert-deftest test<alist>:alist:update ()
  "Tests that `int<imp>:alist:get/value' gets alist cdrs correctly."
  (let ((alist '((:key0 . :value0)
                 (:key1 . :value1))))

    ;;---
    ;; Valid.
    ;;---
    ;; Replace a value.
    (should (equal (int<imp>:alist:update :key1 :value-new alist)
                   '((:key0 . :value0)
                     (:key1 . :value-new))))

    ;; Create a new key/value.
    (should (equal (int<imp>:alist:update :key2 :value2 alist)
                   '((:key2 . :value2)
                     (:key0 . :value0)
                     (:key1 . :value-new)))) ;; Updated last test.

    ;;---
    ;; Invalid.
    ;;---
    (should-error (int<imp>:alist:update "key-invalid" :value-invalid alist))))
;; TODO: does alist:update work without user always doing `setq' of results?


;;------------------------------
;; int<imp>:alist:delete
;;------------------------------
(ert-deftest test<alist>:alist:delete ()
  "Tests that `int<imp>:alist:get/value' gets alist cdrs correctly."
  (let ((alist '((:key0 . :value0)
                 (:key1 . :value1))))

    ;;---
    ;; Valid.
    ;;---
    (should (equal (int<imp>:alist:delete :key1 alist)
                   '((:key0 . :value0))))
    (should (equal (int<imp>:alist:delete :key-DNE alist)
                   '((:key0 . :value0))))

    ;;---
    ;; Invalid.
    ;;---
    (should-error (int<imp>:alist:delete "key-invalid" :value-invalid alist))))
