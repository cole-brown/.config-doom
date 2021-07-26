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

    (face-spec-set 'spy:theme.face/org.todo.keyword/todo
                   (list (cons
                          ;; display type
                          t
                          ;; attributes
                          face-plist)))

    (face-spec-set 'spy:theme.face/org.todo.keyword/background
                   (list (cons
                          ;; display type
                          t
                          ;; attributes
                          (list :background (doom-color 'bg-alt)))))

    (face-spec-set 'spy:theme.face/org.todo.keyword/done.good
                   (list (cons
                          ;; display type
                          t
                          ;; attributes
                          (list :background (doom-color 'bg-alt)
                                :inherit 'org-done))))

    (face-spec-set 'spy:theme.face/org.todo.keyword/done.bad
                   (list (cons
                          ;; display type
                          t
                          ;; attributes
                          (list :background (doom-color 'bg-alt)
                                :foreground (doom-darken (doom-color 'red-4) 0.1)))))

    (face-spec-set 'spy:theme.face/org.todo.keyword/info
                   (list (cons
                          ;; display type
                          t
                          ;; attributes
                          (list :background (doom-color 'bg-alt)
                                :foreground (doom-color 'base7)))))

    (face-spec-set 'spy:theme.face/org.todo.keyword/null
                   (list (cons
                          ;; display type
                          t
                          ;; attributes
                          (list :background (doom-color 'bg-alt)
                                :foreground (doom-color 'base7))))))


  (custom-theme-set-faces! 'doom-zenburn
    ;;---
    ;; Done states - little less dark.
    ;;---
    (list 'org-done :foreground (doom-darken (doom-color 'green-2) 0.15))
    (list 'org-agenda-done :foreground (doom-color 'base7))
    (list 'org-checkbox-statistics-done :foreground (doom-darken (doom-color 'green-2) 0.15))
    ;; "Done" Headlines - success/fail/info/etc.
    ;;    - Would be nice to have green, red, and gray... but we only have the one 'done' face.
    ;;    - So a lighter gray?
    (list 'org-headline-done :foreground (doom-lighten (doom-color 'base7) 0.3))
    ;; (list 'org-headline-done :foreground (doom-darken (doom-color 'green-2) 0.15))

    ;;---
    ;; Org Headlines - adjust a few to be less dark.
    ;;---
    ;; Some unique, headliney colors.
    (list 'outline-1 :foreground (doom-color 'orange))
    (list 'outline-2 :foreground (doom-color 'green+2))
    (list 'outline-3 :foreground (doom-color 'blue-1))
    (list 'outline-4 :foreground (doom-color 'red-1))
    ;; ...and repeat.
    (list 'outline-5 :foreground (doom-color 'orange))
    (list 'outline-6 :foreground (doom-color 'green+2))
    (list 'outline-7 :foreground (doom-color 'blue-1))
    (list 'outline-8 :foreground (doom-color 'red-1))
    ;; ...and 9+ starts over at `outline-1'.

    ;;---
    ;; Org TODO States
    ;;---
    ;; ├CURRENT┤
    (list '+org-todo-active :foreground (doom-color 'violet)
          :background (doom-color 'bg-alt))
    ;; ├WAITING┤, ├HOLDING┤
    (list '+org-todo-onhold :foreground (doom-darken (doom-color 'magenta) 0.3)
          :background (doom-color 'bg-alt))
    ;; ├PROJECT┤
    (list '+org-todo-project :foreground (doom-color 'blue-3)
          :background (doom-color 'bg-alt))


    ;;---
    ;; "#+DOC_KEYWORD" - needs to be slightly lighter.
    ;;---
    (list 'org-document-info-keyword :foreground (doom-color 'base7)))
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
    (list 'whitespace-space :foreground (doom-color 'base6)) ;; zenburn-bg+2
    (list 'whitespace-newline :foreground (doom-color 'base6)) ;; zenburn-bg+2
    ;; whitespace-hspace - leave as-is?
    ;; whitespace-indentation - leave as-is?

    ;;---
    ;; "Ambivalent" Whitespace
    ;;---
    (list 'whitespace-tab :foreground (doom-color 'orange)) ;; zenburn-orange
    ;; whitespace-empty - what is this?
    ;; (list 'whitespace-empty :foreground (doom-color 'red))

    ;;---
    ;; "Bad" Whitespace
    ;;---
    (list 'whitespace-line :foreground (doom-color 'magenta)
          :background (doom-color 'bg-alt)) ;; Soften the bg color.
    ;; whitespace-trailing - leave as-is?
    ;; whitespace-big-indent - Don't know if I've ever seen this... leave as-is for now.
    (list 'whitespace-space-after-tab :foreground (doom-color 'bg-alt)
          :background (doom-color 'magenta)) ;; less eyebleed
    (list 'whitespace-space-before-tab :foreground (doom-color 'bg-alt)
          :background (doom-color 'violet)) ;; less eyebleed
    ))
