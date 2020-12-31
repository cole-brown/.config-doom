;;; config/spy/keybinds.el -*- lexical-binding: t; -*-


(spy/require :spy 'io 'signature)


;;------------------------------------------------------------------------------
;; Align Regex Helpers
;;------------------------------------------------------------------------------
;; `Align-Regex' helper function idea came from this nice chap:
;; http://pragmaticemacs.com/emacs/aligning-text/

(defun smd/align-before (start end text)
  "Align columns by whitespace before TEXT. E.g. with text \"+=\" and region:
  Jeff.Jet(jeff.it).onClick += OnJeffClick;
  Jeff.Jet(jefferson.it).onClick += OnJeffersonClick;
becomes
  Jeff.Jet(jeff.it).onClick      += OnJeffClick;
  Jeff.Jet(jefferson.it).onClick += OnJeffersonClick;

Align currently selected region (if interactive), or region
indicated by START and END.
"
  (interactive "r\nsAlign Before: ")

  (let ((regexp (rx-to-string `(sequence
                                ;; target group: whitespace before input text
                                (group (zero-or-more whitespace))
                                ,text))))
    ;; (message "%S %S %S %S" start end text regexp)
    (align-regexp start end
                  regexp
                  ;; target group 1, min spacing 1, no repeat.
                  1 1 nil)))


