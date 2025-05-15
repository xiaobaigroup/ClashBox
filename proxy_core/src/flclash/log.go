//go:build linux

package main

/*


#cgo LDFLAGS: -lhilog_ndk.z
#include <stdlib.h>
#include <hilog/log.h>
#define TAG "flclashGo"

void log_debug(char *msg) {
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_DOMAIN, TAG, "%{public}s", msg);
    free(msg);
}
*/
import "C"

import (
	"bufio"
	"log"
	"os"
	"runtime"
	"runtime/debug"
	"syscall"
)

// 1024 is the truncation limit from android/log.h, plus a \n.
const logLineLimit = 1024

func init() {
	log.SetFlags(log.Flags() &^ log.LstdFlags)
	log.SetOutput(os.Stdout)

	// Redirect stdout and stderr to the Android logger.
	logFd(os.Stdout.Fd())
	logFd(os.Stderr.Fd())
}

func logFd(fd uintptr) {
	r, w, err := os.Pipe()
	if err != nil {
		panic(err)
	}
	if err := syscall.Dup3(int(w.Fd()), int(fd), syscall.O_CLOEXEC); err != nil {
		panic(err)
	}
	go func() {
		defer func() {
			if p := recover(); p != nil {
				log.Printf("panic in logFd %s: %s", p, debug.Stack())
				panic(p)
			}
		}()

		lineBuf := bufio.NewReaderSize(r, logLineLimit)
		for {
			line, _, err := lineBuf.ReadLine()
			if err != nil {
				break
			}
			C.log_debug(C.CString(string(line)))
		}
		// The garbage collector doesn't know that w's fd was dup'ed.
		// Avoid finalizing w, and thereby avoid its finalizer closing its fd.
		runtime.KeepAlive(w)
	}()
}
