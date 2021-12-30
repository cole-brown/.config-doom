;;; emacs/imp/alist.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                         Better Alist Functions                         ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;               At least these all have 'alist' in the name...               ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; A-list Functions
;;------------------------------------------------------------------------------

(defun int<imp>:alist:valid/key (caller key &optional error?)
  "Returns non-nil if KEY is valid.

If ERROR? is non-nil, raises an error for invalid keys. Else returns t/nil."
  (if (stringp key)
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


(defun int<imp>:alist:update/helper (key value alist)
  "Set/overwrite an entry in the ALIST. Return the new alist.

If VALUE is nil, it will be set as KEY's value. Use
`int<imp>:alist:delete' if you want to remove it.

Returns a new alist, which isn't ALIST."
  (int<imp>:alist:valid/key "int<imp>:alist:update/helper" key :error)

  (if (null alist)
      ;; Create a new alist and return it.
      (list (cons key value))

    ;; `setf' creates a new alist sometimes, so buyer beware!
    (setf (alist-get key alist) value)
    alist))
;; (setq test-alist nil)
;; (setq test-alist (int<imp>:alist:update/helper :k :v test-alist))
;; (int<imp>:alist:update/helper :k2 :v2 test-alist)
;; (int<imp>:alist:update/helper :k2 :v2.0 test-alist)
;; test-alist


(defmacro int<imp>:alist:update (key value alist)
  "Set/overwrite an entry in the ALIST.

SYMBOL/ALIST should be a (quoted) symbol so that this can update it directly.

If VALUE is nil, it will be set as KEY's value. Use
`int<imp>:alist:delete' if you want to remove it.

Returns ALIST."
  `(let ((macro<imp>:alist ,alist))
     (cond
      ((listp macro<imp>:alist)
       (setq ,alist
             (int<imp>:alist:update/helper ,key ,value ,alist)))
      ((symbolp macro<imp>:alist)
       (set macro<imp>:alist
            (int<imp>:alist:update/helper ,key ,value (eval macro<imp>:alist))))

      (t
       (int<imp>:error "int<imp>:alist:update"
                       "Unable to update alist: not a list or a symbol: %S (type: %S)"
                       macro<imp>:alist
                       (typeof macro<imp>:alist))))))
;; (setq test<imp>:alist nil)
;; (int<imp>:alist:update :k0 :v0 test<imp>:alist)
;; test<imp>:alist


(defun int<imp>:alist:delete/helper (key alist)
  "Removes KEY from ALIST.

Returns alist without the key."
  (int<imp>:alist:valid/key "int<imp>:alist:delete/helper" key :error)

  ;; If it's null, no need to do anything.
  (unless (null alist)
    (setf (alist-get key alist nil 'remove) nil))

  ;; Return the alist.
  alist)


(defmacro int<imp>:alist:delete (key alist)
  "Removes KEY from ALIST.

Returns ALIST."
  `(let ((macro<imp>:alist ,alist))
     (cond ((listp macro<imp>:alist)
            (setq ,alist
                  (int<imp>:alist:delete/helper ,key ,alist)))
           ((symbolp macro<imp>:alist)
            (set macro<imp>:alist
                 (int<imp>:alist:delete/helper ,key (eval macro<imp>:alist))))

           (t
            (int<imp>:error "int<imp>:alist:delete"
                            '("Unable to delete key from alist; "
                              "alist is not a list or a symbol: "
                              "%S (type: %S)")
                            macro<imp>:alist
                            (typeof macro<imp>:alist))))))
;; (setq test-alist nil)
;; (int<imp>:alist:delete :k test-alist)
;; (int<imp>:alist:update :k :v test-alist)
;; (int<imp>:alist:delete :k2 test-alist)
;; (int<imp>:alist:delete :k test-alist)
;; test-alist


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
