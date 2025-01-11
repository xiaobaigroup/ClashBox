package executor

type ProviderLoadedHook func(providerName string)

var DefaultProviderLoadedHook ProviderLoadedHook
