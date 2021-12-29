;;; emacs/imp/alist.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; A-list Functions
;;------------------------------------------------------------------------------

(defun int<imp>:alist:valid/key (caller key &optional error?)
  "Returns non-nil if KEY is valid.

If ERROR? is non-nil, raises an error for invalid keys. Else returns t/nil."
  (if (not (stringp key))
      (if error?
          (int<imp>:error (int<imp>:output:callers "int<imp>:alist:valid/key" caller)
                          "Imp alist cannot have a string key! Key: %S"
                          key)
        nil)
    key))
;; (int<imp>:alist:valid/key "test" 'foo t)
;; (int<imp>:alist:valid/key "test" :foo t)
;; (int<imp>:alist:valid/key "test" "foo" t)


(defun int<imp>:alist:get/value (key alist)
  "Get value of KEY's entry in ALIST."
  (int<imp>:alist:valid/key "int<imp>:alist:get/value" key :error)
  (alist-get key alist))


(defun int<imp>:alist:get/pair (key alist)
  "Get KEY's entire entry (`car' is KEY, `cdr' is value) from ALIST."
  (int<imp>:alist:valid/key "int<imp>:alist:get/pair" key :error)
  (assoc key alist))


(defmacro int<imp>:alist:update (key value alist)
  "Set/overwrite an entry in the alist.

If VALUE is nil, it will be set as KEY's value. Use
`int<imp>:alist:delete' if you want to remove it.

Returns ALIST."
  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((macro<imp>:alist (make-symbol "macro<imp>:alist"))
        (macro<imp>:key   (make-symbol "macro<imp>:alist:key")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,macro<imp>:alist ,alist)
           (,macro<imp>:key   ,key))
       (int<imp>:alist:valid/key "int<imp>:alist:update" key :error)
       (setf (alist-get ,macro<imp>:key ,macro<imp>:alist) ,value)
       ,macro<imp>:alist)))


(defmacro int<imp>:alist:delete (key alist &optional set-alist)
  "Removes KEY from ALIST.

Returns ALIST."
  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Surprising-Local-Vars.html#Surprising-Local-Vars
  (let ((macro<imp>:alist (make-symbol "macro<imp>:alist"))
        (macro<imp>:key   (make-symbol "macro<imp>:alist:key")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,macro<imp>:alist ,alist)
           (,macro<imp>:key   ,key))
       (int<imp>:alist:valid/key "int<imp>:alist:delete" key :error)
       (setf (alist-get ,macro<imp>:key ,macro<imp>:alist nil 'remove) nil)
       (when ,set-alist
         (setq ,alist ,macro<imp>:alist))
       ,macro<imp>:alist)))
;; (let ((alist '((foo . bar))))
;;   (int<imp>:alist:delete "foo" alist)
;;   alist)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
