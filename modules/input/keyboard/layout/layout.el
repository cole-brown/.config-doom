;;; input/keyboard/layout/layout.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║             Layout Definition & Keybind Mapping Functions              ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;             Keyboard-Layout-Aware `map!' equivalent and stuff!             ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; Constants
;;------------------------------

(defconst input//kl:layout:keyword/prefix ":layout:"
  "Keyboard layout keywords must always begin with ':layout:' so that they can
be parsed properly.")


;;------------------------------
;; Variables
;;------------------------------

(defvar input//kl:definitions:keywords nil
  "Definition of the keywords->functions created by calling
`input:keyboard/layout:define/keywords'.

Multiple calls to `input:keyboard/layout:define/keywords' accumulate the
result here.

Format:
  - alist of alists of cons:
    - type (:common, :emacs, :evil) -> keyword alist
      - keybind-keyword -> keybind-function")
;; (pp-macroexpand-expression input//kl:definitions:keywords)


;;------------------------------------------------------------------------------
;; Validity
;;------------------------------------------------------------------------------


(defun input//kl:layout:keyword/valid-name-regex (type)
  "Returns a layout keyword validation regex for the TYPE keyword
(:common, :emacs, :evil).

If type is invalid or has no string from `input//kl:layout:type->string',
returns nil."
  (when-let ((type/string (input//kl:layout:type->string type)))
    (rx-to-string
     `(sequence
       ;;---
       ;; Validate start/prefix.
       ;;---
       string-start
       ;; ":layout:"
       ,input//kl:layout:keyword/prefix
       ;; "emacs:"
       ,type/string
       ":"
       ;;---
       ;; Validate the name itself.
       ;;---
       ;; Could expand this more; I just want to disallow ":" for now.
       ;; May re-allow it if we want to use it for groupings
       ;; (e.g. :layout:evil:word:next-begin or something).
       (one-or-more (any "-" "/" "_" "?" alphanumeric))
       ;;---
       ;; Validate the end/postfix.
       ;;---
       string-end))))
;; (input//kl:layout:keyword/valid-name-regex :emacs)


(defun input//kl:layout:valid/keyword? (type keyword)
  "Is KEYWORD a keyword, is it a valid keyboard layout keyword, and is it named
correctly for TYPE?

Returns non-nil for valid KEYWORD."
  (when-let* ((valid/keyword? (keywordp keyword))
              (valid/name-rx (input//kl:layout:keyword/valid-name-regex type)))
    (string-match-p valid/name-rx (symbol-name keyword))))
;; (input//kl:layout:valid/keyword? :evil :layout:evil:valid_hello-there)
;; (input//kl:layout:valid/keyword? :evil :layout:evil:INVALID:hello-there)


(defun input//kl:layout:valid/function? (func)
  "Is FUNC a symbol or function symbol and is it a valid keybinding function?
`nil' is valid - it is used for unbinding already-bound keys."
  (or (null func)
      (and (symbolp func)
           (not (keywordp func))
           ;; Could get something that is not defined yet? In which case this
           ;; causes us to say it's invalid:
           ;; (functionp func)
           )))


;;------------------------------------------------------------------------------
;; Layout Keywords
;;------------------------------------------------------------------------------

(defmacro input:keyboard/layout:define/keywords (type _docstr &rest rest)
  "Define TYPE's layout keywords and their default functions in REST.

TYPE should be one of:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.

_DOCSTR: For you to document if desired - not preserved.

REST: Repeating list of: '(keyword function keyword function ...)"
  (declare (indent 1) (doc-string 2))

  ;;------------------------------
  ;; Parse all the keywords.
  ;;------------------------------
  (while rest
    (let* ((keyword (pop rest))
           (value (pop rest))
           (func (doom-unquote value)))

      ;;------------------------------
      ;; Error check vars.
      ;;------------------------------
      (cond ((not (keywordp keyword))
             (error (input//kl:error-message
                     "input:keyboard/layout:define/keywords"
                     "Expected a keyword, got: %S")
                    keyword))
            ((not (input//kl:layout:valid/keyword? type keyword))
             (error (input//kl:error-message
                     "input:keyboard/layout:define/keywords"
                     "Expected a valid keyboard layout keyword for '%S', got: %S")
                    type
                    keyword))

            ((not (symbolp func))
             (error (input//kl:error-message
                     "input:keyboard/layout:define/keywords"
                     "Expected a symbol, got: %S")
                    func))
            ((not (input//kl:layout:valid/function? func))
             (error (input//kl:error-message
                     "input:keyboard/layout:define/keywords"
                     "Expected a valid keyboard layout function, got: %S")
                    func))

            ((not (input//kl:layout:valid/type? type))
             (error (input//kl:error-message
                     "input:keyboard/layout:define/keywords"
                     "Type '%S' is not a valid type. "
                     "Must be one of: %S")
                    type input//kl:layout:types))

            (t
             nil))

      ;;------------------------------
      ;; Add this keyword entry to alist.
      ;;------------------------------
      ;; Use `input//kl:alist/update' so we overwrite a pre-existing.
      (when input//kl:debugging
        (let* ((kw-str (format "%S" keyword))
               (pad-str (input//kl:debug:fill (- 45    ; Enlarge as needed.
                                                 (length kw-str)
                                                 2)))) ; Preexisting pad spaces in msg.
          (input//kl:debug "input:keyboard/layout:define/keywords"
              '(:layout :define)
            "%s %s -> %-S"
            kw-str
            pad-str
            value)))
      (input//kl:alist/update-quoted keyword
                                     value ;; Save the quoted value, not `func'.
                                     input//kl:definitions:keywords
                                     t))))
;; input//kl:definitions:keywords
;; (setq input//kl:definitions:keywords nil)
;; (input:keyboard/layout:define/keywords :evil "docstring here" :layout:test-keyword #'ignore)
;; (alist-get :layout:test-keyword input//kl:definitions:keywords)


;;------------------------------------------------------------------------------
;; Layout Helpers
;;------------------------------------------------------------------------------

(defun input//kl:layout:normalize->func (keyword-or-func)
  "Normalizes a KEYWORD-OR-FUNC to a function."
  ;; "Function" can be nil for unbinding something, so get the entry to check
  ;; for its existance instead.
  (let ((key->func (input//kl:alist/entry keyword-or-func
                                          input//kl:definitions:keywords)))
    (cond
     ;; Did the keyword exist?
     (key->func
      ;; Return its function/nil.
      (cdr key->func))

     ;; Is a keyword; didn't find it. Error.
     ((keywordp keyword-or-func)
      (error (input//kl:error-message
              "input//kl:layout:normalize->func"
              "No known keyword for %S.")
             keyword-or-func))

     ;; Assume it was a function already, not a keyword, and return it as-is.
     (t
      keyword-or-func))))
;; (input//kl:layout:normalize->func :layout:evil:line-prev)
;; (input//kl:layout:normalize->func :layout:common:undefined)
;; (input//kl:layout:normalize->func :layout:DNE:should-error)


(defun input//kl:layout:normalize->modifier (symbol)
  "Normalizes a symbol, quoted symbol, or keyword to a modifier keyword."
  (let ((symbol/in (doom-unquote symbol)))
    (cond ((keywordp symbol/in)
           symbol/in)
          ((symbolp symbol/in)
           (intern (concat ":" (symbol-name symbol/in))))
          (t
           (error (input//kl:error-message
                   "input//kl:layout:normalize->modifier"
                   "Unknown input type: %S. Not a keyword or symbol.")
                  symbol)))))
;; (input//kl:layout:normalize->modifier ':control)
;; (input//kl:layout:normalize->modifier 'control)
;; (input//kl:layout:normalize->modifier (quote (quote control)))
;; (input//kl:layout:normalize->modifier 'unshift)
;; (input//kl:layout:normalize->modifier 'jeff)


;;------------------------------------------------------------------------------
;; Layout Derivations
;;------------------------------------------------------------------------------


(defun input//kl:layout:derive/search/in-progress (states func in-progress-map-forms)
  "Search `doom--map-batch-forms' for a match to the desired FUNC.

STATES should be a list of the evil state(s) of the existing keybind.

FUNC should be the function to search for.

IN-PROGRESS-MAP-FORMS should be `doom--map-batch-forms'.

Returns keybind string or nil."
  (let ((debug/tags '(:derive :derive/search))
        keybind-found)
    (while (and (not keybind-found)
                states)
      (let* ((state (car states))
             (search/bindings (alist-get state in-progress-map-forms)))
        (input//kl:debug
            "input//kl:layout:derive/search/in-progress"
            debug/tags
          "search state: %S" state)
        (setq states (cdr states))
        ;; Go through `search/bindings' until we run out or find something to return.
        (while (and (not keybind-found)
                    search/bindings)
          ;; Split the first `search/bindings' entry into key string and binding item (list or func).
          (let* ((key (nth 0 (car search/bindings)))
                 (binding (nth 1 (car search/bindings))))
            ;; Update `search/bindings' for next loop.
            (setq search/bindings (cdr search/bindings))

            ;; What is `binding', anyways?
            ;;     ;; Just the function; use it.
            (cond ((functionp (doom-unquote binding))
                   (input//kl:debug
                       "input//kl:layout:derive/search/in-progress"
                       debug/tags
                     "functionp %S == %S?: %S"
                     binding func
                     (eq (doom-unquote binding) (doom-unquote func)))
                   ;; If it's a match, save the key.
                   ;; Else ignore.
                   (when (eq (doom-unquote binding) (doom-unquote func))
                     (input//kl:debug
                         "input//kl:layout:derive/search/in-progress"
                         debug/tags
                       "functionp found %S -> %S" (doom-unquote func) key)
                     (setq keybind-found key)))

                  ;; A list which includes the function.
                  ((listp binding)
                   (input//kl:debug
                       "input//kl:layout:derive/search/in-progress"
                       debug/tags
                     "listp %S: t" binding)
                   ;; Find the function to return.
                   (dolist (each binding)
                     ;; If it's a function and matches, save the key.
                     ;; Else ignore.
                     (when (and (functionp (doom-unquote each))
                                (eq (doom-unquote each) (doom-unquote func)))
                       (input//kl:debug
                           "input//kl:layout:derive/search/in-progress"
                           debug/tags
                         "listp found %S -> %S" (doom-unquote func) key)
                       (setq keybind-found key))))

                  ;; Don't know - ignore? error?
                  (t
                   ;; Error for now - want to know about un-encountered types.
                   (error
                    (input//kl:error-message
                     "input//kl:layout:derive/search/in-progress"
                     "Don't know how to process this keybind setting "
                     "in order to search it for '%s': %S")
                    func
                    binding)
                   nil))))))
    ;; Done searching - return whatever we did (or didn't) find.
    keybind-found))
;; (let ((batch-forms '((motion
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("c" #'evil-previous-line))
;;                      (visual
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("c" #'evil-previous-line))
;;                      (normal
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("c" #'evil-previous-line)))))
;;   (message "\nevil-next-line:")
;;   (input//kl:layout:derive/search/in-progress '(motion) #'evil-next-line batch-forms)
;;   (message "\nevil-previous-line:")
;;   (input//kl:layout:derive/search/in-progress '(motion) #'evil-previous-line batch-forms))


(defun input//kl:layout:derive/search/existing (states func)
  "Search existing keybinds for a match to the desired FUNC.

STATES should be a list of the evil state(s) of the existing keybind.

FUNC should be the function to search for.

Uses general's `general-keybindings.

Returns keybind string or nil."
  (let ((search/maps general-keybindings)
        (debug/tags '(:derive :derive/search))
        keybind-found)
    (while (and (not keybind-found)
                states)
      (let ((state (car states)))
        (setq states (cdr states))

        ;; Search each keymap...
        (while (and (not keybind-found)
                    search/maps)
          ;; Split the first entry in `search/maps' up.
          (let* (;; (map-symbol (caar search/maps)) ;; (nth 0 (car search/maps)))
                 ;; For this symbol, we only care about the keybinds of `state'.
                 ;; So just get that state from the cdr/alist.
                 (search/bindings (alist-get state (cdar search/maps)))) ;; (cdr search/maps))))
            (input//kl:debug
                "input//kl:layout:derive/search/existing"
                debug/tags
              "searching map %S: bindings? %S"
              map-symbol
              (not (null search/bindings)))
            (input//kl:debug
                "input//kl:layout:derive/search/existing"
                debug/tags
              "search/bindings is: %S"
              search/bindings)
            ;; Search state's keybinds...
            (while (and (not keybind-found)
                        search/bindings)
              (input//kl:debug
                  "input//kl:layout:derive/search/existing"
                  debug/tags
                "  checking %S binding: %S"
                map-symbol (car search/bindings))
              ;; Split the first `search/bindings' entry into key string/vector and function bound.
              (let* ((bound-key (nth 0 (car search/bindings)))
                     (bound-func (nth 1 (car search/bindings))))
                (input//kl:debug
                    "input//kl:layout:derive/search/existing"
                    debug/tags
                  "    %S -> %S"
                  (kbd key) func)

                ;; Update `search/bindings' for next loop.
                (setq search/bindings (cdr search/bindings))

                ;; Check for match.
                (when (eq (doom-unquote bound-func) (doom-unquote func))
                  (input//kl:debug
                      "input//kl:layout:derive/search/existing"
                      debug/tags
                    "found %S -> %S"
                    (doom-unquote func) bound-key)
                  (setq keybind-found bound-key)))))

          ;; Update loop variable for next iteration.
          (setq search/maps (cdr search/maps)))))

    ;; Done searching - return whatever we did (or didn't) find.
    keybind-found))
;; (input//kl:layout:derive/search/existing '(normal) #'evil-backward-char)


(defun input//kl:layout:derive (states in-progress args)
  "Derive a `kbd' string from another function/layout-keyword's keybinding.

STATES should be a list of the evil state(s) of the existing keybind.

IN-PROGRESS should be all the current/in-progress `input//kl:layout:map-process' keybinds.
  - Which, currently, should be `doom--map-batch-forms'.

We will look through that and bound keys to figure out the correct derivation,
preferring `existing' over currently bound keys.

ARGS should be a list of:
  - Modifier key symbols:
    + `control'/`:control'
    + `shift'/`:shift'
    + `unshift'/`:unshift'
    + `meta'/`:meta'
    + `alt'/`:alt'
    + `super'/`:super'
    + `hyper'/`:hyper'
  - Keyword or function to derive the keybind from. E.g.:
    + :layout:evil:char-prev
    + #'evil-backward-char

`input:keyboard/layout:map!' Usage Examples:
    :nvm  \"o\"                                                 :layout:evil:char-prev
    :m    (:derive 'shift :layout:evil:char-prev)             :layout:evil:word-prev-end
    :m    (:derive 'meta 'unshift :layout:evil:word-prev-end) :layout:evil:word-prev-end-bigword"
  (let ((debug/tags '(:derive))
        modifiers
        keys)
    (input//kl:debug
        (format "input//kl:layout:derive(%s %S %S)"
                states in-progress args)
        debug/tags
      "Hello.")
    ;; Work through our args to build binding.
    (dolist (arg args)
      ;; What kind of arg is it?
      (cond ((memq (input//kl:layout:normalize->modifier arg)
                   '(:control :shift :meta ;; Common Modifiers
                     :alt :super :hyper    ;; Uncommon Modifiers
                     :unshift))            ;; Cheating a bit...
             (input//kl:debug
                 "input//kl:layout:derive"
                 debug/tags
               "    derive found modifier: %S"
               arg)
             (push (input//kl:layout:normalize->modifier arg) modifiers))

            ;; Our keyword/function we want to derive from.
            ;; Find its keybind string.
            ((or (functionp (doom-unquote arg))
                 (keywordp arg))
             (when-let* ((func (input//kl:layout:normalize->func arg))
                         (found (or
                                 ;; Search the in-progress keybinds for a match.
                                 (input//kl:layout:derive/search/in-progress states func in-progress)
                                 ;; Else, search for an existing keybind.
                                 (input//kl:layout:derive/search/existing states func))))
               ;; Found the keybind - save it.
               (input//kl:debug
                   "input//kl:layout:derive"
                   debug/tags
                 "    derive found key: %S"
                 arg)
               (push found keys)))

            ;; Fallthrough: Failed to parse arg - error.
            (t
             (input//kl:debug
                 "input//kl:layout:derive"
                 debug/tags
               "    derive found nothing - error: %S"
               arg)
             (error
              (input//kl:error-message "input//kl:layout:derive"
                                       "Don't know how to process '%S' (type: %S) for deriving keybind. derivation: %S")
              arg (type-of arg)
              args))))

    (input//kl:debug
        "input//kl:layout:derive"
        debug/tags
      "    derive: modifiers: %S"
      modifiers)
    (input//kl:debug
        "input//kl:layout:derive"
        debug/tags
      "    derive: keys: %S"
      keys)

    ;; Not sure what to do about trying to derive a 'control' keybind from a base of e.g. "mtt".
    ;; Do they want "C-m tt"? "C-m C-t C-t"?
    (when (and (> (length keys) 1)
               (> (length modifiers) 0)
               ;; Can probably let shift through? Would end up as, I think, "Mtt" currently.
               ;; Maybe they want "MTT"?
               (not (eq modifiers '(shift))))
      ;; Error until a good solution is figured out.
      (error
       (input//kl:error-message
        "input//kl:layout:derive"
        (concat "Don't have a good solution for deriving from multi-key sequences... "
                "modifiers: %S, original keybind: %S"))
       modifiers
       keys))

    ;; Join together the modifiers and keys to create the derived keybind.
    (let (mod/string
          downcasing)
      ;; Process modifiers.
      (dolist (mod/symbol modifiers)
        ;; Convert 'control -> "C-", etc for other modifiers.
        ;; Don't know an actual Emacs function that does this.
        (cond ((eq mod/symbol :control)
               (setq mod/string (concat mod/string "C-")))
              ((eq mod/symbol :shift)
               ;; Shift is capital "S".
               (setq mod/string (concat mod/string "S-")))
              ((eq mod/symbol :unshift)
               ;; Unshift is for downcasing a capital letter "S"->"s".
               ;; Also needs to 'downcase' "S-s" to "s".
               (setq downcasing t))
              ((eq mod/symbol :meta)
               (setq mod/string (concat mod/string "M-")))
              ((eq mod/symbol :hyper)
               (setq mod/string (concat mod/string "H-")))
              ((eq mod/symbol :super)
               ;; Super is lowercase 's'.
               (setq mod/string (concat mod/string "s-")))
              ((eq mod/symbol :alt)
               (setq mod/string (concat mod/string "A-")))
              (t
               (error
                (input//kl:error-message "input//kl:layout:derive"
                                         "Don't know how to process modifier '%s' for deriving keybind: %S")
                mod/symbol
                args))))

      ;; Check our `keys'? Zero is bad; more than one might be weird...
      (cond ((= (length keys) 0)
             (error
              (input//kl:error-message "input//kl:layout:derive"
                                       "No keybind found for: %S")
              args))
            ((> (length keys) 1)
             (error
              (input//kl:error-message "input//kl:layout:derive"
                                       "Not currently sure what to do with more than one keybind string. "
                                       "Found: %S, Args: %S")
              keys
              args))
            ;; Only one result in keys. Create and return resultant derived keybind string.
            (t
             (concat mod/string (key-description
                                     (input//kl:layout:derive/normalize-keys keys downcasing))))))))
;; (let ((batch-forms '((motion
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("C" #'evil-previous-line))
;;                      (visual
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("C" #'evil-previous-line))
;;                      (normal
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("C" #'evil-previous-line)))))
;;   ;; Should get "C-h" because char-prev is "h".
;;   (input//kl:layout:derive '(motion) batch-forms '(control :layout:evil:char-prev))
;;   ;; Should get "c" from unshifting "C".
;;   (input//kl:layout:derive '(motion) batch-forms '(unshift #'evil-previous-line)))


;; (defun input//kl:layout:derive/modifier-str? (key-str)
;;   "Returns non-nil if KEY-STR is a modifier string.
;;
;; Modifier strings are:
;;   - control: \"C-a\"
;;   - shift:   \"S-a\"
;;   - meta:    \"M-a\"
;;   - alt:     \"A-a\"
;;   - super:   \"s-a\"
;;   - hyper:   \"H-a\""
;;
;;   )


 (defun input//kl:layout:derive/normalize-keys (keys downcasing)
   "Normalize input params to a key string.

 KEYS should be a list of string.

 DOWNCASING should be nil, or not nil if KEYS should be downcased."
   keys)
;;   (if (null downcasing)
;;       ;; Currently no normalizing needs done; just return as-is.
;;       keys
;;     (let (normalized)
;;       ;; We expect only one string in the list, but we have no real requirement
;;       ;; to enforce this, so we can just be general/stupid.
;;       (dolist (key-str (reverse keys)) ;; Get output to be the correct way 'round.
;;         ;; Need to either unshift or remove "S-".
;;         (if (string-match (length keys)
;;         (push normalized (replace-regexp-in-string "S-" "" keys)))
;;
;;       ;; Also
;;
;;   )


;;------------------------------------------------------------------------------
;; Layout-Aware Keybind Mapping
;;------------------------------------------------------------------------------

(defun input//kl:layout:map-bind (keybind keyword-or-func &optional states desc)
  "Map KEYBIND to a function indicated by KEYWORD-OR-FUNC with DESC description string
for evil STATES.

If STATES is nil or is a list containing `global', the keybind will be global
(no evil state; this is different from evil's \"Emacs\" state and will work in
the absence of `evil-mode').

KEYBIND must be a `kbd'-type string describing the keybind and must fulfill
the `input//kl:layout:valid/keybind?' predicate.

KEYWORD-OR-FUNC must fulfill `input//kl:layout:valid/keyword?' predicate and /is not/
checked by this function. It will be translated to a function via the
`input//kl:definitions:keywords' alist.

DESC can be nil or a string describing the keybinding.

Used for side-effects; just returns non-nil (`t')."
  (let ((debug/tags '(:map :map/bind)))
    (input//kl:debug
        "input//kl:layout:map-bind"
        debug/tags
      "keybind: %S, keyword-or-func: %S, states: %S, desc: %S"
      keybind keyword-or-func states desc)

    ;;------------------------------
    ;; Normalize States.
    ;;------------------------------
    (when (or (memq 'global states)
              (null states))
      (setq states (cons 'nil (delq 'global states))))
    (input//kl:debug
        "input//kl:layout:map-bind"
        debug/tags
      "map-bind: keybind: %S, keyword-or-func: %S, states: %S, desc: %S"
      keybind keyword-or-func states desc)

    ;;------------------------------
    ;; Keyword -> Function
    ;;------------------------------
    ;; Is `keyword-or-func' a keyword? Assume a function if not.
    (let ((func (input//kl:layout:normalize->func keyword-or-func)))
      (when (keywordp func)
        (input//kl:debug
            "input//kl:layout:map-bind"
            debug/tags
          "Um... Unknown keybind keyword: %s -> %s"
          keyword-or-func func)
        (error
         (input//kl:error-message "input//kl:layout:map-bind"
                                  "Unknown keybind keyword: %s -> %s")
         keyword-or-func func))
      (input//kl:debug
          "input//kl:layout:map-bind"
          debug/tags
        "map-bind: keyword-or-func: %S -> func: %S"
        keyword-or-func func)
      ;; Empty string keybind and null func are modified into an ignored keybind.
      ;; Null func is an unbind.
      ;; So not much to error check...

      ;;------------------------------
      ;; Is it a derived keybind?
      ;;------------------------------
      ;; (input//kl:debug
      ;;     "input//kl:layout:map-bind"
      ;;     debug/tags
      ;;   "map-bind: IS IT DERIVED???: %S %S -> %S"
      ;;   (listp keybind)
      ;;   (if (listp keybind)
      ;;       (car keybind)
      ;;     "<nope>")
      ;;   (and (listp keybind)
      ;;        (eq (car keybind) :derive)))
      (when (and (listp keybind)
                 (eq (car keybind) :derive))
        (input//kl:debug
            "input//kl:layout:map-bind"
            debug/tags
          "  states: %S\n  batch-forms: %S\n derive-info: %S"
          states doom--map-batch-forms (cdr keybind))
        (input//kl:debug
            "input//kl:layout:map-bind"
            debug/tags
          "-->map-bind derived: %S <- %S"
          (input//kl:layout:derive states
                                   doom--map-batch-forms
                                   (cdr keybind))
          keybind)
        (let ((debug-orig keybind))
          (setq keybind
                ;; We've guarenteed that `states' is a list of at least `nil'.
                (input//kl:layout:derive states
                                         doom--map-batch-forms
                                         (cdr keybind)))
          (input//kl:debug
              "input//kl:layout:map-bind"
              debug/tags
            "input//kl:layout:map-bind: derived %S from: %S"
            keybind
            debug-orig)))

      ;;------------------------------
      ;; Process `desc' into `func'.
      ;;------------------------------
      (when desc
        (let (unquoted)
          (cond ((and (listp func)
                      (keywordp (car-safe (setq unquoted (doom-unquote func)))))
                 (setq func (list 'quote (plist-put unquoted :which-key desc))))
                ((setq func (cons 'list
                                  (if (and (equal keybind "")
                                           (null func))
                                      `(:ignore t :which-key ,desc)
                                    (plist-put (general--normalize-extended-def func)
                                               :which-key desc))))))))

      ;;------------------------------
      ;; Save Keybind.
      ;;------------------------------
      (dolist (state states)
        (push (list keybind func)
              (alist-get state doom--map-batch-forms))
        (input//kl:debug
            "input//kl:layout:map-bind"
            debug/tags
          "map-bind: SAVE: %S + %S -> %S"
          state keybind func))

      ;;------------------------------
      ;; Always return non-nil as expected by caller.
      ;;------------------------------
      t)))
;; input//kl:definitions:keywords
;; (setq doom--map-batch-forms nil)
;; (input//kl:layout:map-bind "c" :layout:evil:line-prev nil "testing...")
;; (doom--map-def "c" #'evil-prev-line nil "testing...")
;; (input//kl:layout:map-bind '(derive control :layout:evil:line-prev) :layout:evil:scroll-up (doom--map-keyword-to-states :n))
;; doom--map-batch-forms


(defun input//kl:layout:map-nested (wrapper rest)
  "Map a nested list in `input//kl:layout:map-process'."
  ;; Finish current map-forms.
  (doom--map-commit)
  ;; Setup for the nested call.
  (let ((doom--map-parent-state (doom--map-state)))
    (push (if wrapper
              (append wrapper (list (input//kl:layout:map-process rest)))
            (input//kl:layout:map-process rest))
          doom--map-forms)))


(defun input//kl:layout:map-process (rest)
  "Layout-aware backend for `map!' - equivalent to `doom--map-process'.

Create sexprs required for `map!' to be able to map keybinds based on its
input keywords and such."
  (let ((debug/tags '(:map :map/process))
        (doom--map-fn doom--map-fn)
        doom--map-state
        doom--map-forms
        desc)
    (while rest
      (let ((key (pop rest)))
        (input//kl:debug
            "input//kl:layout:map-process"
            debug/tags
          "MAP-PROCESS _KEY_ LOOP: %S"
          key)
        ;;------------------------------
        ;; Nested Mapping?
        ;;------------------------------
        (cond ((listp key)
               (input//kl:debug
                   "input//kl:layout:map-process"
                   debug/tags
                 "-cond->list: list: send to input//kl:layout:map-nested: %S" key)
               (input//kl:layout:map-nested nil key))

              ;;------------------------------
              ;; `map!' keyword to parse.
              ;;------------------------------
              ((keywordp key)
               (input//kl:debug
                   "input//kl:layout:map-process"
                   debug/tags
                 "-cond->keyword: keyword->pcase: %S" key)
               (pcase key
                 ;;---
                 ;; Leaders
                 ;;---
                 ;; Save off info for later.
                 (:leader
                  (input//kl:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->keyword: `%S': doom--map-fn -> `doom--define-leader-key'" key)
                  (doom--map-commit)
                  (setq doom--map-fn 'doom--define-leader-key))
                 (:localleader
                  (input//kl:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->keyword: `%S': doom--map-fn -> `define-localleader-key!'" key)
                  (doom--map-commit)
                  (setq doom--map-fn 'define-localleader-key!))
                 ;;---
                 ;; `:after'  - map as nested under an `after!' macro.
                 ;;---
                 (:after
                  (input//kl:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->keyword: `%S': Call `doom--map-nested'" key)
                  (input//kl:layout:map-nested (list 'after! (pop rest)) rest)
                  (setq rest nil))
                 ;;---
                 ;; Description
                 ;;---
                 ;; Save for next item that wants a description.
                 (:desc
                  (input//kl:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->keyword: `%S': setq desc: %S" key (car rest))
                  (setq desc (pop rest)))
                 ;;---
                 ;; Keymaps
                 ;;---
                 (:map
                  (input//kl:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->keyword: `%S': doom--map-set: %S" rest)
                  ;; TODO: do I need to remake `doom--map-set'?
                  (doom--map-set :keymaps `(quote ,(doom-enlist (pop rest)))))
                 ;;---
                 ;; Major Mode
                 ;;---
                 (:mode
                  (input//kl:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->keyword: `%S': Push mode stuff into rest." key)
                  (push (cl-loop for m in (doom-enlist (pop rest))
                                 collect (intern (concat (symbol-name m) "-map")))
                        rest)
                  (push :map rest))
                 ;;---
                 ;; Conditions
                 ;;---
                 ((or :when :unless)
                  (input//kl:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->keyword: `%S': -> `doom--map-nested'" key)
                  (doom--map-nested (list (intern (doom-keyword-name key)) (pop rest)) rest)
                  (setq rest nil))
                 ;;---
                 ;; Prefix/Prefix-Map
                 ;;---
                 (:prefix-map
                  (input//kl:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->keyword: `%S': create `doom-leader-%s-map'" key desc)
                  (cl-destructuring-bind (prefix . desc)
                      (doom-enlist (pop rest))
                    (let ((keymap (intern (format "doom-leader-%s-map" desc))))
                      (setq rest
                            (append (list :desc desc prefix keymap
                                          :prefix prefix)
                                    rest))
                      (push `(defvar ,keymap (make-sparse-keymap))
                            doom--map-forms))))
                 (:prefix
                  (input//kl:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->keyword: `%S': prefix stuff" key)
                  (cl-destructuring-bind (prefix . desc)
                      (doom-enlist (pop rest))
                    (input//kl:debug
                        "input//kl:layout:map-process"
                        debug/tags
                      "---pcase->:prefix: (%S . %S): rest=%S" prefix desc rest)
                    (doom--map-set (if doom--map-fn :infix :prefix)
                                   prefix)
                    (when (stringp desc)
                      (input//kl:debug
                          "input//kl:layout:map-process"
                          debug/tags
                        "---pcase->:prefix: string desc %S" desc)
                      (setq rest (append (list :desc desc "" nil) rest))
                      (input//kl:debug
                          "input//kl:layout:map-process"
                          debug/tags
                        "---pcase->:prefix: rest w/ desc -> %S" rest)
                      )))
                 ;;---
                 ;; Text Object Inner/Outer Keybind Pairing.
                 ;;---
                 (:textobj
                  (input//kl:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->keyword: `%S': text-objects-map stuff: key: %S, inner: %S, outer: %S"
                    key key inner outer)
                  (let* ((key (pop rest))
                         (inner (pop rest))
                         (outer (pop rest)))
                    (push `(map! (:map evil-inner-text-objects-map ,key ,inner)
                                 (:map evil-outer-text-objects-map ,key ,outer))
                          doom--map-forms)))
                 ;;---
                 ;; Fallthrough: Evil States
                 ;;---
                 (_
                  (input//kl:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->_/fallthrough: `%S': evil state? %S + %S -> %S"
                    key
                    (doom--map-keyword-to-states key)
                    (nth 0 rest)
                    (nth 1 rest))
                  ;; `doom--map-process' did a condition-case around this equivalent and then raised a different error message if an error
                  ;; was caught. But I want `input//kl:layout:map-bind' to do the erroring - it knows more than we do about what went wrong.
                  ;;
                  ;; Evil states are followed by a `kbd'-type string, then
                  ;; either a function or a layout-keyword to bind to the
                  ;; keyword/string.
                  ;;
                  ;; NOTE: Keep `progn'! I keep adding a debug print or something here and ruining the flow into
                  ;; `input//kl:layout:map-bind'...
                  (input//kl:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "-----map-bind->:state: %S=%S, %S -> %S"
                    key (doom--map-keyword-to-states key)
                    (nth 0 rest) (nth 1 rest))
                  (input//kl:layout:map-bind (pop rest)
                                             (pop rest)
                                             (doom--map-keyword-to-states key)
                                             desc)

                  ;; Reset `desc' since we used it.
                  (setq desc nil))))

              ;;------------------------------
              ;; Keybind string to map?
              ;;------------------------------
              (t
               (input//kl:debug
                   "input//kl:layout:map-process"
                   debug/tags
                 "-cond->t/default: 'string'?: %S -> %S" key (car rest))
               ;; Takes over for `doom--map-def' - handles normal string->func
               ;; and new layout-keyword->func functionality.
               (input//kl:layout:map-bind key
                                          (pop rest)
                                          nil
                                          desc)
               ;; We used `desc' - reset it.
               (setq desc nil)))))

    ;;------------------------------
    ;; Finalize
    ;;------------------------------
    ;; (pp-macroexpand-expression doom--map-forms)))
    (doom--map-commit)
    ;; Get rid of nils and order correctly.
    (macroexp-progn (nreverse (delq nil doom--map-forms)))))
;; (pp-macroexpand-expression (list :layout-keyword
;;                                  (input//kl:layout:map-process '(:desc "test" :nvm "t" :layout:line-next))
;;                                  :should-equal-keybind-string
;;                                  (doom--map-process '(:desc "test" :nvm "t" #'evil-next-line))))
;; (doom--map-process '(:nvm  "c"  :layout:evil:line-prev
;;                      :desc "hello" :nvm  "t"  :layout:evil:line-next
;;                      :nvm  "n"  :layout:evil:char-prev
;;                      :nvm  "h"  :layout:evil:char-next))


(defmacro input:keyboard/layout:map! (&rest rest)
  "A convenience macro for defining keyboard-layout-aware keybinds,
powered by `general' - equivalent to Doom's `map!' macro.

If evil isn't loaded, evil-specific bindings are ignored.

Properties
  :leader [...]                   an alias for (:prefix doom-leader-key ...)
  :localleader [...]              bind to localleader; requires a keymap
  :mode [MODE(s)] [...]           inner keybinds are applied to major MODE(s)
  :map [KEYMAP(s)] [...]          inner keybinds are applied to KEYMAP(S)
  :prefix [PREFIX] [...]          set keybind prefix for following keys. PREFIX
                                  can be a cons cell: (PREFIX . DESCRIPTION)
  :prefix-map [PREFIX] [...]      same as :prefix, but defines a prefix keymap
                                  where the following keys will be bound. DO NOT
                                  USE THIS IN YOUR PRIVATE CONFIG.
  :after [FEATURE] [...]          apply keybinds when [FEATURE] loads
  :textobj KEY INNER-FN OUTER-FN  define a text object keybind pair
  :when [CONDITION] [...]
  :unless [CONDITION] [...]

  Any of the above properties may be nested, so that they only apply to a
  certain group of keybinds.

States
  :n  normal
  :v  visual
  :i  insert
  :e  emacs
  :o  operator
  :m  motion
  :r  replace
  :g  global  (binds the key without evil `current-global-map')

  These can be combined in any order, e.g. :nvi will apply to normal, visual and
  insert mode. The state resets after the following key=>def pair. If states are
  omitted the keybind will be global (no emacs state; this is different from
  evil's Emacs state and will work in the absence of `evil-mode').

  These must be placed right before the keybind.

  Do
    (input:keyboard/layout:map! :leader :desc \"Description\" :n \"C-c\" #'dosomething)
    (input:keyboard/layout:map! :leader :desc \"Description\" :n \"C-c\" :layout:action-name)
  Don't
    (input:keyboard/layout:map! :n :leader :desc \"Description\" \"C-c\" #'dosomething)
    (input:keyboard/layout:map! :n :leader :desc \"Description\" \"C-c\" :layout:action-name)
    (input:keyboard/layout:map! :leader :n :desc \"Description\" \"C-c\" #'dosomething)
    (input:keyboard/layout:map! :leader :n :desc \"Description\" \"C-c\" :layout:action-name)

Keybinds
  A keybind is in two parts:
    1. The key, which is either:
       a. A `kbd' string - e.g. \"C-c\", \"SPC\", \"M-S-o\", \"x\", etc.)
       b. A `derive' list:
          - (derive 'meta #'dosomething)
          - (derive 'meta :layout:action-name)
          - Those will find the keybind for the func/keyword, and add \"M-\" to the `kbd' string.
    2. The binding, which can either be:
       - A keyboard-layout keyword (e.g. :layout:evil:line-prev).
       - A function symbol (e.g. #'evil-previous-line).
       - nil (which will unbind the key)."
  ;; Process args into a progn of calls to `general' to bind the keys.
  (input//kl:layout:map-process rest))
;; Dvorak keyboard right-handed WASD-type movement:
;; (input:keyboard/layout:map!
;;  :nvm  "c"  :layout:evil:line-prev
;;  :nvm  "t"  :layout:evil:line-next
;;  :nvm  "h"  :layout:evil:char-next
;;  :nvm  "n"  :layout:evil:char-prev)
;; (input:keyboard/layout:map! :nvm  "c"  :layout:evil:line-prev
;;                             :desc "hello" :nvm  "t"  :layout:evil:line-next
;;                             :nvm  "n"  :layout:evil:char-prev
;;                             :nvm  "h"  :layout:evil:char-next)


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
