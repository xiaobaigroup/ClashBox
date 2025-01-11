//go:build android

package provider

import "time"

var (
	suspended bool
)

type UpdatableProvider interface {
	UpdatedAt() time.Time
}

func Suspend(s bool) {
	suspended = s
}
