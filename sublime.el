;;; sublime.el --- SublimeText emulation
;;;
;;; Copyright (C) 2012 Lorenzo Villani, Aaron Culich.
;;;
;;; Author: Lorenzo Villani <lorenzo@villani.me>
;;; Maintainer: Aaron Culich <aculich@gmail.com>
;;; URL: https://github.com/lvillani/sublime.el
;;;
;;; This file is not part of GNU Emacs.
;;;
;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2, or (at your option)
;;; any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;;;


(unless (>= 24 emacs-major-version)
  (error "sublime.el requires Emacs 24 or later."))


;;; ---------------------------------------------------------------------------
;;; Utility Functions
;;; ---------------------------------------------------------------------------

;;;###autoload
(defun sublime-escape-quit ()
  "Forcefully closes anything which keeps the minibuffer busy."
  (interactive)
  (when (active-minibuffer-window)
    (select-window (active-minibuffer-window)))
  (keyboard-escape-quit))


;;;###autoload
(defun sublime-kill-current-buffer ()
  "Kills the current buffer."
  (interactive)
  (kill-buffer (current-buffer)))


;;;###autoload
(defun sublime-open-file ()
  "Forces menu-find-file-existing to show a GUI dialog box"
  (interactive)
  (let ((last-nonmenu-event nil))
    (menu-find-file-existing)))


;;;###autoload
(defun sublime-open-recent-file ()
  "Integrates `ido-completing-read' with `recentf-mode'"
  (interactive)
  (find-file (ido-completing-read "Find recent file: " recentf-list)))


;;;###autoload
(defun sublime-indent-buffer ()
  "Re-indents the current buffer."
  (interactive)
  (save-excursion
    (indent-region (point-min) (point-max) nil)))




;;; ---------------------------------------------------------------------------
;;; Under The Hood
;;; ---------------------------------------------------------------------------

;;;###autoload
(defun sublime-setup-electric ()
  "Enables automatic matching of parentheses."
  ; (electric-indent-mode) ; - DISABLED: Annoying for some users.
  (electric-layout-mode)
  (electric-pair-mode))


