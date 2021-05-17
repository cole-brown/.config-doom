;;; input/keyboard/map.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defvar input//kl:overwritten nil
  "`input//kl:entry/map' and
`input//kl:entry/unmap' use this to store any existing
keybinds for a key it is overwriting.")


;;------------------------------------------------------------------------------
;; Private Functions
;;------------------------------------------------------------------------------


(defun input//kl:get (type layout)
  "Get TYPE (`:functions' or `:keys') alist for LAYOUT keyword."
  (let (slot
        symbols)
    ;; Error check / set slot.
    (cond ((eq type :keys)
           (setq slot 0))
          ((eq type :functions)
           (setq slot 1))
          (t
           (error (concat "Module :input/keyboard/layout: `input//kl:get' "
                          "Unknown type '%S'. Must be either "
                          "`:keys' or `:functions'!")
                  type)))
    ;; Get layout's key/func symbol from `input//kl:layouts', and return
    ;; its alist value.
    (setq symbols (input//kl:alist/get layout input//kl:layouts))
    (if (not symbols)
        (error (concat "Module :input/keyboard/layout: `input//kl:get' "
                       "No '%S' for layout '%S'. Does layout exist and is it "
                       "currently registered in `input//kl:layouts'?")
                  type layout)
      (symbol-value (nth slot symbols)))))
;; (input//kl:get :keys :spydez)
;; (input//kl:get :functions :qwerty)
;; (input//kl:get nil :spydez)
;; (input//kl:get :keys :layout-invalid)


(defun input//kl:key (layout keymap keyword)
  "Looks up KEYWORD in LAYOUT's KEYMAP alist and returns the value
(a `kbd' string)."
  (cond ((eq layout input//kl:layout/active)
         (input//kl:alist/get keyword
                              (input//kl:alist/get keymap
                                                   (input//kl:get :keys layout))))
        ((eq layout input//kl:layout/default)
         (input//kl:alist/get keyword
                              (input//kl:alist/get keymap
                                                   (input//kl:get :keys layout))))
        (t
         (error (concat "Module :input/keyboard/layout: `input//kl:key' "
                        "Cannot find keyword '%S' for keymap '%S' "
                        "in layout '%S' as the layout is not the "
                        "active (%S) or default (%S).")
                keyword
                keymap
                layout
                input//kl:layout/active
                input//kl:layout/default))))
;; (input//kl:key :spydez nil :up)


(defun input//kl:value (layout keymap keyword)
  "Looks up KEYWORD in LAYOUT alist and returns the value.

Returns: (evil-states function)"
  (cond ((eq layout input//kl:layout/active)
         (input//kl:alist/get keyword
                              (input//kl:alist/get keymap
                                                   (input//kl:get :functions layout))))
        ((eq layout input//kl:layout/default)
         (input//kl:alist/get keyword
                              (input//kl:alist/get keymap
                                                   (input//kl:get :functions layout))))
        (t
         (error (concat "Module :input/keyboard/layout: `input//kl:function' "
                        "Cannot find keyword '%S' for layout '%S' as the "
                        "layout is not the active (%S) or default (%S).")
                keyword
                layout
                input//kl:layout/active
                input//kl:layout/default))))
;; (input//kl:value :spydez nil :up)


(defun input//kl:entry/map (layout keymap keyword)
  "Returns a `map!' entry list to unpack for mapping LAYOUT's
KEYWORD (translated to a `kbd' string) to FUNCTION in
EVIL-STATES.

Save information about what used to be bound to that key, as well as what now is
(FUNCTION). KEYMAP is only used for this saved info.

Returns: (EVIL-STATES kbd-string FUNCTION)"
  (let* ((key    (input//kl:key layout keymap keyword))
         (value  (input//kl:value layout keymap keyword))
         (states (nth 0 value))
         (func   (nth 1 value)))
    (input//kl:entry/overwrite keymap states key keyword func)
    (list states key func)))
;; (setq input//kl:overwritten nil)
;; (input//kl:entry/map :spydez nil :up)
;; input//kl:overwritten


(defun input//kl:entry/unmap (layout keymap keyword)
  "Returns a `map!' entry list to unpack for unbinding LAYOUT's KEYWORD key
in EVIL-STATES.

Save information about what used to be bound to that key, as well as what now is
(FUNCTION). KEYMAP is only used for this saved info.

Returns: (EVIL-STATES kbd-string nil)"
  (let* ((key    (input//kl:key layout keymap keyword))
         (value  (input//kl:value layout keymap keyword))
         (states (nth 0 value))
         (func   (nth 1 value))) ;; For recording overwrite.
    (input//kl:entry/overwrite keymap states key keyword func)
    ;; Return `nil' for function.
    (list states key nil)))


(defun input//kl:entry/overwrite (keymap evil-states key
                                  &optional keyword function)
  "Push a list of info about the params into
`input//kl:overwritten'.

KEYMAP should be a keymap symbol or nil for global.

EVIL-STATES should be:
  - :normal, :visual, :motion
  - :nv, :nvm, :mnv, etc.
  - See `map!' macro's help.

KEY should be a `kbd' string. It will be used to get existing keybinds from
`key-binding'.

KEYWORD and FUNCTION can be nil if unmapping a key.

If `key-binding' returns nil, this function does nothing."
  (when-let ((existing (key-binding key))
             (evil-states-normalized (doom--map-keyword-to-states evil-states)))
    ;; Add to the alist for the KEYMAP.
    (input//kl:alist/update
      keymap
      (input//kl:alist/string/update
        key
        (list evil-states-normalized
              (key-binding key)
              keyword
              function)
        (input//kl:alist/get keymap
                             input//kl:overwritten))
      input//kl:overwritten
      t)))


(defun input//kl:layout/bindings (layout)
  "Maps all keys to their evil-states and functions for LAYOUT keyword."
  ;; Gather a list of map entries from layout and format for `input:keyboard/layout:map!':
  ;;   entry: (evil-states key-keyword function)
  (let ((layout-keys (input//kl:get :keys layout))
        ;; Flat lists: one for global keymap, and one for all others.
        bindings-global
        bindings)
    (message ">>>> input//kl:layout/bindings: %s" layout)
    (message ">>>> input//kl:layout/bindings: keys: %S" layout-keys)
    ;; Do a mapping for each of the keymaps.
    (dolist (keymap-bindings layout-keys)
      (let ((keymap   (car keymap-bindings))
            (keywords (cdr keymap-bindings)))
        (when keymap
          ;; Put this keymap into the bindings so the following will all be under
          ;; it. Skipping for global keymap (nil).
          (push :map bindings)
          (push keymap bindings))

        ;; Now get all the bindings for said keymap parsed into the lists.
        (dolist (keyword-binding keywords)
          ;; Get the actual binding, and push into the correct bindings list one
          ;; at a time.
          (dolist (key-state-func
                   (input//kl:entry/map layout keymap (car keyword-binding)))
            (if keymap
                (push key-state-func bindings)
              (push key-state-func bindings-global))))))

    ;; Got all keybinds for all keymaps. Map 'em.
    (setq bindings (nreverse bindings))
    (setq bindings-global (nreverse bindings-global))
    (message ">>>> input//kl:layout/bindings: BINDINGS!!!:\n    %S"
             (append bindings-global bindings))
    (doom--map-process (append bindings-global bindings))))


;; (defun input//kl:movement (layout-old layout-new keymap evil-states)
;;   "Unmaps movement keys for EVIL-STATES in KEYMAP based on LAYOUT-OLD and remaps
;; based on LAYOUT-NEW."
;;   ;; Need to provide one flat list of stuff for the caller to unpack for `!map',
;;   ;; but `-flatten' deletes important `nil's... So use backquote function with
;;   ;; list splicing.
;;   (map!
;;    ;; Unbind from the old keys.
;;    `(,@(input//kl:entry/unmap layout-old keymap evil-states :left)
;;      ,@(input//kl:entry/unmap layout-old keymap evil-states :right)
;;      ,@(input//kl:entry/unmap layout-old keymap evil-states :down)
;;      ,@(input//kl:entry/unmap layout-old keymap evil-states :up)
;;
;;      ;; Rebind to the new keys.
;;      ,@(input//kl:entry/map layout-new keymap evil-states
;;                             :left   (input//kl:function layout-new :left))
;;      ,@(input//kl:entry/map layout-new keymap evil-states
;;                              :right (input//kl:function layout-new :right))
;;      ,@(input//kl:entry/map layout-new keymap evil-states
;;                              :down  (input//kl:function layout-new :down))
;;      ,@(input//kl:entry/map layout-new keymap evil-states
;;                              :up    (input//kl:function layout-new :up)))))
;; ;; (setq input//kl:overwritten nil)
;; ;; (input//kl:movement nil :nvm)
;; ;; (pp input//kl:overwritten)


;;------------------------------------------------------------------------------
;; Public Functions
;;------------------------------------------------------------------------------

;; TODO: does this work? If not, fix to be like `input:keyboard/layout:layout!'.
(defmacro input:keyboard/layout:map! (layout keymap &rest keywords)
  "`map!' helper for keyboard layouts.

Provide keyboard LAYOUT keyword symbol (e.g. `:dvorak') and some KEYWORDS in
the KEYMAP to `map!'. Each item in KEYWORDS a keyword that exists in the
LAYOUT's keys and functions alists.

Example:
  (input:keyboard/layout:map!
    :dvorak
    'org-mode-map
    :up :down :left :right
    :line-beginning)"
  (let ((mac:layout   (make-symbol "layout-type"))
        (mac:keymap   (make-symbol "layout-keymap"))
        (mac:keywords (make-symbol "layout-keywords")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,mac:layout   ,layout)
           (,mac:keymap   ,keymap)
           (,mac:keywords '(,@keywords))
           entries)
       (dolist (keyword ,mac:keywords entries)
         (push (input//kl:entry/map ,mac:layout
                                    ,mac:keymap
                                    keyword)
               entries))
       (input//kl:map!/all ,mac:keymap entries))))
;; (pp-macroexpand-expression (input:keyboard/layout:map! :spydez nil :up :down :left :right))


;; TODO: does this work? If not, fix to be like `input:keyboard/layout:layout!'.
(defmacro input:keyboard/layout:unmap! (layout keymap &rest keywords)
  "`map!' helper for keyboard layouts that unmaps KEYWORDS keybinds.

Provide keyboard LAYOUT keyword symbol (e.g. `:dvorak') and some
KEYWORDS to unmap in the KEYMAP via `map!'.
Example:
  (input:keyboard/layout:unmap!
    :dvorak
    'org-mode-map
    :up
    :line-beginning)"
  (let ((mac:layout   (make-symbol "layout-type"))
        (mac:keymap   (make-symbol "layout-keymap"))
        (mac:keywords (make-symbol "layout-keywords")))
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Argument-Evaluation.html#Argument-Evaluation
    ;; Eval inputs once.
    `(let ((,mac:layout   ,layout)
           (,mac:keymap   ,keymap)
           (,mac:keywords '(,@keywords))
           entries)
       (dolist (keyword ,mac:keywords entries)
         (push (input//kl:entry/unmap ,mac:layout
                                      ,mac:keymap
                                      keyword)
               entries))
       (input//kl:map!/all ,mac:keymap entries))))
;; (pp-macroexpand-expression (input:keyboard/layout:unmap! :spydez nil :up :down :left :right))
;; (input:keyboard/layout:unmap! :spydez nil :up :down :left :right)


(defmacro input:keyboard/layout:layout! (layout)
  "Map all of layout's evil-states & keybinds to their keymaps."
  (message ">>>>")
  (message ">>>>  input:keyboard/layout:layout! %S -> %S" layout (symbol-value layout))
  (message ">>>>")

  (input//kl:layout/bindings (symbol-value layout)))
;; (input:keyboard/layout:layout! :spydez)
;; (input:keyboard/layout:layout! input//kl:layout/active)