(defun smd/align-after (start end text)
  "Align columns by whitespace after TEXT. E.g. with text \"+=\" and region:
  Jeff.Jet(jeff.it).onClick += OnJeffClick;
  Jeff.Jet(jefferson.it).onClick += OnJeffersonClick;
becomes
  Jeff.Jet(jeff.it).onClick +=      OnJeffClick;
  Jeff.Jet(jefferson.it).onClick += OnJeffersonClick;

Align currently selected region (if interactive), or region
indicated by START and END.
"
  (interactive "r\nsAlign After: ")

  (let ((regexp (rx-to-string `(sequence
                                ,text
                                ;; target group: whitespace after input text
                                (group (zero-or-more whitespace))))))
    ;; (message "%S %S %S %S" start end text regexp)
    (align-regexp start end
                  regexp
                  ;; target group 1, min spacing 1, no repeat.
                  1 1 nil)))


;;------------------------------------------------------------------------------
;; Fill/Unfill Commands, Functions, Hydras
;;------------------------------------------------------------------------------

;; from: nhoffman http://nhoffman.github.io/.emacs.d/#org40b27e4
;;   which is from: http://defindit.com/readme_files/emacs_hints_tricks.html
;;     which is from: Stefan Monnier <foo at acm.org>
;;       which is probably from the turtles that go all the way down
;;
;; This is actually the inverse of fill-paragraph. Takes a multi-line paragraph
;; and makes it into a single line of text.
(defun smd/fill/paragraph/unfill ()
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))


(defun _s//fill/paragraph/fn-for-mode ()
  "Mode-aware fill-paragraph so I only have to bind one thing in
the fill hydra. Separated the 'get func' out here so I can see if
in a mode with a special fill for hydra hinting."
  (cond
   ((derived-mode-p 'csharp-mode)
    #'c-fill-paragraph)

   ;; c-mode and all derivatives
   ((and (functionp 'c-buffer-is-cc-mode)
         (c-buffer-is-cc-mode))
    #'c-fill-paragraph)

   ;; elisp, other lispses
   ((or (derived-mode-p 'emacs-lisp-mode)
        (derived-mode-p 'lisp-mode))
    #'lisp-fill-paragraph)
   ;; Might just use `fill-paragraph'?
   ;; Seems to be what "M-q" is using right now?

   ;; python-mode
   ((derived-mode-p 'python-mode) #'python-fill-paragraph)

   ;; org-mode
   ((derived-mode-p 'org-mode) #'org-fill-paragraph)

   ;; default to the usual fill-paragraph
   (t #'fill-paragraph)))


(defun smd/fill/paragraph/per-mode (&optional justify)
  "Mode-aware fill-paragraph so I only have to bind one thing in
the fill prefix-map."
  (interactive)
  (funcall (_s//fill/paragraph/fn-for-mode) justify))


(defun smd/fill/region/single-line (&optional justify)
  "Grab start/end of current line and call `fill-region'. i.e.
\"'Fill Region' on just this line, please.\""
  (interactive)

  (let ((from (save-excursion (beginning-of-line) (point)))
        (to   (save-excursion (end-of-line)       (point))))
    (fill-region from to justify)))


;;------------------------------------------------------------------------------
;; Manual Unicode Box Drawing Hydra
;;------------------------------------------------------------------------------

;; Wanted this to be `_s//hydra/art.box' but then hydra fucks up the names...
;; Turns the body into `_s//hydra/art\\\.box/body'.
;; Also I forgot how many functions hydra spews out. Fucks up my namespace.
;;
;; Also also: Pink hydra gets fucked up sometimes. Evil thinks it's in charge
;; and the hydra thinks its still running and they hate each other... Especially
;; if you had the misfortune to only have 'ESC' as your exit.
(defhydra _//hydra/art-box (:color amaranth ;; default to warn if non-hydra key
                            ;;:color pink   ;; defaults to not exit unless explicit
                            ;;:idle 0.75    ;; no help for x seconds
                            :hint none)     ;; no hint - just docstr)
  "
Draw box characters. Left-hand \"Grid\" layout according to Dvorak keyborad.
_'_: ?'?  _,_: ?,?  _._: ?.?     _g_: ?g?
_a_: ?a?  _o_: ?o?  _e_: ?e?     _G_: ?G?
_;_: ?;?  _q_: ?q?  _j_: ?j?

_p_: ?p?  _u_: ?u?
"
  ("'" (funcall #'insert "┌") "┌")
  ("," (funcall #'insert "┬") "┬")
  ("." (funcall #'insert "┐") "┐")
  ("a" (funcall #'insert "├") "├")
  ("o" (funcall #'insert "┼") "┼")
  ("e" (funcall #'insert "┤") "┤")
  (";" (funcall #'insert "└") "└")
  ("q" (funcall #'insert "┴") "┴")
  ("j" (funcall #'insert "┘") "┘")
  ("p" (funcall #'insert "─") "─")
  ("u" (funcall #'insert "│") "│")

  ("G"   nil                 "quit (to insert state)" :color blue)
  ("g"   (evil-normal-state) "quit (to normal state)" :color blue)
  ("C-g" (evil-normal-state) "quit (to normal state)" :color blue))
;; §-TODO-§ [2019-10-21]: instead of just insert, try to insert or overwrite,
;; and then move in the proper direction? Or does pink hydra make moving around
;; acceptable? Still could do overwrite instead of insert when applicable.


(defun smd/art.box/draw ()
  "`spy' namespaced function to get into the box drawing hydra.
"
  (interactive)
  (evil-insert 0)
  (call-interactively #'_//hydra/art-box/body))
;; ┌────┐
;; ├────┤
;; │ hi │
;; └────┘


;;------------------------------------------------------------------------------
;; Evil Spy Stuff.
;;------------------------------------------------------------------------------
;; See Doom's keybindings for how to do complicated things:
;; https://github.com/hlissner/doom-emacs/blob/develop/modules/config/default/+evil-bindings.el
(map! :leader       ; Be under the SPC leader.
      :desc   "spy"

      ;;------------------------------
      ;; Start of 'spy' prefix "-"
      ;;------------------------------
      (:prefix ("-" . "spy") ; Not my first choice but no one uses dash,
                                        ; and it's easy on Dvorak.

       ;;------------------------------
       ;; Alignment
       ;;------------------------------
       (:prefix ("a" . "Alignment")

        :desc "spy:   Align Before"    "a" #'smd/align-before
        :desc "spy:   Align After"     "o" #'smd/align-after
        :desc "emacs: Align Regex"     ";" #'align-regexp
        :desc "emacs: C-u Align Regex" "q" (lambda () (interactive)
                                             (setq current-prefix-arg '(4))
                                             (call-interactively #'align-regexp))
        :desc "emacs: Align"           "'" #'align
        :desc "emacs: Align Current"   "," #'align-current)


       ;;------------------------------
       ;; Fill
       ;;------------------------------
       (:prefix ("f" . "Fill")
        ;; Regions
        :desc "Region"              "r" #'fill-region
        :desc "Region as Paragraph" "a" #'fill-region-as-paragraph
        :desc "Line"                "l" #'smd/fill/region/single-line

        ;; Paragraphs
        :desc (if (eq (_s//fill/paragraph/fn-for-mode) #'fill-paragraph)
                  "Default Fill ¶"
                "Mode-Aware Fill ¶")
        "p" #'smd/fill/paragraph/per-mode
        :desc "Individual ¶"  "i" #'fill-individual-paragraphs
        :desc "Non-Uniform ¶" "n" #'fill-nonuniform-paragraphs
        :desc "Default ¶"     "d" #'fill-paragraph

        ;; Unfill
        :desc "Unfill ¶"      "u" #'smd/fill/paragraph/unfill)


       ;;------------------------------
       ;; Join
       ;;------------------------------
       (:prefix ("j" . "Join")
        ;; Lines (Emacs)
        :desc "↑ Line (Trim)"                  "c" #'join-line
        :desc "↓ Line (Trim)"                  "t" (lambda () (interactive) (join-line 1))

        ;; Lines (Evil)
        :desc "↑ Line (Smart Comments): (J)"  "," #'evil-join
        :desc "↑ Line (As-Is): (g J)"         "<" #'evil-join-whitespace)

       ;;------------------------------
       ;; Transpose
       ;;------------------------------
       (:prefix ("t" . "Transpose")
        ;; Emacs
        :desc "Characters"                  "c" #'transpose-chars
        :desc "Words"                       "w" #'transpose-words
        :desc "Lines"                       "l" #'transpose-lines
        :desc "Sentences"                   "s" #'transpose-sentences
        :desc "Paragraphs"                  "p" #'transpose-paragraphs
        :desc "S-Expressions"               "x" #'transpose-sexps

        ;; Org-Mode
        :desc "Org-Mode Words"              "o" #'org-transpose-words
        :desc "Org-Mode Elements"           "e" #'org-transpose-element
        :desc "Org-Mode Table"              "t" #'org-table-transpose-table-at-point)

       ;;------------------------------
       ;; Box Drawning
       ;;------------------------------
       ;; Using a blue hydra so it stays in the transient map.
       :desc "Unicode Box"                  "b" #'smd/art.box/draw

       ;;------------------------------
       ;; Signatures
       ;;------------------------------
       (:prefix ("s" . "Signatures")
        ;; Insert Signatures:

        ;; TODO namespace, timestamp, comment:
        :desc (concat "TODO: " (spy/signature 'sigil 'todo))
        "t"   (cmd! (spy/signature/insert 'sigil 'todo :timestamp t :comment t))

        ;; Sigil for Note Prefix.
        :desc (concat "Note: " (spy/signature 'sigil 'note))
        "n" (cmd! (spy/signature/insert 'sigil 'note))


        ;; Signature for the end of an email or something.
        :desc (concat "Sign: " (spy/signature 'name 'sign))
        "s" (cmd! (spy/signature/insert 'name 'sign))

        ;; IDs
        (:prefix ("i" . "ID")
         ;; Just the Sigil.
         :desc (concat "Sigil: " (spy/signature 'id 'sigil))
         "s" (cmd! (spy/signature/insert 'id 'sigil))

         ;; Just the Name.
         :desc (concat "Name: " (spy/signature 'id 'name))
         "n" (cmd! (spy/signature/insert 'id 'name)))

        ;; Emails
        ;;   - Only show if we have any.
        (:when (spy/signature/exists 'id 'email)
         (:prefix ("e" . "Emails")
          ;; work namespace.
          (:when (spy/signature/exists 'id 'email :namespace :work)
           :desc (concat "work: " (spy/signature 'id 'email :namespace :work))
           "w" (cmd! (spy/signature/insert 'id 'sigil :namespace :work)))

          ;; home namespace.
          (:when (spy/signature/exists 'id 'email :namespace :home)
           :desc (concat "home: " (spy/signature 'id 'email :namespace :home))
           "h" (cmd! (spy/signature/insert 'id 'sigil :namespace :home)))

          ;; default namespace.
          (:when (spy/signature/exists 'id 'email :namespace :default)
           :desc (concat "default: " (spy/signature 'id 'email :namespace :default))
           "c" (cmd! (spy/signature/insert 'id 'sigil :namespace :default)))


          ;; TODO: Search for sigil, todo...

          ;; /Emails
          ))

        ;; /Signatures
        )

       ;;------------------------------
       ;; Org-Journal
       ;;------------------------------
       ;; They are in org-journal's entry in leader. See config/org-mode.el

       ))
