;;; input/keyboard/layout/layout.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║             Layout Definition & Keybind Mapping Functions              ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;             Keyboard-Layout-Aware `map!' equivalent and stuff!             ;;
;;                                 ──────────                                 ;;


(imp:require :input 'keyboard 'vars)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; Constants
;;------------------------------

(defconst input//kl:layout:keyword/prefix ":layout:"
  "Keyboard layout keywords must always begin with ':layout:' so that they can
be parsed properly.")


(defconst input//kl:layout:derive/search/skips
  '((:after . 2)
    (:map . 2)
    (:prefix . 2)
    (:leader . 1)
    (:localleader . 1)
    (:mode . 2)
    (:prefix-map . 2)
    (:textobj . 4)
    (:when . 2)
    (:unless . 2))
  "List of keywords and number of items (including keyword) to skip.")

(defconst input//kl:layout:derive/search/ignores
  '(:derive)
  "List of keywords used to ignore entire lists during search.")


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

If type is invalid or has no string from `int<keyboard>:layout:type->string',
returns nil."
  (when-let ((type/string (int<keyboard>:layout:type->string type)))
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
             (int<keyboard>:output :error
                                   '("input:keyboard/layout:define/keywords"
                                     "Expected a keyword, got: %S")
                                   keyword))
            ((not (input//kl:layout:valid/keyword? type keyword))
             (int<keyboard>:output :error
                                   '("input:keyboard/layout:define/keywords"
                                     "Expected a valid keyboard layout keyword for '%S', got: %S")
                                   type
                                   keyword))

            ((not (symbolp func))
             (int<keyboard>:output :error
                                   '("input:keyboard/layout:define/keywords"
                                     "Expected a symbol, got: %S")
                                   func))
            ((not (input//kl:layout:valid/function? func))
             (int<keyboard>:output :error
                                   '("input:keyboard/layout:define/keywords"
                                     "Expected a valid keyboard layout function, got: %S")
                                   func))

            ((not (int<keyboard>:layout:type/valid? type))
             (int<keyboard>:output :error
                                   '("input:keyboard/layout:define/keywords"
                                     "Type '%S' is not a valid type. "
                                     "Must be one of: %S")
                                   type int<keyboard>:layout:types))

            (t
             nil))

      ;;------------------------------
      ;; Add this keyword entry to alist.
      ;;------------------------------
      ;; Use `int<keyboard>:alist:update' so we overwrite a pre-existing.
      (when int<keyboard>:debugging
        (let* ((kw-str (format "%S" keyword))
               (pad-str (int<keyboard>:debug:fill (- 45    ; Enlarge as needed.
                                                     (length kw-str)
                                                     2)))) ; Preexisting pad spaces in msg.
          (int<keyboard>:debug "input:keyboard/layout:define/keywords"
              '(:layout :define)
            "%s %s -> %-S"
            kw-str
            pad-str
            value)))
      (int<keyboard>:alist:update keyword
                                  value ;; Save the quoted value, not `func'.
                                  input//kl:definitions:keywords))))
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
  (let ((key->func (int<keyboard>:alist:get/pair keyword-or-func
                                                 input//kl:definitions:keywords)))
    (cond
     ;; Did the keyword exist?
     (key->func
      ;; Return its function/nil.
      (cdr key->func))

     ;; Is a keyword; didn't find it. Error.
     ((keywordp keyword-or-func)
      (int<keyboard>:output :error
                            '("input//kl:layout:normalize->func"
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
           (int<keyboard>:output :error
                                 '("input//kl:layout:normalize->modifier"
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

(defun input//kl:layout:derive/search/registered (func registered-binds)
  "Search REGISTERED-BINDS for a match to the desired FUNC.

FUNC should be the function to search for.

REGISTERED-BINDS should be `(input//kl:registrar:get registrar :keybinds)'.

Returns keybind string or nil."
  (let ((debug/tags '(:derive :derive/search))
        (func (input//kl:layout:normalize->func func))
        keybind-found
        (types int<keyboard>:layout:types))
    ;;------------------------------
    ;; Types: :evil, :emacs, :common
    ;;------------------------------
    (while (and (not keybind-found)
                types)
      (let* ((type (caar types)) ;; types is alist, and we want the keys.
             (keymaps (alist-get type registered-binds)))
        (setq types (cdr types)) ;; Drop current type kvp from alist.
        (int<keyboard>:debug
            "input//kl:layout:derive/search/registered"
            debug/tags
          "search type: %S" type)

        ;; Search this type's list.
        (setq keybind-found (input//kl:layout:derive/search/registered:in-list func keymaps))))

    ;; Done searching - return whatever we did (or didn't) find.
    (if keybind-found
        (int<keyboard>:debug
            "input//kl:layout:derive/search/registered"
            debug/tags
          "\n>>> [FOUND!]: %S" keybind-found)
      (int<keyboard>:debug
          "input//kl:layout:derive/search/registered"
          debug/tags
        "\n>>> [absent]: %S" keybind-found))
    keybind-found))
;; `registered-binds' example:
;; (pp (input//kl:registrar:get registrar :keybinds))
;; (input//kl:layout:derive/search/registered
;;  'evil-org-open-below
;;  ;; :layout:evil:state-insert-before
;;  '((:evil
;;     (:prefix ("s" . "Evil States")
;;      :nv "h" :layout:evil:state-insert-before
;;      :nv "n" :layout:evil:state-insert-after
;;      :n "t" :layout:evil:state-insert-line-open-below
;;      :n "c" :layout:evil:state-insert-line-open-above
;;      :n (:derive 'shift :layout:evil:state-insert-before) :layout:evil:state-insert-line-start
;;      :n (:derive 'shift :layout:evil:state-insert-after) :layout:evil:state-insert-line-end
;;      :n (:derive 'shift :layout:evil:state-insert-line-open-below) :layout:evil:state-replace
;;      :m "v" :layout:evil:state-visual-char-wise
;;      :m "V" :layout:evil:state-visual-line-wise)
;;     :nvm "." :layout:evil:line-prev
;;     :nvm "e" :layout:evil:line-next
;;     :nvm "o" :layout:evil:char-prev
;;     :nvm "u" :layout:evil:char-next
;;     :m "A" :layout:evil:word-prev-begin
;;     :m (:derive 'shift :layout:evil:char-prev) :layout:evil:word-prev-end
;;     :m (:derive 'shift :layout:evil:char-next) :layout:evil:word-next-begin
;;     :m "I" :layout:evil:word-next-end
;;     :m (:derive 'meta 'unshift :layout:evil:word-prev-begin) :layout:evil:word-prev-begin-bigword
;;     :m (:derive 'meta 'unshift :layout:evil:word-prev-end) :layout:evil:word-prev-end-bigword
;;     :m (:derive 'meta 'unshift :layout:evil:word-next-begin) :layout:evil:word-next-begin-bigword
;;     :m (:derive 'meta 'unshift :layout:evil:word-next-end) :layout:evil:word-next-end-bigword
;;     :m "(" :layout:evil:sentence-begin-prev
;;     :m ")" :layout:evil:sentence-begin-next
;;     :m "{" :layout:evil:paragraph-prev
;;     :m "}" :layout:evil:paragraph-next
;;     :m (:derive 'control :layout:evil:line-prev) :layout:evil:scroll-up
;;     :m (:derive 'control :layout:evil:line-next) :layout:evil:scroll-down
;;     :m (:derive 'control 'meta :layout:evil:line-prev) :layout:evil:scroll-page-up
;;     :m (:derive 'control 'meta :layout:evil:line-next) :layout:evil:scroll-page-down
;;     :m (:derive 'control :layout:evil:char-prev) :layout:evil:line-begin
;;     :m (:derive 'control :layout:evil:char-next) :layout:evil:line-end
;;     (:after org
;;      :after evil-org
;;      :map evil-org-mode-map
;;      (:prefix ("s" . "Evil States")
;;       :n "t" #'evil-org-open-below)))))


(defun input//kl:layout:derive/search/registered:in-list (func keymaps)
  "Search KEYMAPS for a match to the desired FUNC.

FUNC should be the function to search for.

KEYMAPS should be a list suitable for `input:keyboard/layout:map!'.

Returns keybind string or nil."
  ;;------------------------------
  ;; Keymaps
  ;;------------------------------
  (let ((debug/tags '(:derive :derive/search))
        (debug/name "input//kl:layout:derive/search/registered:in-list")
        (keymaps/len (length keymaps))
        (index 0)
        found/start
        found/keybind)
    (int<keyboard>:debug
        debug/name
        debug/tags
      "search for `%S' in list: %S"
      func keymaps)

    (while (and (not found/start)
                (not found/keybind)
                (< index keymaps/len))
      (let ((item (nth index keymaps)))
        (int<keyboard>:debug
            debug/name
            debug/tags
          "Start search here? index: %d, item: %S"
          index item)

        ;; Get past any `:map' or such.
        (cond ((and (keywordp item) ;; Currently everything in skips is a keyword.
                    (alist-get item input//kl:layout:derive/search/skips))
               ;; `:after <mode-name>'
               ;; `:map <map-name'
               ;; etc.
               (setq index (+ index (alist-get item input//kl:layout:derive/search/skips))))

              ((and (listp item)
                    (memq (car item) input//kl:layout:derive/search/ignores))
               (setq index (1+ index)))

              ((listp item)
               ;; Search down into this list...
               (int<keyboard>:debug
                   debug/name
                   debug/tags
                 "Search into list first: %d -> %S"
                 index item)

               (setq found/keybind (input//kl:layout:derive/search/registered:in-list func item))

               ;; And prep for if it failed to find anything.
               (setq index (1+ index)))

              (t
               (setq found/start index)))))

    (int<keyboard>:debug
        debug/name
        debug/tags
      "Start search at index %d: %S"
      index (nth index keymaps))

    ;; Return something now or finish searching the KEYMAPS.
    (cond (found/keybind
           (int<keyboard>:debug
               debug/name
               debug/tags
             "Already found: %d; found: %S"
             index found/keybind)
           found/keybind)

          (found/start
           ;; Search through the rest of the list for the FUNC.
           (while (and (not found/keybind)
                       (< index keymaps/len))

             ;; Want something like:
             ;;   :nvm "." :layout:evil:line-prev
             ;;   "." #'func
             (let* ((item (nth index keymaps)))
               (int<keyboard>:debug
                   debug/name
                   debug/tags
                 "Searching at: %d -> %S"
                 index item)

               (cond
                ;; A thing to search down into?
                ((listp item)
                 (int<keyboard>:debug
                     debug/name
                     debug/tags
                   "Searching into list at: %d -> %S"
                   index item)

                 ;; Search down into this list...
                 (setq found/keybind (input//kl:layout:derive/search/registered:in-list func item))

                 ;; And prep for if it failed to find anything.
                 (setq index (1+ index)))

                ;; Are we looking at: <states-keyword> <keybind> <func/func-keyword>?
                ((condition-case nil
                     (doom--map-keyword-to-states item)
                   ;; Ignore error signal from `doom--map-keyword-to-states'.
                   (error nil))

                 (let ((check/key (nth (+ index 1) keymaps))
                       (check/func (input//kl:layout:normalize->func (nth (+ index 2) keymaps))))
                   (int<keyboard>:debug
                       debug/name
                       debug/tags
                     "Found evil states/key/bind at: %d -> %S %S %S"
                     index item check/key check/func)
                   (when (eq (doom-unquote check/func) (doom-unquote func))
                     (setq found/keybind check/key)))

                 (setq index (+ index 3)))

                ;; Are we looking at: <keybind> <func/func-keyword>?
                ((stringp item)
                 (let ((check/key (nth index keymaps))
                       (check/func (input//kl:layout:normalize->func (nth (1+ index) keymaps))))
                   (int<keyboard>:debug
                       debug/name
                       debug/tags
                     "Found emacs states/key/bind at: %d -> %S %S"
                     index item check/key check/func)

                   (setq index (+ index 2))

                   (when (eq (doom-unquote check/func) (doom-unquote func))
                     (setq found/keybind check/key))))

                ;; Dunno. Skip.
                (t
                 (setq index (1+ index))))))

           (int<keyboard>:debug
               debug/name
               debug/tags
             "Search result for: %d -> %S"
             index found/keybind)
           ;; Done searching - return whatever we did (or didn't) find.
           found/keybind)

          (t
           (int<keyboard>:debug
               debug/name
               debug/tags
             "Nothing at: %d"
             index)
           ;; Nothing of note in this KEYMAPS list?
           nil))))


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
        (int<keyboard>:debug
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
                   ;; (int<keyboard>:debug
                   ;;     "input//kl:layout:derive/search/in-progress"
                   ;;     debug/tags
                   ;;   "functionp %S == %S?: %S"
                   ;;   binding func
                   ;;   (eq (doom-unquote binding) (doom-unquote func)))

                   ;; If it's a match, save the key.
                   ;; Else ignore.
                   (when (eq (doom-unquote binding) (doom-unquote func))
                     (int<keyboard>:debug
                         "input//kl:layout:derive/search/in-progress"
                         debug/tags
                       "functionp found %S -> %S" (doom-unquote func) key)
                     (setq keybind-found key)))

                  ;; A list which includes the function.
                  ((listp binding)
                   (int<keyboard>:debug
                       "input//kl:layout:derive/search/in-progress"
                       debug/tags
                     "listp %S: t" binding)
                   ;; Find the function to return.
                   (dolist (each binding)
                     ;; If it's a function and matches, save the key.
                     ;; Else ignore.
                     (when (and (functionp (doom-unquote each))
                                (eq (doom-unquote each) (doom-unquote func)))
                       (int<keyboard>:debug
                           "input//kl:layout:derive/search/in-progress"
                           debug/tags
                         "listp found %S -> %S" (doom-unquote func) key)
                       (setq keybind-found key))))

                  ;; Don't know - ignore? error?
                  (t
                   ;; Error for now - want to know about un-encountered types.
                   (int<keyboard>:output :error
                                         '("input//kl:layout:derive/search/in-progress"
                                           "Don't know how to process this keybind setting "
                                           "in order to search it for '%s': %S")
                                         func
                                         binding)
                   nil))))))

    ;; Done searching - return whatever we did (or didn't) find.
    (if keybind-found
        (int<keyboard>:debug
            "input//kl:layout:derive/search/in-progress"
            debug/tags
          "\n>>> [FOUND!]: %S" keybind-found)
      (int<keyboard>:debug
          "input//kl:layout:derive/search/in-progress"
          debug/tags
        "\n>>> [absent]: %S" keybind-found))
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
;;   (input//kl:layout:derive/search/in-progress '(motion) #'evil-next-line batch-forms)
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
          (let* (;; For this symbol, we only care about the keybinds of `state'.
                 ;; So just get that state from the cdr/alist.
                 (search/bindings (alist-get state (cdar search/maps))))
            (int<keyboard>:debug
                "input//kl:layout:derive/search/existing"
                debug/tags
              "bindings? %S"
              (not (null search/bindings)))
            (int<keyboard>:debug
                "input//kl:layout:derive/search/existing"
                debug/tags
              "search/bindings is: %S"
              search/bindings)
            ;; Search state's keybinds...
            (while (and (not keybind-found)
                        search/bindings)
              (int<keyboard>:debug
                  "input//kl:layout:derive/search/existing"
                  debug/tags
                "  checking binding: %S"
                (car search/bindings))
              ;; Split the first `search/bindings' entry into key string/vector and function bound.
              (let* ((bound-key (nth 0 (car search/bindings)))
                     (bound-func (nth 1 (car search/bindings))))
                (int<keyboard>:debug
                    "input//kl:layout:derive/search/existing"
                    debug/tags
                  "    %S -> %S"
                  (int<keyboard>:output:normalize/key bound-key) func)

                ;; Update `search/bindings' for next loop.
                (setq search/bindings (cdr search/bindings))

                ;; Check for match.
                (when (eq (doom-unquote bound-func) (doom-unquote func))
                  (int<keyboard>:debug
                      "input//kl:layout:derive/search/existing"
                      debug/tags
                    "found %S -> %S"
                    (doom-unquote func) bound-key)
                  (setq keybind-found bound-key)))))

          ;; Update loop variable for next iteration.
          (setq search/maps (cdr search/maps)))))

    ;; Done searching - return whatever we did (or didn't) find.
    (if keybind-found
        (int<keyboard>:debug
            "input//kl:layout:derive/search/existing"
            debug/tags
          "\n>>> [FOUND!]: %S" keybind-found)
      (int<keyboard>:debug
          "input//kl:layout:derive/search/existing"
          debug/tags
        "\n>>> [absent]: %S" keybind-found))
    keybind-found))
;; (input//kl:layout:derive/search/existing '(normal) #'evil-backward-char)


(defun input//kl:layout:derive (states keybinds/in-progress keybinds/registered args)
  "Derive a `kbd' string from another function/layout-keyword's keybinding.

STATES should be a list of the evil state(s) of the existing keybind.

KEYBINDS/IN-PROGRESS should be all the current/in-progress
`input//kl:layout:map-process' keybinds.
  - Which, currently, should be `doom--map-batch-forms'.

KEYBINDS/REGISTERED should be all the registered-but-not-yet-applied
`input//kl:layout:map-process' keybinds.
  - Which should be `(input//kl:registrar:get registrar :keybinds)'.

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
    :m    (:derive 'meta 'unshift :layout:evil:word-prev-end) :layout:evil:word-prev-end-bigword

Returns the derived kbd string.
Examples:
  1. If `:layout:evil:word-prev-end' is \"A\":
    (:derive 'meta 'unshift :layout:evil:word-prev-end)
      -> \"M-a\"
  2. If `:layout:evil:word-prev-end' is \"C-A\":
    (:derive 'meta :layout:evil:word-prev-end)
      -> \"M-C-A\""
  (let ((debug/tags '(:derive))
        modifiers
        keys)
    (int<keyboard>:debug
        "input//kl:layout:derive"
        debug/tags
      "INPUTS: \n  states: %S\n  args: %S\n  in-progress: %S\n  registered: %S"
      states args keybinds/in-progress keybinds/registered)

    ;; Work through our args to build binding.
    (dolist (arg args)
      ;; What kind of arg is it?
      (cond ((memq (input//kl:layout:normalize->modifier arg)
                   '(:control :shift :meta ;; Common Modifiers
                     :alt :super :hyper    ;; Uncommon Modifiers
                     :unshift))            ;; Cheating a bit...
             (int<keyboard>:debug
                 "input//kl:layout:derive"
                 debug/tags
               "derive found modifier: %S"
               arg)
             (push (input//kl:layout:normalize->modifier arg) modifiers))

            ;; Our keyword/function we want to derive from.
            ;; Find its keybind string.
            ((or (functionp (doom-unquote arg))
                 (keywordp arg))
             (when-let* ((func (input//kl:layout:normalize->func arg))
                         ;; Search for a keybind in order of what will be the bind when everything is applied and done.
                         (found (or
                                 ;; Search the in-progress keybinds for a match.
                                 (input//kl:layout:derive/search/in-progress states func keybinds/in-progress)
                                 ;; Search the registered-but-not-applied keybinds for a match...
                                 (input//kl:layout:derive/search/registered func keybinds/registered)
                                 ;; Search for an existing keybind.
                                 (input//kl:layout:derive/search/existing states func))))
               ;; Found the keybind - save it.
               (int<keyboard>:debug
                   "input//kl:layout:derive"
                   debug/tags
                 "derive found key: %S"
                 arg)
               (push found keys)))

            ;; Fallthrough: Failed to parse arg - error.
            (t
             (int<keyboard>:debug
                 "input//kl:layout:derive"
                 debug/tags
               "derive found nothing - error: %S"
               arg)
             (int<keyboard>:output :error"input//kl:layout:derive"
                                   "Don't know how to process '%S' (type: %S) for deriving keybind. derivation: %S"
                                   arg
                                   (type-of arg)
                                   args))))

    (int<keyboard>:debug
        "input//kl:layout:derive"
        debug/tags
      "\n  --> Final Modifiers: %S"
      modifiers)
    (int<keyboard>:debug
        "input//kl:layout:derive"
        debug/tags
      "\n  --> Final Keys: %S"
      keys)

    ;; Not sure what to do about trying to derive a 'control' keybind from a base of e.g. "mtt".
    ;; Do they want "C-m tt"? "C-m C-t C-t"?
    (when (and (> (length keys) 1)
               (> (length modifiers) 0)
               ;; Can probably let shift through? Would end up as, I think, "Mtt" currently.
               ;; Maybe they want "MTT"?
               (not (eq modifiers '(shift))))
      ;; Error until a good solution is figured out.
      (int<keyboard>:output :error
                            "input//kl:layout:derive"
                            '("Don't have a good solution for deriving from multi-key sequences... "
                              "modifiers: %S, original keybind: %S")
                            modifiers
                            keys))

    ;; Join together the modifiers and keys to create the derived keybind.
    (let (mod/string
          ;; nil - no change, :lower - downcase/lowercase, :upper - uppercase/upcase
          (string/case nil))
      ;; Process modifiers.
      (dolist (mod/symbol modifiers)
        ;; Convert 'control -> "C-", etc for other modifiers.
        ;; Don't know an actual Emacs function that does this.
        (cond ((eq mod/symbol :control)
               (setq mod/string (concat mod/string "C-")))
              ((eq mod/symbol :shift)
               ;; Shift should be capital "S"? But it isn't working for me.
               ;; (setq mod/string (concat mod/string "S-"))
               ;; Instead let's try upcasing.
               (setq string/case :upper))
              ((eq mod/symbol :unshift)
               ;; Unshift is for downcasing a capital letter "S"->"s".
               ;; Also needs to 'downcase' "S-s" to "s"?
               (setq string/case :lower))
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
               (int<keyboard>:output :error
                                     "input//kl:layout:derive"
                                     "Don't know how to process modifier '%s' for deriving keybind: %S"
                                     mod/symbol
                                     args))))

      ;; Check our `keys'? Zero is bad; more than one might be weird...
      (cond ((= (length keys) 0)
             (int<keyboard>:output :error
                                   "input//kl:layout:derive"
                                   "No keybind found for: %S"
                                   args))

            ((> (length keys) 1)
             (int<keyboard>:output :error
                                   "input//kl:layout:derive"
                                   '("Not currently sure what to do with more than one keybind string. "
                                     "Found: %S, Args: %S")
                                   keys
                                   args))

            ;; Only one result in keys. Create and return resultant derived keybind string.
            (t
             ;; But do we first have to recurse because we're deriving from a derive?
             (cond
              ;; Nope; this is good.
              ((and (listp keys)
                    (stringp (car keys)))
               (int<keyboard>:debug
                   "input//kl:layout:derive"
                   debug/tags
                 "\n[DERIVE]\n>>>>> %S <-- %S"
                 (concat mod/string (key-description
                                     (input//kl:layout:derive/normalize-keys keys string/case)))
                 args)
               (concat mod/string (key-description
                                   (input//kl:layout:derive/normalize-keys keys string/case))))

              ;; Yep; search for what this key is derived from.
              ((and (listp keys)
                    (eq (car keys) :derive))
               (int<keyboard>:debug
                   "input//kl:layout:derive"
                   debug/tags
                 "\n  --> RECURSIVE DERIVE: %S\n[DERIVE:recurse-start]"
                 keys)

               ;; Get recursion result.
               (setq keys (input//kl:layout:derive states
                                                   keybinds/in-progress
                                                   keybinds/registered
                                                   (cdr keys)))
               (int<keyboard>:debug
                   "input//kl:layout:derive"
                   debug/tags
                 "\n[DERIVE:recurse-end]\n[DERIVE]\n>>>>> %S <-- %S"
                 (concat mod/string (key-description
                                     (input//kl:layout:derive/normalize-keys keys string/case)))
                 args)
               (concat mod/string (key-description
                                   (input//kl:layout:derive/normalize-keys keys string/case))))

              ;; No idea - error.
              (t
               (int<keyboard>:debug
                   "input//kl:layout:derive"
                   debug/tags
                 "\n  --> RECURSIVE DERIVE: %S\n[DERIVE:recurse-start]"
                 keys))))))))
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


;; TODO: This?
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

(defun input//kl:layout:derive/normalize-keys (keys case)
  "Normalize input params to a key string.

KEYS should be a list of strings.

CASE should be:
  - nil (no change)
  - :upper (upcase/uppercase)
  - :lower (lowercase/downcase)"
  ;; Validate KEYS.
  (dolist (each keys)
    (unless (stringp each)
      (int<keyboard>:output :error
                            "input//kl:layout:derive/normalize-key"
                            '("KEYS must contain all strings - found '%S' "
                              "(type '%S') in it: %S")
                            each
                            (type-of each)
                            keys)))

  ;; Normalize KEYS list to a string. Expecting it to be backwards from
  ;; `push'ing elements on.
  (let ((key (apply #'concat (reverse keys)))
        (debug/tags '(:derive :derive/normalize)))
    ;; "S-" doesn't work, turns out, so I'm removing it from the code in baby steps...
    ;; TODO: delete this
    ;; ;; Get rid of any "shift modifiers" in it.
    ;; (setq key (replace-regexp-in-string "S-" "" key))

    ;; Valid: To lower/upper cases.
    (cond ((eq case :upper)
           (int<keyboard>:debug "input//kl:layout:derive/normalize-key"
               debug/tags
             "UPPERCASE: keys: %S, case: %S -> %S"
             keys case (upcase key))
           (upcase key))
          ((eq case :lower)
           (int<keyboard>:debug "input//kl:layout:derive/normalize-key"
               debug/tags
             "lowercase: keys: %S, case: %S -> %S"
             keys case (upcase key))
           (downcase key))

          ;; Valid: "Do nothing" case.
          ((null case)
           (int<keyboard>:debug "input//kl:layout:derive/normalize-key"
               debug/tags
             "As-Is: keys: %S, case: %S -> %S"
             keys case (upcase key))
           ;; No normalizing needs done; just return as-is.
           key)

          ;; Invalid: CASE is wrong.
          (t
           (int<keyboard>:output :error
                                 "input//kl:layout:derive/normalize-key"
                                 "Unknown CASE input: %s. Valid inputs are: %S"
                                 case
                                 '(nil :lower :upper))))))
;; (input//kl:layout:derive/normalize-keys '("LLO" "he") nil)
;; (input//kl:layout:derive/normalize-keys '("LLO" "he") :lower)
;; (input//kl:layout:derive/normalize-keys '("LLO" "he") :upper)


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
    (int<keyboard>:debug
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
    (int<keyboard>:debug
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
        (int<keyboard>:debug
            "input//kl:layout:map-bind"
            debug/tags
          "Um... Unknown keybind keyword: %s -> %s"
          keyword-or-func func)
        (int<keyboard>:output :error
                              "input//kl:layout:map-bind"
                              "Unknown keybind keyword: %s -> %s"
                              keyword-or-func func))
      (int<keyboard>:debug
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
      ;; (int<keyboard>:debug
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
        (int<keyboard>:debug
            "input//kl:layout:map-bind"
            debug/tags
          "  states: %S\n  batch-forms: %S\n derive-info: %S"
          states doom--map-batch-forms (cdr keybind))
        (int<keyboard>:debug
            "input//kl:layout:map-bind"
            debug/tags
          "-->map-bind derived: %S <- %S"
          (input//kl:layout:derive states
                                   doom--map-batch-forms
                                   (input//kl:registrar:get registrar :keybinds)
                                   (cdr keybind))
          keybind)
        (let ((debug-orig keybind))
          (setq keybind
                ;; We've guarenteed that `states' is a list of at least `nil'.
                (input//kl:layout:derive states
                                         doom--map-batch-forms
                                         (input//kl:registrar:get registrar :keybinds)
                                         (cdr keybind)))
          (int<keyboard>:debug
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
        (int<keyboard>:debug
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
        (int<keyboard>:debug
            "input//kl:layout:map-process"
            debug/tags
          "MAP-PROCESS _KEY_ LOOP: %S"
          key)
        ;;------------------------------
        ;; Nested Mapping?
        ;;------------------------------
        (cond ((listp key)
               (int<keyboard>:debug
                   "input//kl:layout:map-process"
                   debug/tags
                 "-cond->list: list: send to input//kl:layout:map-nested: %S" key)
               (input//kl:layout:map-nested nil key))

              ;;------------------------------
              ;; `map!' keyword to parse.
              ;;------------------------------
              ((keywordp key)
               (int<keyboard>:debug
                   "input//kl:layout:map-process"
                   debug/tags
                 "-cond->keyword: keyword->pcase: %S" key)
               (pcase key
                 ;;---
                 ;; Leaders
                 ;;---
                 ;; Save off info for later.
                 (:leader
                  (int<keyboard>:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->keyword: `%S': doom--map-fn -> `doom--define-leader-key'" key)
                  (doom--map-commit)
                  (setq doom--map-fn 'doom--define-leader-key))
                 (:localleader
                  (int<keyboard>:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->keyword: `%S': doom--map-fn -> `define-localleader-key!'" key)
                  (doom--map-commit)
                  (setq doom--map-fn 'define-localleader-key!))
                 ;;---
                 ;; `:after'  - map as nested under an `after!' macro.
                 ;;---
                 (:after
                  (int<keyboard>:debug
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
                  (int<keyboard>:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->keyword: `%S': setq desc: %S" key (car rest))
                  (setq desc (pop rest)))
                 ;;---
                 ;; Keymaps
                 ;;---
                 (:map
                  (int<keyboard>:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->keyword: `%S': doom--map-set: %S" key rest)
                  ;; TODO: do I need to remake `doom--map-set'?
                  (doom--map-set :keymaps `(quote ,(doom-enlist (pop rest)))))
                 ;;---
                 ;; Major Mode
                 ;;---
                 (:mode
                  (int<keyboard>:debug
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
                  (int<keyboard>:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->keyword: `%S': -> `doom--map-nested'" key)
                  (doom--map-nested (list (intern (doom-keyword-name key)) (pop rest)) rest)
                  (setq rest nil))
                 ;;---
                 ;; Prefix/Prefix-Map
                 ;;---
                 (:prefix-map
                  (int<keyboard>:debug
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
                  (int<keyboard>:debug
                      "input//kl:layout:map-process"
                      debug/tags
                    "---pcase->keyword: `%S': prefix stuff" key)
                  (cl-destructuring-bind (prefix . desc)
                      (doom-enlist (pop rest))
                    (int<keyboard>:debug
                        "input//kl:layout:map-process"
                        debug/tags
                      "---pcase->:prefix: (%S . %S): rest=%S" prefix desc rest)
                    (doom--map-set (if doom--map-fn :infix :prefix)
                                   prefix)
                    (when (stringp desc)
                      (int<keyboard>:debug
                          "input//kl:layout:map-process"
                          debug/tags
                        "---pcase->:prefix: string desc %S" desc)
                      (setq rest (append (list :desc desc "" nil) rest))
                      (int<keyboard>:debug
                          "input//kl:layout:map-process"
                          debug/tags
                        "---pcase->:prefix: rest w/ desc -> %S" rest)
                      )))
                 ;;---
                 ;; Text Object Inner/Outer Keybind Pairing.
                 ;;---
                 (:textobj
                  (int<keyboard>:debug
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
                  (int<keyboard>:debug
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
                  (int<keyboard>:debug
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
               (int<keyboard>:debug
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
