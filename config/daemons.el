;;; config/daemons.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Emacs Server
;;------------------------------------------------------------------------------
;; Make sure Emacs Server is running so emacs will collect itself into one
;; instance and drag-drop, send from Visual Studio, etc will work as expected.

;; (Not using emacs as daemon right now... https://www.emacswiki.org/emacs/EmacsAsDaemon )
;; Just start server for emacs when needed by emacs.

(require 'server)


;; server-auth-dir


;; server-socket-dir


;; server-name
;;   The command server-start makes use of this.  It should not be
;;   changed while a server is running.
;;   If this is a file name with no leading directories, Emacs will
;;   create a socket file by that name under server-socket-dir
;;   if server-use-tcp is nil, else under server-auth-dir.
;;   If this is an absolute file name, it specifies where the socket
;;   file will be created.  To have emacsclient connect to the same
;;   socket, use the "-s" switch for local non-TCP sockets, and
;;   the "-f" switch otherwise.


(defun spy:emacs/server:path ()
  "Path to server file."
  (spy:path/join (if (and server-use-tcp
                          server-socket-dir)
                     server-socket-dir
                   server-auth-dir)
                 server-name))


(defun spy:emacs/server:file? ()
  "Returns non-nil if server file exists."
  ;; Windows 10: `server-use-tcp' is `t' (`server-socket-dir' is `nil') and...
  ;; server file gets put into `server-auth-dir'.

  ;; Return the path? Or just t/nil from `file-exists-p'?
  (file-exists-p (spy:emacs/server:path)))
;; (spy:emacs/server:file.exists)


;; `server-running-p' doesn't work.
;;   - http://emacshorrors.com/posts/determining-if-the-server-is-started-or-the-wonders-of-server-running-p.html
;;     -> http://lists.gnu.org/archive/html/bug-gnu-emacs/2018-06/msg00723.html
;; (unless (server-running-p) (server-start))
(defun spy:emacs/server:process? ()
    "Return non-nil if this Emacs has a server process."
    (bound-and-true-p server-process))
;; (spy:emacs/server:process?)


(defun spy:emacs/server:running? ()
    "Return non-nil if this Emacs has a server process and a server file."
    (and (spy:emacs/server:process?)
         (spy:emacs/server:file?)))
;; (spy:emacs/server:running?)


(if (spy:emacs/server:running?)
    ;; Ignore - already running.
    (mis0/init/warning "spy:emacs/server:running?"
                       "[daemons] Server already running: %s"
                       (spy:emacs/server:path))

  ;; Start up a server.
  (mis0/init/message "[daemons] Starting server.")
  (server-start))




;;------------------------------------------------------------------------------
;; The End!
;;------------------------------------------------------------------------------
;; You get nothing provided and you'll like it.
