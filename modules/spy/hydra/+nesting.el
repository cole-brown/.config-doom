;;; spy/hydra/nesting.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Nesting Hydra Helpers
;;------------------------------------------------------------------------------
;; https://github.com/abo-abo/hydra/wiki/Nesting-Hydras

;; (defhydra test-a (:post (message "post a"))
;;   "a"
;;   ("q" test-b/body "to b" :exit t))
;;
;; (defhydra test-b (:body-pre (message "pre b"))
;;   "b"
;;   ("q" nil "exit" :exit t))


(defun spy:hydra/nest (hydra)
  "Enter HYDRA from current hydra.

NOTE: Use `:exit t' or appropriate color for exiting the caller hydra!"
  (funcall (intern-soft (concat (symbol-name hydra) "/body"))))
;; (defun test/body () (message "hello there"))
;; (spy:hydra/nest 'test)


;;------------------------------------------------------------------------------
;; Hydra Stacks
;;------------------------------------------------------------------------------
;; https://github.com/abo-abo/hydra/wiki/Nesting-Hydras

(defvar sss:hydra/stack nil
  "A list of the stack of hydras currently in use.")


(defun sss:hydra/push (func)
  "Add the hydra FUNC to the stack."
  (push func sss:hydra/stack))


(defun spy:hydra/push (hydra)
  "Add the HYDRA to the stack and enter its `<hydra>/body'.

Example:
  With a hydra named `s:hydra:qux':
    (spy:hydra/push 's:hydra:qux)
      - Will push to the stack: '(s:hydra:qux/body)"
  ;; Create function call to `hydra' body function.
  (let ((hydra/body (intern-soft (concat (symbol-name hydra) "/body"))))
    ;; Call the hydra, then push to stack to save state.
    (funcall 'hydra/body)
    (push hydra/body sss:hydra/stack)))


(defun spy:hydra/pop ()
  "Pop a hydra body off of `sss:hydra/stack' if one exists and call it."
  (interactive)
  (let ((hydra/func/body (pop sss:hydra/stack)))
    (when hydra/func/body
      (funcall hydra/func/body))))


;;------------------------------
;; Example:
;;------------------------------
;; teal: default to exit on hydra heads
;;   - Think just used to make example more compact?
;;
;; (defhydra hydra-a (:color teal)
;;   "a"
;;   ("b" (progn
;;          (hydra-b/body)
;;          (hydra-push '(hydra-a/body)))
;;        "visit hydra-b")
;;   ("c" (progn
;;          (hydra-c/body)
;;          (hydra-push '(hydra-a/body)))
;;        "visit hydra-c")
;;   ("i" (message "I am a") :exit nil)
;;   ("q" hydra-pop "exit"))
;;
;; (defhydra hydra-b (:color teal)
;;   "b"
;;   ("a" (progn
;;          (hydra-a/body)
;;          (hydra-push '(hydra-b/body)))
;;        "visit hydra-a")
;;   ("c" (progn
;;          (hydra-c/body)
;;          (hydra-push '(hydra-b/body)))
;;        "visit hydra-c")
;;   ("i" (message "I am b") :exit nil)
;;   ("q" hydra-pop "exit"))
;;
;; (defhydra hydra-c (:color teal)
;;   "c"
;;   ("a" (progn
;;          (hydra-a/body)
;;          (hydra-push '(hydra-c/body)))
;;        "visit hydra-a")
;;   ("b" (progn
;;          (hydra-b/body)
;;          (hydra-push '(hydra-c/body)))
;;        "visit hydra-b")
;;   ("i" (message "I am c") :exit nil)
;;   ("q" hydra-pop "exit"))
