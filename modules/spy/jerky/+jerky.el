;; -*- mode: emacs-lisp; lexical-binding: t -*-


;;---------------------Like spy/dirky, but, like, general.----------------------
;;--                      So... Generlky? Genky?... Hm.                       --
;;-------------------------------(or, maybe...)---------------------------------
;;├────────────────────────────────┼ jerky ┼───────────────────────────────────┤


(require 's)
(require 'dash)
(spy/require :spy 'zero 'strings)

;; §-TODO-§ [2020-10-23]: Make this its own package.

;;------------------------------------------------------------------------------
;; Jerky's Repository of... dried meats?
;;------------------------------------------------------------------------------

;; TODO: Change this to a hash table?
(defvar jerky//kvs '()
  "A recursive key-value store, basically. An alist of alists (of et ceteras).
  Maybe some values thrown in there somewhere; I don't know.

Each alist entry is a list (not a cons). There are three cells like so:
'(key value docstr)

KEY should be a symbol, probably?

VALUE can be:
  - Another alist in a layout jerky understands.
  - A string.
  - A symbol that will evaluate to a string.
  - A function that will return a string.
  - Something else? But strings get special treatment.

DOCSTR should be short.
Or not.

I'm not your mother.
")


(defun jerky//repo/test/string=/cmp (a b)
  "Compare strings (ignoring case) for `jerky//repo/test/string='.
"
  ;; `compare-strings' returns t or integer.
  ;; Convert that to a bool t/nil.
  (eq t
      ;; Compare the strings, ignoring case.
      (compare-strings a nil nil b nil nil t)))


(defun jerky//repo/test/string=/hash (key)
  "Get a hashed value for the (lowercased) key for
`jerky//repo/test/string='.
"
  (sxhash-equal (downcase key)))


;; String comparison, ignores case.
(define-hash-table-test 'jerky//repo/test/string=
  'jerky//repo/test/string=/cmp
  'jerky//repo/test/string=/hash)


(defvar jerky//repo (make-hash-table :test 'jerky//repo/test/string=
                                     :weakness nil)
  "A key-path/value store, basically.

Each entry is a list. There are three cells like so:
'(key values docstr)

KEY should be the key it's stored under (for inspection).

VALUES is a plist of 'namespace' to value. e.g.
  '(:default \"/mnt/jeff/dir\" :home \"~/my-stuff/jeff/dir\")

  - `:default' is special - it is the fallback namespace if not found in the
    desired namespace, or the namespace if none is specified.
  - Actual values in the plist can be whatever.

DOCSTR should be short.
  - Or not.
    - I'm not your mother.
")

;; Are we testing the hash-table change, or using the alist?
;; (setq jerky//feature/repo nil)
(setq jerky//feature/repo t)


;;------------------------------------------------------------------------------
;; Customizables and Constants
;;------------------------------------------------------------------------------

(defcustom jerky/custom:keys/separator "/"
  "Jerky keys will be split/joined using this character.

E.g.: (jerky/get 'my/key :path \"to/dir\")
  The key path used would be: '(my key path to dir)
")


;;------------------------------------------------------------------------------
;; Keys Functions
;;------------------------------------------------------------------------------

(defalias 'jerky//keys/symbol->str 'spy/string/symbol->str
  "Convert a symbol to a string. Removes ':' from keywords.")


(defun jerky//keys/normalize (&rest args)
  "Turn args into a list of key symbols.

(jerky//keys/normalize \"a/b\" \"c\")
  -> (a b c)
(jerky//keys/normalize \"a/b\" c)
  -> (a b c)
(jerky//keys/normalize \"a\" b c)
  -> (a b c)
"
  (let ((keys '()) ; alist tree
        (key  nil) ; hash table
        (strings '()))
    (dolist (arg args)
      ;; Push string args to strings, turn non-strings into strings.
      (cond ((stringp arg)
             (push arg strings))

            ;; symbol->string: drop keyword prefix if exists.
            ((symbolp arg)
             (push (jerky//keys/symbol->str arg) strings))

            ;; function->string:
            ((functionp arg)
             (push (funcall arg) strings))

            ;; fail
            (t
             (error (concat "%s: Can't convert '%S' to string for conversion "
                            "of keys into key list.")
                    "jerky//keys/normalize"
                    arg))))

    ;; Now we have strings. They are in backwards order. They need to be turned
    ;; into a final separated string.
    (setq key (s-join jerky/custom:keys/separator
                      (nreverse strings)))

    ;; Now we have strings. They are in backwards order. They need to be turned
    ;; into a final separated string so we can then break it apart into final key
    ;; list... One of the args could've been a compond key - e.g. "jeff/key".
    (dolist (name
             ;; Make a regex which is "literally this character" for split.
             (s-split (concat "["
                              jerky/custom:keys/separator
                              "]")
                     key))

      ;; Make symbols out of the key strings.
      (push (intern name) keys))

    ;; Return the full key string if doing hash tables, else return the list of symbols.
    (if jerky//feature/repo
        ;; Key string is good as-is.
        key

     ;; Keys list is a backwards list... again.
     ;; Turn it into a forwards list.
     (nreverse keys))))
;; (jerky//keys/normalize "a/b" "c")
;; (jerky//keys/normalize :base "a/b" "c")


(defun jerky//keys/desired? (key)
  "Predicate for filtering list. Returns nil if it encounters one of these:
  `:value'
  `:docstr'

For all others, this returns t to indicate KEY is a valid/desired key.
"
  (not (or (eq key :value)
           (eq key :docstr))))
;; (jerky//keys/desired? :jeff)
;; (jerky//keys/desired? 'jeff)
;; (jerky//keys/desired? "jeff")
;; (jerky//keys/desired? "value")
;; (jerky//keys/desired? 'value)
;; (jerky//keys/desired? :value)
;; (-take-while 'jerky//keys/desired? '(path to thing :value "hello there"))
;; (-drop-while 'jerky//keys/desired? '(path to thing :value "hello there"))


;;------------------------------------------------------------------------------
;; Writing to Key-Value Store
;;------------------------------------------------------------------------------


(defun jerky//write/update (repo keys &optional value docstr)
  "Looks in jerky's key-value REPO for KEYS. Updates final key in KEYS to:
(list KEY VALUE DOCSTR)

KEYS should be the output of `jerky//keys/normalize'.

REPO should be the (quoted) symbol. E.g.: 'jerky//kvs

VALUE can be whatever.

DOCSTR can be nil or a string, but is not verified.
"
  (if jerky//feature/repo
      ;; Write to the hash table:
      (puthash keys (list keys value docstr) jerky//repo)

    ;; Else, write to the KVS tree.
    (let ((key (car keys))
          (rest (cdr keys)))

      (let ((entry (assoc key repo)))
        (if (null entry)
            ;; Entry doesn't exist; push a new one into the list.
            (if (null rest)
                ;; This is the end; we know what to do.
                (push (list key value docstr) repo)

              ;; Have `jerky//write/tree' take care of the rest when
              ;; this isn't the end...
              (push ;; (list ;; The alist...
               ;; The alist's key's entry... Put `key' and `rest' back
               ;; together so it can deal with as much as possible.
               (jerky//write/tree (cons key rest) value docstr) ;;)
               repo))

          ;; Entry does exist; update cdr slot with new list.
          (if (null rest)
              ;; This is the end; we know what to do.
              (setf (cdr entry) (cons value docstr))

            ;; We don't know what to do; but maybe if we ask ourself?..
            (setf (nth 1 entry) (jerky//write/update (nth 1 entry)
                                                     rest
                                                     value
                                                     docstr))))))
    ;; Always return the (modified) key-value store.
    repo))
;; (setq spy//test/jerky nil)
;; (symbol-value 'spy//test/jerky)
;; (jerky//write/update spy//test/jerky '(path) "test" "docstr")
;; (setq spy//test/jerky (jerky//write/update spy//test/jerky '(path to thing one) "test" "docstr"))
;; (setq spy//test/jerky (jerky//write/update spy//test/jerky '(path to glory) "glory?!" "*shrug*"))
;; (setq spy//test/jerky (jerky//write/update spy//test/jerky '(path to thing) "hello there"))


(defun jerky//write/tree (keys value docstr)
  "Uses the list of KEYS to make a tree of empty branches out to the final leaf
of (key VALUE DOCSTR).
"
  (when jerky//feature/repo
    (error "'Write a subtree' not supported for storage backend of hash table."))

  (if (cdr keys)
      ;; This is an alist of alists, so we need the cdr to be that 'of alist'...
      ;; So we put the list we get back from ourself into a list. It'll end up
      ;; as an alist with one entry, like:
      ;;   '((:solo-key "solo value" "solo docstr"))
      (list (car keys) (list (jerky//write/tree (cdr keys)
                                                       value
                                                       docstr)))
    ;; Final key. Return the '(field value docstr) entry.
    (list (car keys) value docstr)))
;; (defvar spy//test/jerky '())
;; (jerky//write/tree '(path to thing one) "test" "docstr")


(defun jerky/set (&rest args)
  "Overwrite an existing entry or add new entry to `jerky//keys'.

KEYS: The '&rest' come first!
  All ARGS before jerky's keyword args are considered the keys. They will be
processed by `jerky/keys' to get a key path to follow.

TODO: Flatten lists here? So if only arg is list, becomes key list?

This uses two keyword ARGS after the KEYS. The keywords are:
  `:value'
  `:docstr'

`:docstr'
  The argument after :docstr will be evaluated and stored as the
  documentation string.

`:value'
  The argument after :value will be stored as the value.

If not provided, they will be nil.
"
  ;; Some shenanigans to do to turn 'args' into keys args and plist args.
  (-let ((keys (apply #'jerky//keys/normalize
                      (-take-while #'jerky//keys/desired? args)))
         ;; dash-let's plist match pattern to non-keys in ARGS.
         ((&plist :docstr docstr :value value)
          (-drop-while #'jerky//keys/desired? args)))

    (if jerky//feature/repo
        (jerky//write/update jerky//kvs keys value docstr)

      (setq jerky//kvs (jerky//write/update jerky//kvs
                                            keys
                                            value
                                            docstr)))))
;; jerky//kvs
;; (setq jerky//kvs nil)
;; (jerky/set 'path 'to 'thing :value "hello there")
;; (jerky/set :test :jeff :value "jeffe" :docstr "I am a comment.")
;; (jerky/set :test :jeff :value "jeffe")
;; (jerky/set :test :jill :value "jill")


;;------------------------------------------------------------------------------
;; Reading from Key-Value Store
;;------------------------------------------------------------------------------

(defun jerky//get/key (entry)
  "Get the key of this entry in jerky's repo.
"
  ;; key is at index 0
  (nth 0 entry))


(defun jerky//get/value (entry)
  "Get the value of this entry in jerky's repo.
"
  ;; value is at index 1
  (nth 1 entry))


(defun jerky//get/docstr (entry)
  "Get the docstr of this entry in jerky's repo.
"
  ;; docstr is at index 2
  (nth 2 entry))


(defun jerky/get (&rest keys)
  "Gets an entry's value from `jerky//keys'.

KEYS: Key path to walk down to find value to return.

TODO: Flatten lists here? So if only arg is list, becomes key list?

If nothing found at KEYS, return will be nil.
"
  (let ((keys (apply #'jerky//keys/normalize keys))
        (kvs jerky//kvs))

    (if jerky//feature/repo
        ;; Return keys' value or null.
        (jerky//get/value (gethash keys jerky//repo))

      ;; Else, walk our tree to find the key.
      (dolist (key keys)
        (setq kvs (nth 1 (assoc key kvs))))
      kvs)))
;; (setq jerky//kvs nil)
;; (setq jerky//kvs '((test ((jill "jill" nil) (jeff "jeffe" "I am a comment."))) (path ((to ((thing "hello there" nil))))))
;; jerky//kvs
;; (jerky/get 'path 'to 'thing)
;; (jerky/get :test :jeff)
;; (jerky/get :test :jill)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy/provide :spy 'jerky) ;; I have given you tasty jerky. Enjoy.
