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

  (defvar markdown-command)
  (defvar LaTeX-mode-map)
  (defvar corfu-map)
  (defvar corfu-popupinfo-delay)
  (defvar tramp-use-ssh-controlmaster-options)
  (defvar tramp-verbose)
  
  (declare-function pdf-loader-install nil)
  (declare-function TeX-revert-document-buffer nil)
  (declare-function pyvenv-mode nil)
  (declare-function pyvenv-workon-home nil)
  (declare-function global-corfu-mode nil)
  (declare-function corfu-popupinfo-mode nil)
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
    corfu
    jupyter              ;; melpa
    htmlize
    magit
    markdown-mode
    pdf-tools
    pyvenv               ;; melpa
    use-package
    xwwp                 ;; melpa
    processing-mode      ;; melpa
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
(setq org-latex-src-block-backend 'listings)

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

;; Markdown support
(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

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
	      (define-key LaTeX-mode-map (kbd "$") 'self-insert-command)
	      )
	    )

(add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)

;; ===================================
;; Programming Modes
;; ===================================
(add-hook 'prog-mode-hook 'display-line-numbers-mode) ;; Show line numbers for programming languages

(use-package corfu
  :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  ;; (corfu-separator ?\s)          ;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin

  :bind
  (:map corfu-map
	;; Option 1: Unbind RET completely
	("RET" . nil))
  :init
  (global-corfu-mode))

(use-package corfu-popupinfo
  :init
  (corfu-popupinfo-mode)
  (setq corfu-popupinfo-delay '(1.0 . 0.1)))

(use-package emacs
  :init
  (setq completion-cycle-threshold 3))

(add-hook 'emacs-lisp-mode-hook 'flymake-mode)

;; Python with eglot
;; (add-hook 'python-mode-hook 'eglot-ensure)
(setq-default eglot-workspace-configuration
	      '(:pylsp (:skip_token_initialization t
			:plugins (:ruff (:enabled t
						  :formatEnabled t)
				  :pylsp_mypy (:enabled t)))
		))

;; Conda and TRAMP setup

(pyvenv-mode 1)

(defun tramp-conda-setup()
  "Set up conda for tramp."
  (when default-directory (if (file-remote-p default-directory)
				(setenv "WORKON_HOME" (concat (file-remote-p default-directory) "~/.virtualenvs"))
			      (setenv "WORKON_HOME" "~/.virtualenvs"))))

(advice-add #'pyvenv-workon-home :before #'tramp-conda-setup)

(setq tramp-use-ssh-controlmaster-options nil)
(setq exec-path (append exec-path '("/afs/.ir/users/b/i/bidiptas/bin")))
(setq tramp-verbose 6)

(add-to-list 'auto-mode-alist '("\\.cu\\'" . c++-mode))
(add-hook 'c++-mode-hook 'eglot-ensure)

(setq processing-location "/usr/local/bin/processing-java")
(setq processing-application-dir "/Applications/Processing.app")
(setq processing-sketchbook-dir "~/Documents/Processing")

;; emacs -eval "(message (emacs-init-time))" -Q
(message (emacs-init-time))

(provide 'init)
;;; init.el ends here
