#lang racket

(require ffi/unsafe
         ffi/unsafe/define)

(provide _GLXContext
         _Display
         current-glx-context
         current-glx-display)

(define-ffi-definer define-gdkglext
                    (ffi-lib "libgdkglext-x11-1.0"))

(define _GLXContext (_cpointer 'GLXContext))
(define _Display (_cpointer 'Display))

(define-gdkglext glXGetCurrentContext (_fun -> _GLXContext))
(define-gdkglext glXGetCurrentDisplay (_fun -> _Display))

(define (current-glx-context)
  (glXGetCurrentContext))

(define (current-glx-display)
  (glXGetCurrentDisplay))