;;;###autoload
(defun sublime-setup-clipboard ()
  "Improve interaction with X11 clipboard giving Emacs the 'feel'
of a modern X11 application."
  (interactive)
  (global-set-key "\C-w" 'clipboard-kill-region)
  (global-set-key "\C-y" 'clipboard-yank)
  (global-set-key "\M-w" 'clipboard-kill-ring-save)
  (global-set-key [mouse-2] 'mouse-yank-primary)
  (setq mouse-drag-copy-region nil)
  (setq select-active-regions t)
  (setq x-select-enable-clipboard t)
  (setq x-select-enable-primary nil))


;;;###autoload
(defun sublime-setup-elpa-repositories ()
  "Configure ELPA to use the GNU and Marmalade repositories."
  (setq package-archives
        '(("gnu" . "http://elpa.gnu.org/packages/")
          ("marmalade" . "http://marmalade-repo.org/packages/"))))


;;;###autoload
(defun sublime-setup-file-hooks ()
  (custom-set-variables '(auto-save-default nil)
                        '(backup-inhibited t)
                        '(fill-column 78)
			'(indent-tabs-mode nil)
                        '(indicate-empty-lines t)
                        '(require-final-newline t)
                        '(tab-width 4)
                        '(ruby-indent-level tab-width))
  ;; Flyspell
  (add-hook 'text-mode-hook 'flyspell-mode)
  (add-hook 'prog-mode-hook 'flyspell-prog-mode)
  ;; File Manipulation
  (add-hook 'before-save-hook 'delete-trailing-whitespace)
  (add-hook 'before-save-hook 'time-stamp)
  (add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p nil t))


;;;###autoload
(defun sublime-setup-indentation ()
  "Homogeneous indentation level for various modes."
  (interactive)
  (setq tab-width 4
        puppet-indent-level tab-width
        ruby-indent-level tab-width))


;;;###autoload
(defun sublime-setup-mode-assoc ()
  "Configures file-extension -> mode association."
  (interactive)
  (add-to-list 'auto-mode-alist '("COMMIT_EDITMSG" . text-mode))
  (add-to-list 'auto-mode-alist '("\\.markdown$" . markdown-mode))
  (add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode)))


;;;###autoload
(defun sublime-setup-recentf ()
  "Configures `recentf' for use in combination with `ido-mode'"
  (setq recentf-max-saved-items 75)
  (recentf-mode t)
  (global-set-key (kbd "C-x C-r") 'sublime-open-recent-file))




;;; ---------------------------------------------------------------------------
;;; Keyboard
;;; ---------------------------------------------------------------------------

;;;###autoload
(defun sublime-setup-snippets ()
  "Enables emacs-wise snippets support using YASnippet."
  (interactive)
  (let* ((name "yasnippet")
         (symbol (intern name))
         (yasnippet-dir
         (package--dir name
          (package-version-join
           (package-desc-vers
            (cdr (assq 'yasnippet package-alist)))))))
    (load (expand-file-name name yasnippet-dir))
    (yas/load-directory (expand-file-name "snippets" yasnippet-dir))
    (yas/global-mode)))


;;;###autoload
(defun sublime-setup-go-to-anything ()
  "Emulates SublimeText `Go-To Anything' feature using IDO and SMEX.
It binds C-S-p to `SMEX' and C-p to `FIND-FILE-IN-PROJECT'."
  (interactive)
  (setq ido-create-new-buffer 'always
        ido-everywhere t
        ido-ignore-extensions t
        ido-use-filename-at-point 'guess
        ido-auto-merge-work-directories-length nil
        ido-enable-prefix nil
        ido-max-prospects 8
        ido-use-filename-at-point 'guess
        ido-enable-flex-matching t)
  (setq ffip-limit 2048)
  (ido-mode t)
  (ido-ubiquitous t)
  (smex-initialize)
  (global-set-key (kbd "A-p") 'find-file-in-project)
  (global-set-key (kbd "C-S-p") 'smex))


;;;; How now, you secret, black, and midnight hags!
;;;; What is't you do?
;;;###autoload
(defun sublime-setup-keybindings ()
  "Turn away, weary adventurer, for this path leads straight into
the Mouth of Madness!

Hark! Learn the fate of those who came before you:

I did not shriek, but all the fiendish ghouls that ride the
nightwind shrieked for me as in that same second there crashed
down upon my mind a single and fleeting avalanche of
soul-annihilating memory. His eyes refused to close, he did not
shriek, but the hideous unholy abominations shrieked for him, as
in the same second he saw them spill and tumble upwards out of an
enormous carrion black pit, choked with the gleaming white bones
of countless unhallowed centuries."
  (interactive)
  ;; CUA Mode
  (cua-mode t)
  ;; Editing
  (global-set-key (kbd "C-/") 'comment-or-uncomment-region)
  (global-set-key (kbd "C-<backspace>") 'backward-kill-word)
  (global-set-key (kbd "C-a") 'mark-whole-buffer)
  (global-set-key (kbd "RET") 'newline-and-indent)
  ;; Buffer Navigation
  (global-set-key (kbd "C-<next>") 'next-buffer)
  (global-set-key (kbd "C-<prior>") 'previous-buffer)
  (global-set-key (kbd "C-q") 'save-buffers-kill-terminal)
  (global-set-key (kbd "C-s") 'save-buffer)
  (global-set-key (kbd "C-w") 'sublime-kill-current-buffer)
  (global-set-key (kbd "RET") 'newline-and-indent)

  (message "*ROAR* *chomp* *snurfle* *chomp*!

Much to the delight of the Wumpus, you walked right into his mouth,
making you one of the easiest dinners he's ever had!"))




;;; ---------------------------------------------------------------------------
;;; User Interface
;;; ---------------------------------------------------------------------------

;;;###autoload
(defun sublime-setup-font ()
  "Chooses a font native to the platform (if available)."
  (interactive)
  (when (string-equal system-type "gnu/linux")
    (if (find-font (font-spec :name "Ubuntu Mono"))
        (set-default-font "Ubuntu Mono-12")
      (set-default-font "Monospace-11"))))


;;;###autoload
(defun sublime-setup-ui ()
  "Various user interface customizations."
  (interactive)
  (setq echo-keystrokes 0.01
        inhibit-startup-screen t
        linum-format "  %d  "
        show-paren-delay 0
        frame-title-format '("%f - " user-real-login-name "@" system-name))
  (load-theme 'monokai)
  (fset 'yes-or-no-p 'y-or-n-p)
  (blink-cursor-mode t)
  (column-number-mode t)
  (global-linum-mode t)
  (global-hl-line-mode t)
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  ;; Truncate lines everywhere
  (set-default 'truncate-lines t)
  (setq truncate-partial-width-windows nil)
  ;; Show Paren mode
  (show-paren-mode t)
  (set-face-attribute 'show-paren-match-face nil :underline t)
  ;; ---------------
  (tool-bar-mode -1)
  (which-function-mode t))




;;; ---------------------------------------------------------------------------
;;; Activates all customizations.
;;; ---------------------------------------------------------------------------

;;;###autoload
(defun sublime-activate ()
  "Enables all customization options provided by `sublime.el'."
  (interactive)
  ;; Under the Hood Settings
  (sublime-setup-clipboard)
  (sublime-setup-electric)
  (sublime-setup-elpa-repositories)
  (sublime-setup-file-hooks)
  (sublime-setup-indentation)
  (sublime-setup-mode-assoc)
  (sublime-setup-recentf)
  ;; Keyboard settings
  ;;;; By the pricking of my thumbs,
  ;;;; Something wicked this way comes. [Knocking]
  ;;;; Open locks,
  ;;;; Whoever knocks!
  ;; (sublime-setup-keybindings)  ;; TURN BACK! Do NOT choose this path!!!
  (sublime-setup-go-to-anything)
  (sublime-setup-snippets)
  ;; UI Settings
  (sublime-setup-font)
  (sublime-setup-ui))

;;;###autoload
(progn
  (sublime-activate))

(provide 'sublime)

;;; sublime.el ends here
