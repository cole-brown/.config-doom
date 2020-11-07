;; -*- mode: emacs-lisp; lexical-binding: t -*-


;;---------------------Like spy/dirky, but, like, general.----------------------
;;--                      So... Generlky? Genky?... Hm.                       --
;;-------------------------------(or, maybe...)---------------------------------
;;├────────────────────────────────┼ jerky ┼───────────────────────────────────┤


(require 's)
(require 'dash)
(spy/require :spy 'zero 'strings)

;; §-TODO-§ [2020-10-23]: Make this its own package.

;; TODO [2020-11-06]: Change get/set to take only one keys arg. list or str.

;;------------------------------------------------------------------------------
;; Jerky's Repository of... dried meats?
;;------------------------------------------------------------------------------

(defun jerky//repo.test.string=/cmp (a b)
  "Compare strings (ignoring case) for `jerky//repo.test.string='.
"
  ;; `compare-strings' returns t or integer.
  ;; Convert that to a bool t/nil.
  (eq t
      ;; Compare the strings, ignoring case.
      (compare-strings a nil nil b nil nil t)))


(defun jerky//repo.test.string=/hash (key)
  "Get a hashed value for the (lowercased) key for
`jerky//repo.test.string='.
"
  (sxhash-equal (downcase key)))


;; String comparison, ignores case.
(define-hash-table-test 'jerky//repo.test.string=
  'jerky//repo.test.string=/cmp
  'jerky//repo.test.string=/hash)


(defvar jerky//repo (make-hash-table :test 'jerky//repo.test.string=
                                     :weakness nil)
  "A key-path/value store, basically.

Each hash table key/value is a plist 2-tuple of `:key' and `:record'
(referred to as a kvp or pair).

The plist's `:key' association holds the hash table KEY it's stored under
(for inspection).

The `:record' association holds an alist of 3-tuples (aka 'record'):
  (namespace value docstr)

So a hash table tuple might look like this:
  '(:key \"path/to/jeff\"
    :record ((:default \"default value\" \"default docstr\")
            (:jeff    \"jeff value\"    \"jeff docstr\")
             ...))

VALUES can be whatever.

DOCSTR should be short.
  - Or not.
    - I'm not your mother.
")


;;------------------------------------------------------------------------------
;; Customizables and Constants
;;------------------------------------------------------------------------------

(defcustom jerky/custom.key/separator "/"
  "Jerky keys will be split/joined using this character.

E.g.: (jerky/get 'my/key :path \"to/dir\")
  The key path used would be: '(my key path to dir)
")


(defcustom jerky/custom.namespace/default :default
  "(Keyword) name of the default namespace.
")


;;------------------------------------------------------------------------------
;; Namespaces
;;------------------------------------------------------------------------------

(defvar jerky//namespaces
  (list
   (list jerky/custom.namespace/default
         "Default/Fallback Namespace"
         (concat "Default namespace for jerky. Other namespaces "
                 "default to this for fallbacks.")
         '(:jerky/namespace/no-fallback)))
  "alist of namespace keywords with titles, docstrs, and fallback namespaces:
So an entry would be, for example:
  '(:namespace-name \"Title\" \"docstring\" (:fallback-name-0 :fallback-name-1))

If no/nil fallbacks or nothing found after using fallbacks, jerky
will try the `jerky/custom.namespace/default'.

If the fallback is explicitly `:jerky/namespace/no-fallback', no fallbacks
will be checked (including the default).

This starts off with just the default namespace. More have to be
added. Namespaces must exist before keys can be added to them.
")
;; (setq jerky//namespaces (list (list jerky/custom.namespace/default :jerky/namespace/no-fallback)))


;;------------------------------------------------------------------------------
;; Namespace Functions
;;------------------------------------------------------------------------------

(defun jerky//namespace.entry.namespace/get (entry)
  "Returns namespace keyword symbol from entry.
"
  (nth 0 entry))


(defun jerky//namespace.entry.title/get (entry)
  "Returns namespace's title string from entry.
"
  (nth 1 entry))


(defun jerky//namespace.entry.docstr/get (entry)
  "Returns namespace doc string from entry.
"
  (nth 2 entry))


(defun jerky//namespace.entry.fallback/get (entry)
  "Returns namespace fallback list from entry.
"
  (nth 3 entry))


(defun jerky//namespace.entry/get (namespace)
  "Get a namespace entry from `jerky//namespaces'.
"
  (assoc namespace jerky//namespaces))
;; (jerky//namespace.entry/get :default)
;; (jerky//namespace.entry/get :jeff)


(defun jerky//namespace.entry/set (namespace title docstr &rest fallback)
  "Creates or overwrites a namespace entry in `jerky//namespaces'.
"
  ;; Error checks.
  (when (eq namespace jerky/custom.namespace/default)
    (error (concat "jerky//namespace.entry/set: "
                   "Cannot create the default namespace's entry: %s")
           namespace))

  (when (not (keywordp namespace))
    (error (concat "jerky//namespace.entry/set: "
                   "NAMESPACE must be a keyword: %s")
           namespace))

  (let ((verified-fallbacks nil))
    (dolist (fb-ns (-non-nil fallback))
      (cond ((eq fb-ns :jerky/namespace/no-fallback)
             (push fb-ns verified-fallbacks))

            ((not (keywordp fb-ns))
             (error (concat "jerky//namespace.entry/set: "
                            "FALLBACK must be a keyword: %s")
                    fb-ns))

            ((not (jerky//namespace/get fb-ns 'quiet))
             (error (concat "jerky//namespace.entry/set: "
                            "FALLBACK must be an existing namespace: %s")
                    fb-ns))

            (t
             (push fb-ns verified-fallbacks))))

        ;; Ok, good to go. Just make a list in this particular order.
    (list namespace title docstr verified-fallbacks)))


(defun jerky//namespace/set (entry &optional action)
  "Create/overwrite NAMESPACE entry in `jerky//namespaces'.

If ACTION is `:jerky//action/delete', delete the namespace instead.
"
  (let* ((namespace (jerky//namespace.entry.namespace/get entry))
         (existing (jerky//namespace.entry/get namespace)))
    (if (null existing)
        ;; None exists. Add it.
        (push entry jerky//namespaces)

      ;; Have the entry! Delete or update it.
      (if (eq action :jerky//action/delete)
          ;; Delete entry.
          (setf (alist-get namespace jerky//namespaces
                           ;; DEFAULT set to same as new value for
                           ;; removing from alist. REMOVE set to non-nil.
                           :jerky//action/delete :jerky//action/delete)
                ;; New value must be eql to DEFAULT provided to alist-get.
                :jerky//action/delete)

        ;; Overwrite entry.
        (setf (alist-get namespace jerky//namespaces) (cdr entry))

        ;; Return the updated entry.
        entry))))
;; (jerky//namespace/set :jeffory)
;; jerky//namespaces
;; (jerky//namespace/set :jeff :jeffory)
;; jerky//namespaces


(defun jerky/namespace/create (namespace &rest args)
  "Make the NAMESPACE, which must be a keyword, with optional Title,
Docstr, and Fallback Namespaces.

args is a keyword plist. These are the keywords supported:
  `:title'     - expects a string value
  `:docstr'    - expects a string value
  `:fallbacks' - expects a list of keywords of existing namespaces
                 or `:jerky/namespace/no-fallback'.

If fallbacks are supplied, they will be followed in order when a key is not
found in the namespace.

If fallbacks is nil, the namespace will fall back to the default namespace when
a key is not found.

If fallbacks is `:jerky/namespace/no-fallback', no fallbacks will be
used/allowed.
"
  ;; dash-let's plist match pattern to non-keys in ARGS.
  (-let (((&plist :docstr docstr :title title :fallbacks fallbacks) args))

    ;; Set new entry.
    (jerky//namespace/set
     ;; Make new entry from provided args.
     (jerky//namespace.entry/set namespace title docstr fallbacks))))
;; (jerky/namespace/create :foo :title "hello there" :docstr "jeff" :fallbacks '(a b c))


(defun jerky//namespace/ordered (namespace &optional quiet)
  "Gets a namespace & its fallbacks.

If NAMESPACE isn't found, returns `jerky/custom.namespace/default' entry.

If QUIET is non-nil, don't output messages/warnings.
"
  (let ((entry (assoc namespace jerky//namespaces))
        (namespaces nil)
        (stop? nil))
    (when (null entry)
      (unless quiet
        (warn "%s: No namespace found for: %s. Using default: %s"
              "jerky//namespace/get"
              namespace
              jerky/custom.namespace/default))
      (setq entry (assoc jerky/custom.namespace/default jerky//namespaces))
      (when (null entry)
        (unless quiet
          (warn (concat "jerky//namespace/get: No default namespace "
                        "found in namespaces!: %s. Where'd it go? %s")
                jerky/custom.namespace/default
                jerky//namespaces))
        (setq entry
              (jerky//namespace.entry/set jerky/custom.namespace/default
                                          "No default namespace exists."
                                          "No default namespace exists."))))

    ;; Convert namespaces entry into a list of namespace symbols.
    ;; Follow namespaces and keep appending on to the list until done.

    ;; First things first: the actual namespace.
    (push (jerky//namespace.entry.namespace/get entry) namespaces)

    ;; Second things second: actual namespace's fallbacks.
    (dolist (ns (jerky//namespace.entry.fallback/get entry))
      ;; If we already got a no-fallback, or this one is, set `stop?' flag
      ;; and ignore the rest.
      (if (or stop?
              (eq ns :jerky/namespace/no-fallback))
          (setq stop? t)
        (push ns namespaces)))

    ;; Do we have a stop condition already?
    (unless stop?
      ;; Start cascading fallbacks.

      ;; Last things last: get the fallbacks' fallbacks.
      (dolist (ns (cdr namespaces)) ; Skip primary namespace.
        ;; When we have a fallback entry with fallbacks...
        (when-let* ((fb-entry (assoc ns jerky//namespaces))
                    (fb-fb (jerky//namespace.entry.fallback/get fb-entry)))
          ;; ...push each of those onto the list if not there already.
          (dolist (fb-ns fb-fb)
            (unless (or (memq fb-ns namespaces)
                        (eq fb-ns :jerky/namespace/no-fallback))
                (push fb-ns namespaces))))))

    ;; Return list of namespaces to check.
    namespaces))
;; (jerky//namespace/ordered :default)
;; (jerky//namespace/ordered :jeff)


;;------------------------------------------------------------------------------
;; Key Functions
;;------------------------------------------------------------------------------

(defalias 'jerky//key/symbol->str 'spy/string/symbol->str
  "Convert a symbol to a string. Removes ':' from keywords.")


(defun jerky//key/normalize (args)
  "Turn args into a key string.

(jerky//key/normalize '(\"a/b\" \"c\"))
  -> a/b/c
(jerky//key/normalize '(\"a/b\" c))
  -> a/b/c
(jerky//key/normalize '(\"a\" b c))
  -> a/b/c
"
  (let ((strings '()) ; List for processing args.
        (key  nil))   ; Final keypath string built from `strings'.
(cond ((stringp args)
	(setq strings (list args)))
	((listp args)
    (dolist (arg args)
      ;; Push string args to strings, turn non-strings into strings.
      (cond ((stringp arg)
             (push arg strings))

            ;; symbol->string: drop keyword prefix if exists.
            ((symbolp arg)
             (push (jerky//key/symbol->str arg) strings))

            ;; function->string:
            ((functionp arg)
             (push (funcall arg) strings))

            ;; fail
            (t
             (error (concat "%s: Can't convert '%S' to string for conversion "
                            "of keys into key list.")
                    "jerky//key/normalize"
                    arg))))))

    ;; Now we have strings. They are in backwards order. They need to be turned
    ;; into a final separated string.
    (setq key (s-join jerky/custom.key/separator
                      (nreverse strings)))

    ;; Return the full key string.
    key))
;; (jerky//key/normalize "a/b" "c")
;; (jerky//key/normalize :base "a/b" "c")


;;------------------------------------------------------------------------------
;; Reading from Key-Value Store
;;------------------------------------------------------------------------------

(defun jerky//repo/get (key)
  "Get the key-record plist in jerky's repo at KEY's location.
"
  (gethash key jerky//repo))


(defun jerky//repo.key/get (plist)
  "Get the `:key' from this key-record PLIST in jerky's repo.
"
  (plist-get plist :key))


(defun jerky//repo.record/get (plist)
  "Get the `:record' from this key-record PLIST in jerky's repo.
"
  (plist-get plist :record))


(defun jerky//repo.record.namespace/get (namespaces record)
  "Get the specific NAMESPACES's alist assoc from the key's record in the repo.

If NAMESPACES is a keyword, get exactly that namespace's.

If NAMESPACES is a list (from e.g. `jerky//namespace/ordered'), walk the list
in order and return record from first namespace that has one.
"
  ;; If one keyword, get it.
  (cond ((keywordp namespaces)
         (assoc namespaces record))

        ((listp namespaces)
         (let ((item nil))
           ;; Loop looking for an item in the record. Save it off for
           ;; returning if found.
           (dolist (ns namespaces item)
             (when (null item)
               (setq item (assoc ns record))))))

        (t
         (error (concat "jerky//repo.record.namespace/get: "
                        "`namespaces' must be a keyword or a list of them. "
                        "Got: %S")
                namespaces))))


(defun jerky//record.namespace/get (record)
  "Get the namespace of this record in jerky's repo.
"
  (nth 0 record))


(defun jerky//record.value/get (record)
  "Get the value of this record in jerky's repo.
"
    ;; value is at index 1
    (nth 1 record))


(defun jerky//record.docstr/get (record)
  "Get the docstr of this record in jerky's repo.
"
  ;; docstr is at index 2
  (nth 2 record))

;; TODO: change to names like the above funcs for rest of jerky?


(defun jerky/get (keys &rest args)
  "Gets a record's value from `jerky//repo'.

KEYS: A list of key strings/symbols/keywords, or a string key.

This uses keyword ARGS after the KEY. The keywords are:
  `:namespace'
     - The namespace to look in, and what fallbacks to use.
  `:field'
     - Can be: `:namespace', `:value', `:docstr'.
     - Defaults to `:value' if not supplied.

If nothing found at KEY, return will be nil.
"
  ;; Some shenanigans to do to turn 'args' into key args and plist args.
  (-let ((getter nil)
         (key (jerky//key/normalize keys))
         ;; dash-let's plist match pattern to non-keys in ARGS.
         ((&plist :namespace namespace :field field) args))

    ;; Check field... is it a known value?
    (cond ((memq field '(:namespace :value :docstr))
           (ignore))

          ;; Be the default.
          ((null field)
           (setq field :value))

          ;; Be the... error.
          (t
           (error "Unsupported value for `:field': %s. Only support: %S"
                  field '(:namespace :value :docstr))))

    ;; Set up getter.
    (cond ((eq field :namespace)
           (setq getter #'jerky//record.namespace/get))

          ((eq field :value)
           (setq getter #'jerky//record.value/get))

          ((eq field :docstr)
           (setq getter #'jerky//record.docstr/get)))

    ;; Ok... Get namespaced... whatever they asked for.
    (funcall getter
             ;; Filter all down to the namespace we want.
             (jerky//repo.record.namespace/get
              (jerky//namespace/ordered namespace 'quiet)
              ;; Get the record.
              (jerky//repo.record/get (jerky//repo/get key))))))
;; (jerky/get 'path 'to 'thing)
;; (jerky/get :test :jeff)
;; (jerky/get :test :jill)


;;------------------------------------------------------------------------------
;; Writing to Key-Value Store
;;------------------------------------------------------------------------------

(defun jerky//repo.record.namespace/set (namespace value docstr record)
  "Create/overwrite NAMESPACE's alist assoc in (a copy of) the record with the
new VALUE and DOCSTR.

If VALUE is `:jerky//action/delete', remove NAMESPACE's record instead.

Returns new, updated copy of record list that the old RECORD should be
replaced with.
"
  (if (null record)
      ;; No existing record. Create a new one.
      (list (list namespace value docstr))

    ;; Have the record! Delete or update it.
    (if (eq value :jerky//action/delete)
        ;; Delete record.
        (setf (alist-get namespace record
                         ;; DEFAULT set to same as new value for
                         ;; removing from alist. REMOVE set to non-nil.
                         :jerky//action/delete :jerky//action/delete)
              ;; New value must be eql to DEFAULT provided to alist-get.
              :jerky//action/delete)

      ;; Overwrite record.
      (setf (alist-get namespace record) (list value docstr))

      ;; Return the updated record.
      record)))
;; (setq jerky//alist/test '((:default "default value" "default ds")))
;; (jerky//repo.record.namespace/set :home "test" "test ds" 'jerky//alist/test)
;; jerky//alist/test


(defun jerky//repo.key/set (key plist)
  "Set the KEY in the hash table value PLIST.

Returns the updated plist. You set it back in place, as you may or may not
get a copy and the original may or may not have been destructievly updated.
"
  (plist-put plist :key key))
;; (jerky//repo.key/set 'jeff nil)


(defun jerky//repo.record/set (record plist)
  "Set the RECORD in the hash table value PLIST.

Returns the updated plist. You set it back in place, as you may or may not
get a copy and the original may or may not have been destructievly updated.
"
  (plist-put plist :record record))


(defun jerky//repo/set (key plist)
  "Create/overwrite the KEY in `jerky//repo', setting it to PLIST.

If PLIST is `:jerky//action/delete', remove KEY from `jerky//repo' instead.
"
  ;; Delete?
  (cond ((eq plist :jerky//action/delete)
         (remhash key jerky//repo))

        ;; Has the correct members for adding?
        ((and (plist-member plist :key)
              (plist-member plist :record))
         (puthash key plist jerky//repo))

        ;; Error out, I guess.
        (t
         (error (concat "jerky//repo/set: plist must be "
                        "`:jerky//action/delete' or an actual plist "
                        "with `:key' and `:record' members. Got: %s")
                plist))))


(defun jerky//repo/update (key namespace value docstr)
  "Create, delete, or update/overwrite a NAMESPACE'd VALUE with DOCSTR.
File it under KEY in `jerky//repo'.

To delete the NAMESPACE's value, pass `:jerky//action/delete' as the value.
"
  ;; Get existing plist value in our repo under key. Could be nil if it
  ;; doesn't exist; that's fine.
  (let* ((plist (jerky//repo/get key))
         (record (jerky//repo.record/get plist)))

    ;; plist/record will be nil if they don't exist.
    ;; The code path is the same for a brand new thing and for updating
    ;; an existing thing.

    (jerky//repo/set
     key
     ;; Make the record w/ plist from making the key.
     (jerky//repo.record/set
      (jerky//repo.record.namespace/set namespace value docstr record)
      ;; Make plist for the key.
      (jerky//repo.key/set key plist)))))


(defun jerky/set (keys &rest args)
  "Overwrite an existing record or add new record to `jerky//repo'.

KEYS: A list of key strings/symbols/keywords, or a string key.

This uses keyword ARGS after the KEY. The keywords are:
  `:value'
  `:docstr'
  `:namespace'

`:namespace'
  The argument after :namespace will be used as the namespace to set the
  data under. If no namespace is provided, this will only look under
  the default.

`:docstr'
  The argument after :docstr will be evaluated and stored as the
  documentation string.

`:value'
  The argument after :value will be stored as the value.

If not provided, they will be nil.
"
  ;; Some shenanigans to do to turn 'args' into key args and plist args.
  (-let ((key (jerky//key/normalize keys))
         ;; dash-let's plist match pattern to non-keys in ARGS.
         ((&plist :docstr docstr :value value :namespace namespace) args))

    ;; Get/update/create entries, set hash to key in repo.
    (jerky//repo/update key
                        (or namespace jerky/custom.namespace/default)
                        value
                        docstr)))
;; (jerky/set '(path to thing) :value "hello there")
;; (jerky/set '(:test :jeff) :value "jeffe" :docstr "I am a comment.")
;; (jerky/set "test/jeff" :value "jeffe")
;; (jerky/set "test/jill" :value "jill")


;;------------------------------------------------------------------------------
;; Searching the Repo.
;;------------------------------------------------------------------------------

;; todo: use maphash to walk over all the entries.
;; maphash takes a function w/ 2 args for calling for every record:
;;   (key value)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy/provide :spy 'jerky) ;; I have given you tasty jerky. Enjoy.
