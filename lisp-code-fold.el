;;; lisp-code-fold.el ---                                -*- lexical-binding: t; -*-

;; Copyright (C) 2021

;; Author:  <matthew.j.oconnell1@gmail.com>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'hideshow)
(require 'subr-x)

(defun configure-auto-hide-preferences ()
  "Configures forms that should auto hide on load of buffer."
  (interactive)
  (hs-minor-mode 1)
  (hs-life-goes-on
   (save-excursion
     (goto-char (point-min))

     (while (ignore-errors (re-search-forward "^("))
       (hs-hide-block)))))

(defmacro make-clojure-tab-function ()
  "Return a clojure mode-specific function suitable for binding to TAB.
This newly bound function will first determine if it should fold by;

1) Ensuring the cursor is at the beginning of a line
2) Proceding text is a namespace form or defn* form
3) Proceding text immediatlly follows (point)

If those checks fail it will fallback to the default tab behavior."
  (let ((original-tab-function (key-binding (kbd "TAB") t)))
    `(let ((new-tab-function
            (lambda ()
              (interactive)
              (let ((should-fold (when (bolp)
                                   (let ((proceeding-text (string-trim-right
                                                           (buffer-substring-no-properties (point) (point-at-eol)))))
                                     (string-prefix-p "(" proceeding-text)))))
                (if should-fold
                    (progn
                      (hs-toggle-hiding)
                      (beginning-of-line)
                      (,original-tab-function))
                  (,original-tab-function))))))
       new-tab-function)))

(defun lisp-code-fold-init ()
  "Configures hide-show-preferences."
  ;; Automatically open a block if you search for something where it matches
  (setq hs-isearch-open t)

  (configure-auto-hide-preferences)
  (local-set-key (kbd "TAB") (make-clojure-tab-function)))

(provide 'lisp-code-fold)
;;; lisp-code-fold.el ends here
