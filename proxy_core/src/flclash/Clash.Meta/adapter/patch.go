package adapter

type UrlTestCheck func(name string, delay uint16)

var UrlTestHook UrlTestCheck
