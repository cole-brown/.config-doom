;;; config/theme/zenburn.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;;                               Zenburn Tweaks
;;------------------------------------------------------------------------------

(when (eq doom-theme 'doom-zenburn)

  ;;----------------------------------------------------------------------------
  ;; Org-Mode
  ;;----------------------------------------------------------------------------
  ;; (face-spec-set 'facename
  ;; Attributes plist:
  (let ((face-plist
         (list :foreground (doom-darken (doom-color 'magenta) 0.1)
               :background (doom-color 'bg-alt)
               :weight 'bold
               ;; :underline t
               )))

    (face-spec-set 'spy/theme.face/org.todo.keyword/todo
      (list (cons
             ;; display type
             t
             ;; attributes
             face-plist)))

    (face-spec-set 'spy/theme.face/org.todo.keyword/background
      (list (cons
             ;; display type
             t
             ;; attributes
             (list :background (doom-color 'bg-alt)))))

    (face-spec-set 'spy/theme.face/org.todo.keyword/done.good
      (list (cons
             ;; display type
             t
             ;; attributes
             (list :background (doom-color 'bg-alt)
                   :inherit 'org-done))))

    (face-spec-set 'spy/theme.face/org.todo.keyword/done.bad
      (list (cons
             ;; display type
             t
             ;; attributes
             (list :background (doom-color 'bg-alt)
                   :foreground (doom-darken (doom-color 'red-4) 0.1))))))

  (custom-theme-set-faces! 'doom-zenburn
    ;;---
    ;; Done states - little less dark.
    ;;---
    `(org-done :foreground ,(doom-darken (doom-color 'green-2) 0.15))
    `(org-agenda-done :foreground ,(doom-color 'base7))
    `(org-headline-done :foreground ,(doom-color 'base7))
    `(org-checkbox-statistics-done :foreground ,(doom-darken (doom-color 'green-2) 0.15))

    ;;---
    ;; Org Headlines - adjust a few to be less dark.
    ;;---
    ;; Some unique, headliney colors.
    `(outline-1 :foreground ,(doom-color 'orange))
    `(outline-2 :foreground ,(doom-color 'green+2))
    `(outline-3 :foreground ,(doom-color 'blue-1))
    `(outline-4 :foreground ,(doom-color 'red-1))
    ;; ...and repeat.
    `(outline-5 :foreground ,(doom-color 'orange))
    `(outline-6 :foreground ,(doom-color 'green+2))
    `(outline-7 :foreground ,(doom-color 'blue-1))
    `(outline-8 :foreground ,(doom-color 'red-1))
    ;; ...and 9+ starts over at `outline-1'.

    ;;---
    ;; Org TODO States
    ;;---
    ;; ├CURRENT┤
    `(+org-todo-active :foreground ,(doom-color 'violet)
                       :background ,(doom-color 'bg-alt))
    ;; ├WAITING┤, ├HOLDING┤
    `(+org-todo-onhold :foreground ,(doom-darken (doom-color 'magenta) 0.3)
                       :background ,(doom-color 'bg-alt))
    ;; ├PROJECT┤
    `(+org-todo-project :foreground ,(doom-color 'blue-3)
                        :background ,(doom-color 'bg-alt))


    ;;---
    ;; "#+DOC_KEYWORD" - needs to be slightly lighter.
    ;;---
    `(org-document-info-keyword :foreground ,(doom-color 'base7))
    )
  ;; +org-todo-active  - bold green
  ;; +org-todo-onhold  - orangey
  ;; +org-todo-project - darker green than bold green
  ;; org-checkbox
  ;; org-checkbox-statistics-todo
  ;; org-headline-todo
  ;; org-todo


  ;;----------------------------------------------------------------------------
  ;; Whitespace Mode
  ;;----------------------------------------------------------------------------
  ;; Normal Zenburn:
  ;;   - whitespace-mode is garish.
  ;;   - Like. Ow. My eyeballs...
  ;; Doom Zenburn:
  ;;   - Normal whitespace chars are a bit dark against zenburn's background.
  ;;   - Too-long-lines highlight is _too_ distracting/eye-catching.
  ;; So... change them
  (custom-theme-set-faces! 'doom-zenburn
    ;;---
    ;; "Good" Whitespace
    ;;---
    `(whitespace-space :foreground ,(doom-color 'base6)) ;; zenburn-bg+2
    `(whitespace-newline :foreground ,(doom-color 'base6)) ;; zenburn-bg+2
    ;; whitespace-hspace - leave as-is?
    ;; whitespace-indentation - leave as-is?

    ;;---
    ;; "Ambivalent" Whitespace
    ;;---
    `(whitespace-tab :foreground ,(doom-color 'orange)) ;; zenburn-orange
    ;; whitespace-empty - what is this?
    ;; `(whitespace-empty :foreground ,(doom-color 'red))

    ;;---
    ;; "Bad" Whitespace
    ;;---
    `(whitespace-line :foreground ,(doom-color 'magenta)
                      :background ,(doom-color 'bg-alt)) ;; Soften the bg color.
    ;; whitespace-trailing - leave as-is?
    ;; whitespace-big-indent - Don't know if I've ever seen this... leave as-is for now.
    `(whitespace-space-after-tab :foreground ,(doom-color 'bg-alt)
                                 :background ,(doom-color 'magenta)) ;; less eyebleed
    `(whitespace-space-before-tab :foreground ,(doom-color 'bg-alt)
                                  :background ,(doom-color 'violet)) ;; less eyebleed
    ))
