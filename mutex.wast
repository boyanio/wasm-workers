;; Taken from https://github.com/WebAssembly/threads/blob/master/proposals/threads/Overview.md
;; Try to lock a mutex at the given address.
;; Returns 1 if the mutex was successfully locked, and 0 otherwise.
(func $_tryLockMutex (param $mutexAddr i32) (result i32)
  ;; Attempt to grab the mutex. The cmpxchg operation atomically
  ;; does the following:
  ;; - Loads the value at $mutexAddr.
  ;; - If it is 0 (unlocked), set it to 1 (locked).
  ;; - Return the originally loaded value.
  (i32.atomic.rmw.cmpxchg
    (local.get $mutexAddr) ;; mutex address
    (i32.const 0)          ;; expected value (0 => unlocked)
    (i32.const 1))         ;; replacement value (1 => locked)

  ;; The top of the stack is the originally loaded value.
  ;; If it is 0, this means we acquired the mutex. We want to
  ;; return the inverse (1 means mutex acquired), so use i32.eqz
  ;; as a logical not.
  (i32.eqz)
)

;; Lock a mutex at the given address, retrying until successful.
(func $__ZNSt3__25mutex4lockEv (param $mutexAddr i32)
  (block $done
    (loop $retry
      ;; Try to lock the mutex. $tryLockMutex returns 1 if the mutex
      ;; was locked, and 0 otherwise.
      (call $_tryLockMutex (local.get $mutexAddr))
      (br_if $done)

      ;; Wait for the other agent to finish with mutex.
      (i32.atomic.wait
        (local.get $mutexAddr) ;; mutex address
        (i32.const 1)          ;; expected value (1 => locked)
        (i64.const -1))        ;; infinite timeout

      ;; i32.atomic.wait returns:
      ;;   0 => "ok", woken by another agent.
      ;;   1 => "not-equal", loaded value != expected value
      ;;   2 => "timed-out", the timeout expired
      ;;
      ;; Since there is an infinite timeout, only 0 or 1 will be returned. In
      ;; either case we should try to acquire the mutex again, so we can
      ;; ignore the result.
      (drop)

      ;; Try to acquire the lock again.
      (br $retry)
    )
  )
)

;; Unlock a mutex at the given address.
(func $__ZNSt3__25mutex6unlockEv (param $mutexAddr i32)
  ;; Unlock the mutex.
  (i32.atomic.store
    (local.get $mutexAddr)     ;; mutex address
    (i32.const 0))             ;; 0 => unlocked

  ;; Notify one agent that is waiting on this lock.
  (drop
    (atomic.notify
      (local.get $mutexAddr)   ;; mutex address
      (i32.const 1)))          ;; notify 1 waiter
)