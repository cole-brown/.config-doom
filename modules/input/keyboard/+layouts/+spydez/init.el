;;; input/keyboard/layout/spydez/init.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                                 SpydeZ                                 ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                Dvorak Layout: Cuz I was bored in college...                ;;
;;             Non-standard Evil Layout: Cuz I'm weird that way.              ;;
;;                                 ──────────                                 ;;


;; Should be done with all the 'init' of ':input/keyboard'.
(imp:require :input 'keyboard 'init)


;;------------------------------------------------------------------------------
;; Common
;;------------------------------------------------------------------------------

;; None right now.


;;------------------------------------------------------------------------------
;; Evil
;;------------------------------------------------------------------------------
;; Set `:spydez' as the active layout, and also set our evil keybinds.
;; Does not configure the keybinds; just saves it for now.

;;------------------------------
;; Unbind Keys
;;------------------------------

;; TODO [2021-06-29]: Trying out new binds - revert if necessary.
;; (test<keyboard>:layout:unbind :eval :spydez :evil
(keyboard:layout:unbind :spydez :evil
  ;; Keybinds for the `:spydez' layout: a big list of inputs to
  ;; `keyboard:layout:map!'.
  '(;; ╔════════════════════════════════════════════════════════════════╗
    ;; ║ Keymap: nil/global                                             ║
    ;; ╚════════════════════════════════════════════════════════════════╝

    ;; ┌────────────────────────────────┐
    ;; │ Prefixes                       │
    ;; └────────────────────────────────┘
    ;; Doom or General or someone will complain if bound keys are not
    ;; unbound before being used for prefixes...

    ;; Unbind from `evil-substitute'.
    :n "s" :layout:common:undefined

    ;; ┌────────────────────────────────┐
    ;; │ Keys                           │
    ;; └────────────────────────────────┘

    ;; Unbind from `evil-repeat-pop'.
    :n "C-." :layout:common:undefined

    ;; Unbind from `better-jumper-jump-backward'.
    :n "C-o" :layout:common:undefined

    ;; Unbind from `evil-normal-state-map'.
    :n "A" :layout:common:undefined

    ;; Unbind from `evil-open-above'.
    :n "O" :layout:common:undefined

    ;; Unbind from `evil-insert-line'.
    :n "I" :layout:common:undefined

    ;; Unbind from `evil-emacs-state', which is confusing to get out of (need to call w/ negative prefix arg).
    :im "C-z" :layout:common:undefined
    ;; Unbind from `suspend-frame', which takes over "C-z" when `evil-emacs-state' gets unbound.
    "C-z" :layout:common:undefined

    ;; ╔════════════════════════════════════════════════════════════════╗
    ;; ║ Keymap: evil-snipe-mode-map / evil-snipe-local-mode-map        ║
    ;; ╚════════════════════════════════════════════════════════════════╝
    ;; Wait until after `evil-snipe' shows up or else these unbinds will get overwritten by the binds. Hooray lazy loading! :eyeroll:
    (:after evil-snipe
     :map (evil-snipe-mode-map evil-snipe-local-mode-map)

     ;; ┌────────────────────────────────┐
     ;; │ Prefixes                       │
     ;; └────────────────────────────────┘
     ;; Doom or General or someone will complain if bound keys are not
     ;; unbound before being used for prefixes...

     ;; Unbind 's' from snipe.
     :nvm "s" :layout:common:undefined)


    ;; ╔════════════════════════════════════════════════════════════════╗
    ;; ║ Keymap: evil-org-mode-map                                      ║
    ;; ╚════════════════════════════════════════════════════════════════╝
    ;; Wait until after `org' shows up or else these unbinds will get overwritten by the binds. Hooray lazy loading! :eyeroll:
    (:after org
     :after evil-org
     :map evil-org-mode-map

     ;; ┌────────────────────────────────┐
     ;; │ Keys                           │
     ;; └────────────────────────────────┘

     ;; Unbind from `evil-open-below'.
     :n "o" :layout:common:undefined)))


;;------------------------------
;; NEW: ESDF position keys (shifted-WASD left-hand, index on home key)
;;------------------------------
;; TODO [2021-06-29]: Trying out new binds - revert if necessary.
;; (test<keyboard>:layout:bind :bind :eval ; :pp-sexpr
;;                             :spydez :evil
(keyboard:layout:bind :spydez :evil
  ;; Keybinds for the `:spydez' layout: a big list of inputs to
  ;; `keyboard:layout:map!'.
  '(;; ╔════════════════════════════════════════════════════════════════╗
    ;; ║ Keymap: nil/global                                             ║
    ;; ╚════════════════════════════════════════════════════════════════╝

    ;; ┌────────────────────────────────┐
    ;; │ States                         │
    ;; └────────────────────────────────┘
    ;; IJKL position keys (WASD-style, right hand).
    (:prefix ("s" . "Evil States")
     :nv  "h"  :layout:evil:state-insert-before
     :nv  "n"  :layout:evil:state-insert-after
     :n   "t"  :layout:evil:state-insert-line-open-below
     :n   "c"  :layout:evil:state-insert-line-open-above

     :n  (:derive 'shift :layout:evil:state-insert-before) :layout:evil:state-insert-line-start
     :n  (:derive 'shift :layout:evil:state-insert-after)  :layout:evil:state-insert-line-end
     :n  (:derive 'shift :layout:evil:state-insert-line-open-below)  :layout:evil:state-replace

     ;; TODO: Leave as Dvorak 'v'?
     :m  "v"  :layout:evil:state-visual-char-wise
     :m  "V"  :layout:evil:state-visual-line-wise)


    ;; ┌────────────────────────────────┐
    ;; │ Movement                       │
    ;; └────────────────────────────────┘

    ;; ──┬────────────────
    ;;   │ ↑ ↓ ← →
    ;; ──┴────────────────
    ;; ESDF position keys (WASD shifted rightward one for index on home key).
    :nvm  "."  :layout:evil:line-prev
    :nvm  "e"  :layout:evil:line-next
    :nvm  "o"  :layout:evil:char-prev
    :nvm  "u"  :layout:evil:char-next

    ;; ──┬────────────────
    ;;   │ Word
    ;; ──┴────────────────
    ;; ESDF-based. To go 'farther away', move finger away (e.g. word-next-begin is "U", word-next-end is "I".)
    ;; "Small" words: Shift
    ;; "Big"   words: Meta
    ;; TODO: swap modifier if using "Big" more than "Small".
    ;; TODO: TODO: Use derive? But nothing to derive "A"/"I" from.
    :m  "A"                                       :layout:evil:word-prev-begin
    :m  (:derive 'shift :layout:evil:char-prev)   :layout:evil:word-prev-end
    :m  (:derive 'shift :layout:evil:char-next)   :layout:evil:word-next-begin
    :m  "I"                                       :layout:evil:word-next-end
    ;; AKA :layout:evil:word-*-* with optional arg BIGWORD set to 't'
    :m  (:derive 'meta 'unshift :layout:evil:word-prev-begin)  :layout:evil:word-prev-begin-bigword
    :m  (:derive 'meta 'unshift :layout:evil:word-prev-end)    :layout:evil:word-prev-end-bigword
    :m  (:derive 'meta 'unshift :layout:evil:word-next-begin)  :layout:evil:word-next-begin-bigword
    :m  (:derive 'meta 'unshift :layout:evil:word-next-end)    :layout:evil:word-next-end-bigword

    ;; ──┬────────────────
    ;;   │ Sentences
    ;; ──┴────────────────
    ;; TODO: Leave as-is or move near movement keys?
    :m  "("  :layout:evil:sentence-begin-prev
    :m  ")"  :layout:evil:sentence-begin-next

    ;; ──┬────────────────
    ;;   │ Paragraphs
    ;; ──┴────────────────
    ;; TODO: Leave as-is or move near movement keys?
    :m  "{"  :layout:evil:paragraph-prev
    :m  "}"  :layout:evil:paragraph-next


    ;; ;; ──┬────────────────
    ;; ;;   │ Scroll
    ;; ;; ──┴────────────────
    ;; ;; Recentering.
    ;; (:prefix (";" . "Movement...")  ;; prefix for even more movement commands
    ;;  :m (:derive :layout:evil:line-prev)                :layout:evil:scroll-line-to-top
    ;;  :m (:derive 'prefix)                               :layout:evil:scroll-line-to-center
    ;;  :m (:derive :layout:evil:line-next)                :layout:evil:scroll-line-to-bottom
    ;;  :m (:derive 'shift :layout:evil:line-prev)         :layout:evil:scroll-top-line-to-bottom
    ;;  :m (:derive 'shift :layout:evil:line-next)         :layout:evil:scroll-bottom-line-to-top)

    ;; ;; Half page scrolling.
    :m (:derive 'control :layout:evil:line-prev)        :layout:evil:scroll-up
    :m (:derive 'control :layout:evil:line-next)        :layout:evil:scroll-down
    ;; TODO: These are beginning/end of line. Any (other) place for scroll-left/right?
    ;; :m (:derive 'control :layout:evil:char-prev)        :layout:evil:scroll-left
    ;; :m (:derive 'control :layout:evil:char-next)        :layout:evil:scroll-right

    ;; Full page scrolling.
    :m (:derive 'control 'meta :layout:evil:line-prev)   :layout:evil:scroll-page-up
    :m (:derive 'control 'meta :layout:evil:line-next)   :layout:evil:scroll-page-down

    ;; ;; Line/column scrolling.
    ;; :m (:derive 'control 'shift :layout:evil:line-prev) :layout:evil:scroll-line-up
    ;; :m (:derive 'control 'shift :layout:evil:line-next) :layout:evil:scroll-line-down
    ;; :m (:derive 'control 'shift :layout:evil:char-prev) :layout:evil:scroll-column-left
    ;; :m (:derive 'control 'shift :layout:evil:char-next) :layout:evil:scroll-column-right
    ;; ;; Unused:
    ;; ;; :? "" :layout:evil:scroll-count-reset

    ;; ;; ──┬────────────────
    ;; ;;   │ Lines
    ;; ;; ──┴────────────────
    ;; ;; ',py
    ;; ;; qjk
    ;; :m  "TAB"  :layout:evil:item-jump ;; Was %, and also in some modes tab in some way that doesn't show under help's keybinds for tab...
    ;; :m  "0"    :layout:evil:digit-arg-0/line-start
    :m (:derive 'control :layout:evil:char-prev) :layout:evil:line-begin
    :m (:derive 'control :layout:evil:char-next) :layout:evil:line-end
    ;; :m  "-"    :layout:evil:line-prev-first-non-blank
    ;; :m  "^"    :layout:evil:line-current-first-non-blank
    ;; :m  "_"    :layout:evil:line-next-1-first-non-blank
    ;; :m  "+"    :layout:evil:line-next-first-non-blank

    ;; :m  "G"  :layout:evil:goto-line ;; default:layout:evil: last line in buffer
    ;; :m  "H"  :layout:evil:goto-line-visible-first
    ;; :m  "M"  :layout:evil:goto-line-visible-middle
    ;; :m  "L"  :layout:evil:goto-line-visible-last


    ;; ╔═══════════════════╗
    ;; ╠═ END: global map ═╣
    ;; ╚═══════════════════╝


    ;; ╔════════════════════════════════════════════════════════════════╗
    ;; ║ Keymap: evil-org-mode-map                                      ║
    ;; ╚════════════════════════════════════════════════════════════════╝
    ;; Wait until after `org' shows up or else these binds will get overwritten by org-mode. Hooray lazy loading! :eyeroll:
    (:after org
     :after evil-org
     :map evil-org-mode-map

     ;; ┌────────────────────────────────┐
     ;; │ Special Org Versions           │
     ;; └────────────────────────────────┘
     (:prefix ("s" . "Evil States")
      :n   "t"  #'evil-org-open-below)) ;; Replace `evil-open-below' with `evil-org-open-below'.

    ;; ╔══════════════════════════╗
    ;; ╠═ END: evil-org-mode-map ═╣
    ;; ╚══════════════════════════╝
    ))
;; (pp-macroexpand-expression (int<keyboard>:registrar:get :actual :keybinds))


;;------------------------------------------------------------------------------
;; Evil: Magit
;;------------------------------------------------------------------------------

;; Don't run this at all for now.
(when nil
  ;; Can't bind our magit keys until after evil-collection loads its stuff for them.
  (after! '(evil-collection magit)
    ;; Try to set states via `evil-collection' vars, fallback to a default.
    (let ((states
           (int<keyboard>:states->keyword
            ;; When does evil-collection overwrite all the magit keys?
            ;;   - Does it overwrite them? Or does Doom do it differently somewhere else?
            (condition-case-unless-debug signal-raised
                ;; Get list of states from 'evil-collection'?
                (if evil-collection-magit-use-y-for-yank
                    (list evil-collection-magit-state 'visual)
                  (list evil-collection-magit-state))
              ;; Failed - that file wasn't loaded I guess?
              ;; Use a default.
              (void-variable
               (int<keyboard>:debug "+spydez/init.el:magit"
                                    nil ;; No tags?
                                    "`void-variable' signal caught when trying to create magit keybinds. %S"
                                    signal-raised)

               ;; No `evil-collection-magit-use-y-for-yank' Fallback:
               ;;   - Looks like the default for `evil-collection-magit-state' is `normal'.
               '(normal))))))

      ;;------------------------------
      ;; Magit: Unbind Keys
      ;;------------------------------
      ;; (keyboard:layout:bind :spydez :evil
      (test<keyboard>:layout:bind :pp-sexpr ; :eval
          :spydez :evil
        ;; Keybinds for the `:spydez' layout: a big list of inputs to
        ;; `keyboard:layout:map!'.
        ;; Wait until after `magit' shows up or else these binds will get overwritten. Hooray lazy loading! :eyeroll:
        `(:after magit

          ;; ╔════════════════════════════════════════════════════════════════╗
          ;; ║ Keymap: magit-mode-map                                         ║
          ;; ╚════════════════════════════════════════════════════════════════╝
          (:map magit-mode-map

           ;; ┌────────────────────────────────┐
           ;; │ Keys                           │
           ;; └────────────────────────────────┘

           ;; Because only y can be for yank.
           ;; ...unless you have a different keyboard layout and are remapping literally everything.
           (:when evil-collection-magit-use-y-for-yank
            ,states "y" :layout:common:undefined))

          ;; ╔═══════════════════════╗
          ;; ╠═ END: magit-mode-map ═╣
          ;; ╚═══════════════════════╝


          ;; ;; ╔════════════════════════════════════════════════════════════════╗
          ;; ;; ║ Keymap: magit-popup-mode-map                                   ║
          ;; ;; ╚════════════════════════════════════════════════════════════════╝
          ;; (:map magit-popup-mode-map
          ;;
          ;;  ;; ┌────────────────────────────────┐
          ;;  ;; │ Magit Misc. Commands           │
          ;;  ;; └────────────────────────────────┘
          ;;  (:prefix ("g" . "Magit...")  ;; Prefix for a bunch of Magit commands.
          ;;   ;; No change from 'evil-collection'.
          ;;   ;; :e "<ecape>" :layout:common:undefined
          ;;   ))
          ;;
          ;; ;; ╔═════════════════════════════╗
          ;; ;; ╠═ END: magit-popup-mode-map ═╣
          ;; ;; ╚═════════════════════════════╝
          ))


      ;;------------------------------
      ;; Magit: Bind Keys
      ;;------------------------------
      ;; (keyboard:layout:bind :spydez :evil
      (test<keyboard>:layout:bind :pp-sexpr ; :eval
          :spydez :evil
        ;; Keybinds for the `:spydez' layout: a big list of inputs to
        ;; `keyboard:layout:map!'.
        ;; Wait until after `magit' shows up or else these binds will get overwritten. Hooray lazy loading! :eyeroll:
        `(:after magit

          ;; ╔════════════════════════════════════════════════════════════════╗
          ;; ║ Keymap: magit-mode-map                                         ║
          ;; ╚════════════════════════════════════════════════════════════════╝
          (:map magit-mode-map

           ;; ┌────────────────────────────────┐
           ;; │ Magit Misc. Commands           │
           ;; └────────────────────────────────┘
           (:prefix ("g" . "Magit...")  ;; Prefix for a bunch of Magit commands.
            ,states (:derive :layout:evil:line-next) #'magit-section-forward-sibling
            ,states (:derive :layout:evil:line-prev) #'magit-section-backward-sibling
            ;; No change from 'evil-collection'.
            ;; ,states "r"                               #'magit-refresh
            ;; ,states "R"                               #'magit-refresh-all
            ;; ,states "g"                               :layout:evil:goto-line-first
            )

           ;; ┌────────────────────────────────┐
           ;; │ Movement                       │
           ;; └────────────────────────────────┘
           ;; By line:
           ,states (:derive :layout:evil:line-next) :layout:evil:line-next
           ,states (:derive :layout:evil:line-prev) :layout:evil:line-prev
           ;; No change from 'evil-collection'.
           ;; ,states "G"                               :layout:evil:goto-line

           ;; By number of lines:
           ,states (:derive :layout:evil:scroll-up)   :layout:evil:scroll-up
           ,states (:derive :layout:evil:scroll-down) :layout:evil:scroll-down

           ;; By sections:
           ,states (:derive :layout:evil:scroll-page-up)   #'magit-section-forward
           ,states (:derive :layout:evil:scroll-page-down) #'magit-section-backward
           ;; No change from 'evil-collection'.
           ;; ,states "["                                 #'magit-section-forward-sibling
           ;; ,states "]"                                 #'magit-section-backward-sibling

           ;; ┌────────────────────────────────┐
           ;; │ Actions                        │
           ;; └────────────────────────────────┘
           ;; No change from 'evil-collection'.
           ;; ,states "x"                                        #'magit-delete-thing
           ;; ,states (:derive 'shift #'magit-delete-thing)     #'magit-file-untrack
           ;; ,states "-"                                        #'magit-revert-no-commit
           ;; TODO: make `(:derive 'shift ...)' work for non-alpha characters.
           ;; ,states (:derive 'shift #'magit-revert-no-commit) #'magit-revert
           ;; ,states "p"                                        #'magit-push
           ;; ,states "o"                                        #'magit-reset-quickly
           ;; ,states (:derive 'shift #'magit-reset-quickly)    #'magit-reset

           ;; ┌────────────────────────────────┐
           ;; │ Git                            │
           ;; └────────────────────────────────┘
           ;; No change from 'evil-collection'.
           ;; ,states "|" #'magit-git-command

           ;; ┌────────────────────────────────┐
           ;; │ Sub-Repositories               │
           ;; └────────────────────────────────┘
           ;; No change from 'evil-collection'.
           ;; ,states "'"                                #'magit-submodule
           ;; ,states (:derive 'shift #'magit-submodule) #'magit-subtree

           ;; ┌────────────────────────────────┐
           ;; │ Diff                           │
           ;; └────────────────────────────────┘
           ;; No change from 'evil-collection'.
           ;; ,states "=" #'magit-diff-less-context

           ;; TODO: Does their bug apply to ':input/keyboard'?
           ;; https://github.com/emacs-evil/evil-collection/issues/406
           ;; Use kbd here for S-SPC and S-DEL so evil-collection-define-key can
           ;; parse definition correctly.
           ;;
           ;; No change from 'evil-collection'.
           ;; ,states (kbd "S-SPC") #'magit-diff-show-or-scroll-up
           ;; ,states (kbd "S-DEL") #'magit-diff-show-or-scroll-down

           ;; ┌────────────────────────────────┐
           ;; │ Magit                          │
           ;; └────────────────────────────────┘
           ;; No change from 'evil-collection'.
           ;; ,states "q" #'magit-mode-bury-buffer

           ;; ┌────────────────────────────────┐
           ;; │ Magit Forge                    │
           ;; └────────────────────────────────┘
           ;; No change from 'evil-collection'.
           ;; ,states "@" #'forge-dispatch

           ;; ┌────────────────────────────────┐
           ;; │ Evil                           │
           ;; └────────────────────────────────┘
           ;; No change from 'evil-collection'.
           ;; ,states ":" :layout:evil:evil-command


           ;; TODO: `evil-toggle-key' not defined?
           ;; :n evil-toggle-key #'evil-emacs-state
           ;; TODO: Escape is cancel. Why would 'evil-collection' make it a different keybind? Can you even do that?
           ;; :n "<escape>" #'magit-mode-bury-buffer

           ;; TODO: `evil-search-module' not defined?
           ;; TODO: No ':if' in `map!'. Would have to implement or use both `:when' and `:unless'.
           ;; (:when (eq evil-search-module 'evil-search)
           ;;       ,states "/" #'evil-ex-search-forward
           ;;       ,states "n" #'evil-ex-search-next
           ;;       ,states (:derive 'shift #'evil-ex-search-next) #'evil-ex-search-previous)
           ;; (:unless (eq evil-search-module 'evil-search)
           ;;   ,states "/" #'evil-search-forward
           ;;   ,states "n" #'evil-search-next
           ;;   ,states (:derive #'evil-ex-search-next) #'evil-search-previous)

           ;; TODO: Don't have these vars, so I can't really check for these things.
           ;;   - What does Doom do?
           ;; (:when evil-collection-magit-want-horizontal-movement
           ;;       ,states "H"   #'magit-dispatch
           ;;       ,states "L"   #'magit-log
           ;;       ,states "C-l" #'magit-log-refresh
           ;;       ,states "h"   #'evil-backward-char
           ;;       ,states "l"   #'evil-forward-char)

           ;; TODO: Ignore this var?
           ;; (:when evil-want-C-u-scroll
           ;;   ,states "C-u" evil-scroll-up))

           ;; TODO: Var isn't defined.
           ;; TODO: No ':if' in `map!'. Would have to implement or use both `:when' and `:unless'.
           ;; (:when evil-collection-magit-use-y-for-yank
           ;;       ,states "v"    #'evil-visual-line
           ;;       ,states "V"    #'evil-visual-line
           ;;       ,states "\C-w"  #'evil-window-map
           ;;       ;; TODO: "y" prefix
           ;;       ;; ,states "y"
           ;;       ;; ,states "yy"   #'evil-collection-magit-yank-whole-line
           ;;       ;; ,states "yr"   #'magit-show-refs
           ;;       ;; ,states "ys"   #'magit-copy-section-value
           ;;       ;; ,states "yb"   #'magit-copy-buffer-revision
           ;;       ;; :v     "y"    #'magit-copy-section-value
           ;;       )
           ;; (:unless evil-collection-magit-use-y-for-yank
           ;;       ,states magit-mode-map "v" #'set-mark-command
           ;;       ;; TODO: Why both "v" and "V"?
           ;;       ,states magit-mode-map (:derive 'shift #'set-mark-command) #'set-mark-command
           ;;       ;; TODO: Escape is cancel. Why would 'evil-collection' make it a different keybind? Can you even do that?
           ;;       ,states magit-mode-map "<escape>" #'evil-collection-magit-maybe-deactivate-mark)

           ;; (when evil-collection-magit-use-z-for-folds
           ;;   ;; TODO: "z" prefix
           ;;   ;; ,states "z1" #'magit-section-show-level-1-all
           ;;   ;; ,states "z2" #'magit-section-show-level-2-all
           ;;   ;; ,states "z3" #'magit-section-show-level-3-all
           ;;   ;; ,states "z4" #'magit-section-show-level-4-all
           ;;   ;; ,states "za" #'magit-section-toggle
           ;;   ;; ,states "zc" #'magit-section-hide
           ;;   ;; ,states "zC" #'magit-section-hide-children
           ;;   ;; ,states "zo" #'magit-section-show
           ;;   ;; ,states "zO" #'magit-section-show-children
           ;;   ;; ,states "zr" #'magit-section-show-level-4-all
           )

          ;; ╔═══════════════════════╗
          ;; ╠═ END: magit-mode-map ═╣
          ;; ╚═══════════════════════╝


          ;; ╔════════════════════════════════════════════════════════════════╗
          ;; ║ Keymap: magit-log-mode-map                                     ║
          ;; ╚════════════════════════════════════════════════════════════════╝
          (:map magit-log-mode-map

           ;; ┌────────────────────────────────┐
           ;; │ Commits                        │
           ;; └────────────────────────────────┘
           ;; These are to fix the priority of the log mode map and the magit mode map.
           ;; FIXME: Conflict between this and revert. Revert seems more important here.
           ;; (,states magit-log-mode-map "-" magit-log-half-commit-limit    "-")
           ;;
           ;; No change from 'evil-collection'.
           ,states "=" #'magit-log-toggle-commit-limit
           )

          ;; ╔═══════════════════════════╗
          ;; ╠═ END: magit-log-mode-map ═╣
          ;; ╚═══════════════════════════╝


          ;; ;; ╔════════════════════════════════════════════════════════════════╗
          ;; ;; ║ Keymap: magit-status-mode-map                                  ║
          ;; ;; ╚════════════════════════════════════════════════════════════════╝
          ;; (:map magit-status-mode-map
          ;;
          ;;       ;; ┌────────────────────────────────┐
          ;;       ;; │ Magit Misc. Commands           │
          ;;       ;; └────────────────────────────────┘
          ;;       (:prefix ("g" . "Magit...")  ;; Prefix for a bunch of Magit commands.
          ;;             ;; No change from 'evil-collection'.
          ;;             ,states "z"  #'magit-jump-to-stashes
          ;;             ,states "t"  #'magit-jump-to-tracked
          ;;             ,states "n"  #'magit-jump-to-untracked
          ;;             ,states "u"  #'magit-jump-to-unstaged
          ;;             ,states "s"  #'magit-jump-to-staged
          ;;             ,states "fu" #'magit-jump-to-unpulled-from-upstream
          ;;             ,states "fp" #'magit-jump-to-unpulled-from-pushremote
          ;;             ,states "pu" #'magit-jump-to-unpushed-to-upstream
          ;;             ,states "pp" #'magit-jump-to-unpushed-to-pushremote
          ;;             ,states "h"  #'magit-section-up
          ;;             )
          ;;       )
          ;;
          ;; ;; ╔══════════════════════════════╗
          ;; ;; ╠═ END: magit-status-mode-map ═╣
          ;; ;; ╚══════════════════════════════╝


          ;; ;; ╔══════════════════════════════════════════════════════════════╗
          ;; ;; ║ Keymap: magit-diff-mode-map                                  ║
          ;; ;; ╚══════════════════════════════════════════════════════════════╝
          ;; (:map magit-diff-mode-map
          ;;
          ;;       ;; ┌────────────────────────────────┐
          ;;       ;; │ Magit Misc. Commands           │
          ;;       ;; └────────────────────────────────┘
          ;;       (:prefix ("g" . "Magit...")  ;; Prefix for a bunch of Magit commands.
          ;;             ;; No change from 'evil-collection'.
          ;;             :v "y"  #'magit-copy-section-value
          ;;             )
          ;;       )
          ;;
          ;; ;; ╔════════════════════════════╗
          ;; ;; ╠═ END: magit-diff-mode-map ═╣
          ;; ;; ╚════════════════════════════╝

          ;; <<done>>
          )
        ;; ╔═══════════════════════════╗
        ;; ╠═ END: magit-log-mode-map ═╣
        ;; ╚═══════════════════════════╝

        ) ;; /`test<keyboard>:layout:bind', or possibly `keyboard:layout:bind'
      ;; <EVAL-THIS kbd="C-x C-e">
      ) ;; /set `states' from `evil-collection'.
    ;; </EVAL-THIS>
    ) ;; /`after!' evil-collection and magit
  ) ;; /when nil



;;------------------------------------------------------------------------------
;; TODO: MORE KEYBINDS!!!
;;------------------------------------------------------------------------------

;; TODO: These and more


;; ;; ──┬────────────────
;; ;;   │ Searches
;; ;; ──┴────────────────
;; ;; evil: motion
;; :m  "n"  :layout:evil:search-next
;; :m  "N"  :layout:evil:search-prev
;; :m  "/"  :layout:evil:search-forward
;; :m  "?"  :layout:evil:search-backward

;; :m  "#"  :layout:evil:search-word-backward
;; :m  "*"  :layout:evil:search-word-forward

;; :m  "t"  :layout:evil:snipe-next-1-t ;; TODO: not a keyboard-dependent keyword?
;; :m  "f"  :layout:evil:snipe-next-1-f ;; TODO: not a keyboard-dependent keyword?
;; :m  "T"  :layout:evil:snipe-prev-1-T ;; TODO: not a keyboard-dependent keyword?
;; :m  "F"  :layout:evil:snipe-prev-1-F ;; TODO: not a keyboard-dependent keyword?
;; :m  "s"  :layout:evil:snipe-next-2-s ;; TODO: not a keyboard-dependent keyword?
;; :m  "S"  :layout:evil:snipe-prev-2-S ;; TODO: not a keyboard-dependent keyword?
;; :m  ";"  :layout:evil:snipe-repeat
;; :m  ","  :layout:evil:snipe-repeat-inverse

;; ;; ──┬────────────────
;; ;;   │ Marks
;; ;; ──┴────────────────
;; :n  "m"  :layout:evil:mark-set
;; :m  "`"  :layout:evil:mark-goto


;; ┌────────────────────────────────┐
;; │ Next Thing                     │
;; └────────────────────────────────┘

;; TODO: Many more keybinds for global?
;; TODO: Many more keymaps


;;------------------------------------------------------------------------------
;; Emacs
;;------------------------------------------------------------------------------

;; None right now.


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard '+layouts '+spydez 'init)
