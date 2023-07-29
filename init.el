;; .emacs.d/init.el --- Init for Emacs

;;; Commentary:

;; Lightweight Emacs config file to make Emacs look like atom
;; while having tramp/python/c++/latex support.

;;; Code:

;; This is only here to resolve flymake complaints
(eval-when-compile
  (defvar xwwp-search-prefix)
  (defvar org-image-actual-width)
  (defvar org-support-shift-select)
  (defvar org-latex-listings)
  (defvar org-src-fontify-natively)
  (defvar org-file-apps)
  (defvar TeX-auto-save)
  (defvar TeX-parse-self)
  (defvar TeX-view-program-selection)
  (defvar TeX-source-correlate-start-server)
  (defvar TeX-source-correlate-method)
  (defvar TeX-source-correlate-mode)
  (defvar reftex-plug-into-AUCTeX)
  (defvar reftex-bibliography-commands)
  (declare-function pdf-loader-install nil)
  (declare-function TeX-revert-document-buffer nil)
  (declare-function pyvenv-mode nil)
  (declare-function pyvenv-workon-home nil)
  )

;; ===================================
;; MELPA Package Support
;; ===================================
;; Enables basic packing support
(require 'package)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)

(when (not package-archive-contents) (package-refresh-contents))

(defvar my-packages
  '(atom-one-dark-theme  ;; melpa
    htmlize
    magit
    pdf-tools
    pyvenv               ;; melpa
    use-package
    xwwp                 ;; melpa
    ))

;; Iterate on packages and install missing ones
(dolist (pkg my-packages)
  (unless (package-installed-p pkg)
    (package-install pkg)))

;; ===================================
;; Basic Customization
;; ===================================

(load-theme 'atom-one-dark t)

(setq inhibit-startup-message t)    ;; Hide the startup message
(setq column-number-mode t)         ;; Show column number in mode-line
(global-superword-mode t)           ;; Superword for all buffers
(delete-selection-mode t)           ;; Delete when typing over selection
(setq split-height-threshold nil)   ;; Do not split by height by default
(setq split-width-threshold 0)      ;; Split by width by default
(electric-pair-mode t)              ;; Default electric pairs (opening parentheses create closing)
(setq use-short-answers t)          ;; Use y/n instead of yes or no
(setq make-backup-files nil)        ;; Do not save the backup files ~filename

(windmove-default-keybindings 'meta);; Use option key with arrows to switch which window is active

;; separate custom.el so users can set preferences separately
(defconst custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)

;; ===================================
;; macOS Default Keys
;; ===================================
(setq mac-option-modifier 'meta
      mac-command-modifier 'super
      mac-right-option-modifier 'meta)

(when (string= system-type "darwin") (defvar dired-use-ls-dired nil))

(defun comment-or-uncomment-region-or-line ()
  "Comments the region or the current line if there's no active region."
  (interactive)
  (let (beg end)
    (if (region-active-p)
	(setq beg (region-beginning) end (region-end))
      (setq beg (line-beginning-position) end (line-end-position)))
    (comment-or-uncomment-region beg end)))

(global-set-key (kbd "s-Z") 'undo-redo)
(global-set-key (kbd "s-/") 'comment-or-uncomment-region-or-line)
(global-set-key (kbd "C-s-f") 'toggle-frame-fullscreen)

(global-set-key (kbd "M-s-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "M-s-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "M-s-<up>") 'shrink-window)
(global-set-key (kbd "M-s-<down>") 'enlarge-window)

;; ===================================
;; xwwp setup
;; ===================================
(use-package xwwp)
(setq xwwp-search-prefix "https://duckduckgo.com/?q=")

;; ===================================
;; Writing Modes
;; ===================================
(defun human-text-on ()
  "Turn on human text options."
  (turn-on-visual-line-mode)
  (display-line-numbers-mode)
  )

;; Txt support
(add-hook 'text-mode-hook #'human-text-on)

;; Org support
(setq org-image-actual-width 500)
(add-hook 'org-mode-hook #'human-text-on)
(setq org-support-shift-select t)
(setq org-latex-listings t)

(use-package htmlize)
(setq org-src-fontify-natively t)
(setq browse-url-browser-function 'xwidget-webkit-browse-url)
(setq org-file-apps
      '((auto-mode . emacs)
	("\\.x?html?\\'" . (lambda (file link) (xwidget-webkit-browse-url (concat "file://" link))))
	("\\.mp4\\'" . "vlc \"%s\"")))

(org-babel-do-load-languages 'org-babel-load-languages
			     '(
			       (python . t)
			       (shell . t)
			       ))

;; Latex support
(pdf-loader-install)
(add-hook 'pdf-view-mode-hook 'pdf-view-dark-minor-mode)

(add-hook 'eww-mode-hook 'pdf-tools-install)

(use-package tex
  :ensure auctex)

(add-hook 'LaTeX-mode-hook
	  (lambda()
	    (turn-on-reftex)
	    (flyspell-mode)
	    (setq TeX-auto-save t)
	    (setq TeX-parse-self t)
	    (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
		  TeX-source-correlate-start-server t)
	    (setq TeX-source-correlate-method 'synctex)

	    (setq TeX-source-correlate-mode t)
	    (setq-default TeX-master nil)
	    (global-set-key (kbd "C-c C-g") 'pdf-sync-forward-search)
	    (setq reftex-plug-into-AUCTeX t)
	    (setq reftex-bibliography-commands '("bibliography" "nobibliography" "addbibresource"))
	    )
	  )

(add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)

;; ===================================
;; Programming Modes
;; ===================================
(add-hook 'prog-mode-hook 'display-line-numbers-mode) ;; Show line numbers for programming languages

(add-hook 'emacs-lisp-mode-hook 'flymake-mode)

;; Python with eglot
(add-hook 'python-mode-hook 'eglot-ensure)

;; Conda and TRAMP setup

(pyvenv-mode 1)

(defun tramp-conda-setup()
  "Set up conda for tramp."
  (when default-directory (if (file-remote-p default-directory)
			      (setenv "WORKON_HOME" (concat (file-remote-p default-directory) "~/.virtualenvs"))
			    (setenv "WORKON_HOME" "~/.virtualenvs"))))

(advice-add #'pyvenv-workon-home :before #'tramp-conda-setup)

(setq tramp-use-ssh-controlmaster-options nil)
(setq tramp-controlmaster-options "-o ControlMaster=auto -o ControlPersist=no")
(setq exec-path (append exec-path '("/afs/.ir/users/b/i/bidiptas/bin")))
(setq tramp-verbose 6)

;; emacs -eval "(message (emacs-init-time))" -Q
(message (emacs-init-time))

(provide 'init)
;;; init.el ends here
