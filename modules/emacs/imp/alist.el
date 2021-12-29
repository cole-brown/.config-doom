;;; emacs/imp/alist.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; A-list Functions
;;------------------------------------------------------------------------------

(defun int<imp>:alist:valid/key (key)
  "Returns non-nil if KEY is valid.

Caller should probably raise an error if they get a nil returned."
  (not (stringp key)))
;; (int<imp>:alist:valid/key 'foo)
;; (int<imp>:alist:valid/key :foo)
;; (int<imp>:alist:valid/key "foo")


(defun int<imp>:alist:get/value (key alist)
  "Get value of KEY's entry in ALIST."
  ;;---
  ;; Error Checking
  ;;---
  (if (int<imp>:alist:valid/key key)
      (alist-get key alist)
    (error (concat "int<imp>:alist:get/value: "
                   "String key '%s' won't work... ")
           key)))


(defun int<imp>:alist:get/pair (key alist)
  "Get KEY's entire entry (`car' is KEY, `cdr' is value) from ALIST."
  ;;---
  ;; Error Checking
  ;;---
  (if (int<imp>:alist:valid/key key)
      (assoc key alist)
    (error (concat "int<imp>:alist:get/pair: "
                   "String key '%s' won't work... ")
           key)))


(defmacro int<imp>:alist:update (key value alist)
  "Set/overwrite an entry in the alist.

If VALUE is nil, it will be set as KEY's value. Use
`int<imp>:alist:delete' if you want to remove it.

Returns ALIST."
  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((mmm:alist (make-symbol "alist/general"))
        (mmm:key   (make-symbol "alist/general:key")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,mmm:alist ,alist)
           (,mmm:key ,key))
       ;;---
       ;; Error Checking
       ;;---
       (unless (int<imp>:alist:valid/key ,mmm:key)
         (error (concat "int<imp>:alist:update: "
                        "String key '%s' won't work... ")
                ,mmm:key))
       (setf (alist-get ,mmm:key ,mmm:alist) ,value)
       ,mmm:alist)))


(defmacro int<imp>:alist:delete (key alist &optional set-alist)
  "Removes KEY from ALIST.

Returns ALIST."
  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((mmm:alist (make-symbol "alist/general"))
        (mmm:key   (make-symbol "alist/general:key")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,mmm:alist ,alist)
           (,mmm:key ,key))
       ;;---
       ;; Error Checking
       ;;---
       (unless (int<imp>:alist:valid/key ,mmm:key)
         (error (concat "int<imp>:alist:update: "
                        "String key '%s' won't work... ")
                ,mmm:key))
       (setf (alist-get ,mmm:key ,mmm:alist nil 'remove) nil)
       (when ,set-alist
         (setq ,alist ,mmm:alist))
       ,mmm:alist)))
;; (let ((alist '((foo . bar))))
;;   (int<imp>:alist:delete "foo" alist)
;;   alist)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
