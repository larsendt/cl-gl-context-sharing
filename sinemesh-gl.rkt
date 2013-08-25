#!/home/dane/chematox/local/racket-5.90.0.6/bin/racket
#lang racket/gui

(require ffi/unsafe
         ffi/unsafe/cvector
         ffi/vector
         (planet stephanh/RacketGL:1:4/rgl)
         "../c.rkt"
         "glcontext.rkt")

(define (resize w h)
  (glViewport 0 0 w h)
  #t)



(define my-canvas%
  (class* canvas% ()
    (inherit with-gl-context swap-gl-buffers)

    (super-instantiate () (style '(gl)))

    (define vertex-buf 0)
    (define index-buf 0)
    (define mesh-width 20)
    (define mesh-height 20)
    (define vertex-count 6)

    (with-gl-context
      (lambda ()
        (define glctx (cast
                        (current-glx-context)
                        _GLXContext
                        _intptr))

        (define gldisplay (cast
                            (current-glx-display)
                            _Display
                            _intptr))

        (define platform (cast
                           (cvector-ref (clGetPlatformIDs:vector) 0)
                           _cl_platform_id
                           _intptr))

        (define propvec (vector CL_GL_CONTEXT_KHR glctx
                                CL_GLX_DISPLAY_KHR gldisplay
                                CL_CONTEXT_PLATFORM platform
                                0))

        (printf "~v~n" (clGetGLContextInfoKHR:generic propvec 'CL_DEVICES_FOR_GL_CONTEXT_KHR))

        (set! vertex-buf (u32vector-ref (glGenBuffers 1) 0))

        (glBindBuffer GL_ARRAY_BUFFER vertex-buf)
        (define bufsize (* mesh-width mesh-height 4 (ctype-sizeof _float)))
        (glBufferData GL_ARRAY_BUFFER
                      bufsize
                      0
                      GL_DYNAMIC_DRAW)

        (set! index-buf (u32vector-ref (glGenBuffers 1) 0))
        (define indices (list->u32vector
                          (stream->list
                            (in-range 0 vertex-count))))
        (glBindBuffer GL_ELEMENT_ARRAY_BUFFER index-buf)
        (glBufferData GL_ELEMENT_ARRAY_BUFFER
                      (* (u32vector-length indices)
                         (ctype-sizeof _uint))
                      (u32vector->cpointer indices)
                      GL_DYNAMIC_DRAW)))


    (define/override (on-paint)
      (with-gl-context
        (lambda ()
          (draw-opengl)
          (swap-gl-buffers))))

    (define/override (on-size width height)
      (with-gl-context
        (lambda ()
          (resize width height))))

    (define (draw-opengl)
      (glClearColor 0.0 0.0 0.0 0.0)
      (glClear GL_COLOR_BUFFER_BIT)
      (glColor3d 1.0 1.0 1.0)

      (glMatrixMode GL_PROJECTION)
      (glLoadIdentity)
      (glOrtho 0.0 1.0 0.0 1.0 -1.0 1.0)
      (glMatrixMode GL_MODELVIEW)
      (glLoadIdentity)

      (glBindBuffer GL_ARRAY_BUFFER vertex-buf)
      (glEnableClientState GL_VERTEX_ARRAY)
      (glVertexPointer 4 GL_FLOAT 0 0)

      (glBindBuffer GL_ELEMENT_ARRAY_BUFFER index-buf)
      (glDrawElements GL_TRIANGLE_STRIP vertex-count GL_UNSIGNED_INT 0))))


(define win (new frame% (label "OpenGL Test") (min-width 200) (min-height 200)))
(define gl  (new my-canvas% (parent win)))

(send win show #t)

