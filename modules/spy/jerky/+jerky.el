;; -*- mode: emacs-lisp; lexical-binding: t -*-


;;---------------------Like spy/dirky, but, like, general.----------------------
;;--                      So... Generlky? Genky?... Hm.                       --
;;-------------------------------(or, maybe...)---------------------------------
;;├────────────────────────────────┼ jerky ┼───────────────────────────────────┤


(require 's)
(require 'dash)
(spy/require :spy 'zero 'strings)
(spy/require :spy 'jerky 'debug)

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
;; Helpers
;;------------------------------------------------------------------------------

(defun jerky//parse (args-list keywords &rest extra-keywords)
  "Splits ARGS-LIST into keys, and keyword arg/value pairs.

KEY: A list of key strings/symbols/keywords, or a string key, or
a mix. These must come before any of the keyword args.

Keyword key/value pairs only exist after the KEYS. The keywords can be defined
by passing in a list of KEYWORDS '(:value :fallback), or passing `t' for the
defaults, which are:
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

If EXTRA-KEYWORDS are supplied, will prepend them to the usual returned plist.

Returns a 2-tuple list of:
  - jerky key parsed
  - plist of keys/values parsed.

If a keyword is requested but doesn't exist in the keys, their value in the
output will be nil.
"
  (-let* ((keywords (cond ((null keywords)   ; Must be supplied something.
                           (error "jerky//parse: keywords cannot be null: %S" keywords))
                          ((listp keywords)  ; Given list? Use it.
                           keywords)
                          (t                 ; Use the defaults.
                           ;; Backwards so they'll end up forwards.
                           '(:docstr :value :namespace))))
          ((args kwargs) (apply #'spy/lisp/func.args
                                args-list
                                keywords))
          parsed)

    ;; If extra keywords, add first so they're at the end of the plist.
    (when (not (null extra-keywords))
      ;; Look for extra keywords.
      (dolist (key extra-keywords)
        ;; Add key and value (nil default) to output.
        (push (plist-get kwargs key) parsed)
        (push key parsed)))

    ;; Now look for the usual keywords...
    (dolist (key keywords)
        ;; Add key and value (nil default) to output.
        (push (plist-get kwargs key) parsed)
        (push key parsed))

    ;; And build our tuple output.
    (list (jerky//key/normalize args) parsed)))
;; (jerky//parse '(foo bar baz :namespace qux :value 1) t)
;; (jerky//parse '(foo bar baz :namespace qux :value 1 :baz "hello") t :baz :DNE)
;; (jerky//parse '(foo bar baz :namespace nil :value 1) t)


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

(defun jerky//namespace/valid (potential-namespace &optional quiet)
  "Validates POTENTIAL-NAMESPACE.

Doesn't care if it exists or not; just if it's a good
possible-or-current-or-whatever namespace.

Returns t/nil if QUIET is non-nil, else it signals error on failure.
"
  (if (keywordp potential-namespace)
      t
    (if quiet
        nil
      (error "%s: namespace must be a keyword. %S"
             "jerky//namespace/valid" potential-namespace))))
;; (jerky//namespace/valid :jeff)
;; (jerky//namespace/valid 'jeff t)
;; (jerky//namespace/valid 'jeff)
;; (jerky//namespace/valid 'not-keyword)

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


(defun jerky//namespace.entry/set (namespace title docstr fallbacks)
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
    (dolist (fb-ns (-non-nil fallbacks))
      (cond ((eq fb-ns :jerky/namespace/no-fallback)
             (push fb-ns verified-fallbacks))

            ((not (keywordp fb-ns))
             (error (concat "jerky//namespace.entry/set: "
                            "FALLBACK must be a keyword: %s")
                    fb-ns))

            ((not (jerky//namespace/ordered fb-ns 'quiet))
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
  (-let* (((&plist :docstr docstr :title title :fallbacks fallbacks) args)
          ;; Make fallbacks a flat list of inputs or the default.
          (fallbacks (-flatten (or fallbacks
                                   jerky/custom.namespace/default))))

    ;; Set new entry.
    (jerky//namespace/set
     ;; Make new entry from provided args.
     (jerky//namespace.entry/set namespace title docstr fallbacks))))
;; (jerky/namespace/create :the-namespace :title "hello there" :docstr "jeff" :fallbacks '(a b c))
;; (jerky/namespace/create :the-namespace :title "hello there" :docstr "jeff")


(defun jerky/namespace/has (namespace)
  "Returns t if namespace is present in `jerky/custom.namespace/default'.
"
  (not (null (assoc namespace jerky//namespaces))))
;; (jerky/namespace/has :jeff)


(defun jerky//namespace/ordered (namespace &optional quiet)
  "Gets a namespace & its fallbacks.

If NAMESPACE isn't found, returns `jerky/custom.namespace/default' entry.

If QUIET is non-nil, don't output messages/warnings.
"
  (let ((entry (assoc namespace jerky//namespaces))
        (namespaces nil)
        (stop? nil))

    ;; No entry at all? Default to default.
    (when (null entry)
      (unless quiet
        (warn "%s: No namespace found for: %s. Using default: %s"
              "jerky//namespace/ordered"
              namespace
              jerky/custom.namespace/default))

      (setq entry (assoc jerky/custom.namespace/default jerky//namespaces))
      (when (null entry)
        (unless quiet
          (warn (concat "jerky//namespace/ordered: No default namespace "
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
    (nreverse namespaces)))
;; (jerky//namespace/ordered :default)
;; (jerky//namespace/ordered :work)
;; (jerky//namespace/ordered :jeff)


(defun jerky/namespace.get ()
  "Looks for a namespace to use.

Checks/returns first to be non-nil of:
  - `jerky//dlv/namespace.local' if jerky DLV is in use.
  - Jerky key: 'namespace 'system
  - `jerky/custom.namespace/default'
"
  (if (and (featurep 'jerky/dlv)
              (not (null jerky//dlv/namespace.local)))
      jerky//dlv/namespace.local

    (if-let ((system (jerky/get 'namespace 'system)))
        system
      jerky/custom.namespace/default)))
;; (jerky/namespace.get)


;;------------------------------------------------------------------------------
;; Key Functions
;;------------------------------------------------------------------------------

(defalias 'jerky//key/symbol->str 'spy/string/symbol->str
  "Convert a symbol to a string. Removes ':' from keywords.")


(defun jerky//key/normalize (args &optional quiet)
  "Turn args into a key string.

(jerky//key/normalize '(\"a/b\" \"c\"))
  -> a/b/c
(jerky//key/normalize '(\"a/b\" c))
  -> a/b/c
(jerky//key/normalize '(\"a\" b c))
  -> a/b/c
"
  (if (null args)
      nil
    (let ((strings '()) ; List for processing args.
          (key  nil))   ; Final keypath string built from `strings'.
      ;; If just a string, turn into our `strings' list.
      (cond ((stringp args)
             (setq strings (list args)))

            ;; If a list, turn each item into a string and push to the `strings' list.
            ((listp args)
             (dolist (arg (-flatten args)) ; Just want one level of list.
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
                      (if quiet
                          nil
                        (error (concat "%s: Can't convert '%S' to string for conversion "
                                       "of keys into key list.")
                               "jerky//key/normalize"
                               arg)))))))

      ;; Now we have strings. They are in backwards order. They need to be turned
      ;; into a final separated string.
      (setq key (s-join jerky/custom.key/separator
                        (nreverse strings)))

      ;; Return the full key string.
      key)))
;; (jerky//key/normalize "a/b")
;; (jerky//key/normalize "a/b" "c")
;; (jerky//key/normalize :base "a/b" "c")
;; (jerky//key/normalize nil)


(defun jerky/key.str (&rest keys)
  "Returns the jerky key string obtained by combining & normalizing the ARGS."
  (jerky//key/normalize keys))
;; (jerky/key.str "a/b")
;; (jerky/key.str 'a :b)
;; (jerky/key.str "a/b" "c")
;; (jerky/key.str :base "a/b" "c")


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


(defun jerky//record.dlv/get (record)
  "Get the dlv sub-record of this record in jerky's repo.
"
  ;; dlv is at index 3 or does not exist
  (nth 3 record))


(defun jerky//record.dlv/is (record)
  "Returns t if the record is a jDLV record, else nil.
"
  ;; dlv is at index 3 or does not exist
  (not (null (nth 3 record))))
;; (jerky//record.dlv/is '(:ns 42 "hello" ("c:/jeff/dir" 'klassy)))
;; (jerky//record.dlv/is '(:ns 42 "hello"))


(defun jerky//record.dlv.directory/get (record &optional quiet)
  "Get the dlv directory, if this is a dlv RECORD, else error/nil based on QUIET."
  (nth 0
       (or (jerky//record.dlv/get record)
           (if quiet
               nil
             (error "%s: Record is not a jDLV record; cannot get directory: %S"
                    "jerky//record.dlv.directory/get"
                    record)))))
;; (jerky//record.dlv.directory/get '(:ns 42 "hello" ("c:/jeff/dir" 'klassy)))


(defun jerky//record.dlv.class/get (record &optional quiet)
  "Get the dlv class, if this is a dlv RECORD, else error/nil based on QUIET."
  (nth 1
       (or (jerky//record.dlv/get record)
           (if quiet
               nil
             (error "%s: Record is not a jDLV record; cannot get directory: %S"
                    "jerky//record.dlv.directory/get"
                    record)))))
;; (jerky//record.dlv.directory/get '(:ns 42 "hello" ("c:/jeff/dir" 'klassy)))


(defun jerky/get (&rest keys-and-options)
  "Gets a record's value from `jerky//repo'.

Splits KEYS-AND-OPTIONS into keys, and optional keyword arg/value pairs.

KEY: A list of key strings/symbols/keywords, or a string key, or
a mix. These must come before any of the optional keyword args.

Keyword key/value pairs only exist after the KEYS. The keywords are:
  `:namespace'
     - The namespace to look in, and what fallbacks to use.
  `:field'
     - Can be: `:namespace', `:value', `:docstr',
       - and for jDLV also: `:dlv', `:directory', `:class'
     - Defaults to `:value' if not supplied.

If nothing found at KEY, return will be nil.
"
  ;; Some shenanigans to do to turn input into key/kwargs,
  ;; then kwargs into options.
  (-let* (((key kwargs) (jerky//parse keys-and-options
                                       '(:namespace :field)))
          (getter nil)
          ((&plist :namespace namespace :field field) kwargs)
          (dbg.func "jerky/get"))

    (jerky//debug dbg.func "key: %s" key)
    (jerky//debug dbg.func "kwargs: %s" kwargs)
    (jerky//debug dbg.func "namespace: %s, key: %s" namespace key)

    ;; Check field... is it a known value?
    (cond ((memq field '(:namespace :value :docstr :dlv :directory :class))
           ;; Known values are good. Leave them be.
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
           (setq getter #'jerky//record.docstr/get))

          ;; Just return t/nil if asked for `:dlv' directly.
          ((eq field :dlv)
           (setq getter #'jerky//record.dlv/is))

          ((eq field :directory)
           (setq getter #'jerky//record.directory/get))

          ((eq field :class)
           (setq getter #'jerky//record.class/get)))


    ;; Ok... Get namespaced... whatever they asked for.
    (when jerky//debugging
      (jerky//debug dbg.func
                    "ordered namespaces: %s"
                    (jerky//namespace/ordered namespace 'quiet)))
    (funcall getter
             ;; Filter all down to the namespace we want.
             (jerky//repo.record.namespace/get
              (jerky//namespace/ordered namespace 'quiet)
              ;; Get the record.
              (jerky//repo.record/get (jerky//repo/get key))))))
;; (jerky/get 'path 'to 'thing)
;; (jerky/get :test :jeff)
;; (jerky/get :test :jill)
;; (jerky/get '(signature id sigil))
;; (jerky/get '(signature id sigil) :namespace :work)
;; (jerky/get '(signature id email) :namespace :work)


;;------------------------------------------------------------------------------
;; Writing to Key-Value Store
;;------------------------------------------------------------------------------

(defun jerky//repo.record.namespace/set (namespace value docstr record
                                         &optional dlv directory class)
  "Create/overwrite NAMESPACE's alist assoc in (a copy of) the record with the
new VALUE and DOCSTR.

If VALUE is `:jerky//action/delete', remove NAMESPACE's record instead.

If DLV is `t', DIRECTORY and CLASS are also required for this jDLV repo KEY.

Returns new, updated copy of record list that the old RECORD should be
replaced with.
"
  (if (null record)
      ;; No existing record. Create a new one.
      (if (eq dlv t)
          ;; jerky directory-local-variable record
          (list (list namespace value docstr (list directory class)))
        ;; Normal jerky record.
        (list (list namespace value docstr)))

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
      (setf (alist-get namespace record)
            (if (eq dlv t)
                ;; jerky directory-local-variable record
                (list value docstr (list directory class))
              ;; normal record
              (list value docstr)))

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


(defun jerky//repo/update (key namespace value docstr &optional dlv directory class)
  "Create, delete, or update/overwrite a NAMESPACE'd VALUE with DOCSTR.
File it under KEY in `jerky//repo'.

To delete the NAMESPACE's value, pass `:jerky//action/delete' as the value.

If DLV is `t', DIRECTORY and CLASS are also required for this jDLV repo KEY.
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
      (jerky//repo.record.namespace/set namespace value docstr record
                                        dlv directory class)
      ;; Make plist for the key.
      (jerky//repo.key/set key plist)))))


(defun jerky/set (&rest keys-and-options)
  "Overwrite an existing record or add new record to `jerky//repo'.

Splits KEYS-AND-OPTIONS into keys, and keyword arg/value pairs.

KEY: A list of key strings/symbols/keywords, or a string key, or
a mix. These must come before any of the keyword args.

Keyword key/value pairs only exist after the KEYS. The keywords are:
  `:value'
  `:docstr'
  `:namespace'
  Jerky Directory-Local-Variables (jDLV) Only!
    `:dlv'
    `:directory'
    `:class'

`:namespace'
  The argument after :namespace will be used as the namespace to set the
  data under. If no namespace is provided, this will only look under
  the default.

`:docstr'
  The argument after :docstr will be evaluated and stored as the
  documentation string.

`:value'
  The argument after :value will be stored as the value.

jDLV-Only:
  `:dlv'
    Must be `t'.

  `:directory'
    The directory that the jDLVs apply to.

  `:class'
    The class name provided to `dir-locals-set-class-variables' and
    `dir-locals-set-directory-class'.

If not provided, they will be nil.
"
  ;; Some shenanigans to do to turn input into args/kwargs into a key
  ;; and values.
  (-let* (((key kwargs) (jerky//parse keys-and-options t
                                       :dlv :directory :class))
          ;; dash-let's plist match pattern to non-keys in ARGS.
          ((&plist :docstr :value :namespace :dlv :directory :class) kwargs))

    ;; Get/update/create entries, set hash to key in repo.
    (jerky//repo/update key
                        (or namespace jerky/custom.namespace/default)
                        value
                        docstr
                        dlv
                        directory
                        class)))
;; (jerky/set '(path to thing) :value "hello there")
;; (jerky/set '(:test :jeff) :value "jeffe" :docstr "I am a comment.")
;; (jerky/set :test "jeff" :value "jeffe overwrite" :docstr "I am not a comment.")
;; (jerky/set "test/jeff" :value "jeffe")
;; (jerky/set "test/jill" :value "jill")


;;------------------------------------------------------------------------------
;; Searching the Repo.
;;------------------------------------------------------------------------------

(defun jerky//search/filter (search-key &optional namespace)
  "Walks jerky//repo and returns anything that matches (potentially partial)
SEARCH-KEY and (optional) NAMESPACE.

KEYS /must/ be normalized already!

If NAMESPACE is nil, all namespaces will be matched.

Returns list of results or nil.

Result format is: '(full-key-str namespace-keyword value)

Note that this is /not/ an alist, as the same key (differing namespaces)
can exist multiple times.
"
  (let ((results nil))
    ;; Maphash's function must take only: key and value.
    (maphash (lambda (key value)
               (when (and (stringp key)
                          (s-starts-with? search-key key))
                 ;; Matched key; get record from 'value'.
                 (if-let ((records (jerky//repo.record/get value)))
                     (dolist (rec records)
                       ;; Check namespace if needed; add rec if matches.
                       (when (or (null namespace)
                                 (eq namespace (jerky//record.namespace/get rec)))
                         (push (list key
                                     (jerky//record.namespace/get rec)
                                     (jerky//record.value/get rec))
                               results))))))
             jerky//repo)

    ;; Return whatever we found.
    results))
;; (jerky//search/filter "signature/id")
;; (jerky//search/filter "signature/id" :work)


(defun jerky/has (&rest keys-and-options)
  "Returns a list of keys/options for any keys that match the partial or
complete key path in KEYS-AND-OPTIONS.

Splits KEYS-AND-OPTIONS into keys, and optional keyword arg/value pairs.

KEY: A list of key strings/symbols/keywords, or a string key, or
a mix. These must come before any of the optional keyword args.

Keyword key/value pairs only exist after the KEYS. The keywords are:
  `:namespace'
     - The namespace to look in, and what fallbacks to use.

Returns: alist of keys/namespaces or nil

Example:
  - KEYS-AND-OPTIONS: \"path/to\"
  '((:work \"path/to/jeff\")
    (:default \"path/to/jill\"))
"
  ;; Some shenanigans to do to turn input into args/kwargs into a key
  ;; and a namespace.
  (-let* (((partial-key kwargs) (jerky//parse keys-and-options '(:namespace)))
          ;; dash-let's plist match pattern to non-keys in ARGS.
          ((&plist :namespace namespace) kwargs))

    (jerky//debug "jerky/has" "keys-and-options: %S" keys-and-options)
    (jerky//debug "jerky/has" "  -> key:    %S" partial-key)
    (jerky//debug "jerky/has" "  -> kwargs: %S" kwargs)
    (jerky//debug "jerky/has" "partial-key: %S" partial-key)
    (jerky//debug "jerky/has" "namespace:   %S" namespace)
    ;; Now we can search & filter.
    (jerky//search/filter partial-key namespace)))
;; (jerky/has 'signature 'id)
;; (jerky/has "signature/id")
;; (jerky/has 'signature 'id :namespace :work)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy/provide :spy 'jerky) ;; I have given you tasty jerky. Enjoy.
(provide 'jerky)
