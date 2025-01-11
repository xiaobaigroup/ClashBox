package listener

func StopListener() {

	if socksListener != nil {
		_ = socksListener.Close()
		socksListener = nil
	}

	if socksUDPListener != nil {
		_ = socksUDPListener.Close()
		socksUDPListener = nil
	}

	if httpListener != nil {
		_ = httpListener.Close()
		httpListener = nil
	}

	if redirListener != nil {
		_ = redirListener.Close()
		redirListener = nil
	}

	if redirUDPListener != nil {
		_ = redirUDPListener.Close()
		redirUDPListener = nil
	}

	if tproxyListener != nil {
		_ = tproxyListener.Close()
		tproxyListener = nil
	}

	if tproxyUDPListener != nil {
		_ = tproxyUDPListener.Close()
		tproxyUDPListener = nil
	}

	if mixedListener != nil {
		_ = mixedListener.Close()
		mixedListener = nil
	}

	if mixedUDPLister != nil {
		_ = mixedUDPLister.Close()
		mixedUDPLister = nil
	}

	if tunLister != nil {
		_ = tunLister.Close()
		tunLister = nil
	}

	if shadowSocksListener != nil {
		_ = shadowSocksListener.Close()
		shadowSocksListener = nil
	}

	if shadowSocksListener != nil {
		_ = shadowSocksListener.Close()
		shadowSocksListener = nil
	}

	if vmessListener != nil {
		_ = vmessListener.Close()
		vmessListener = nil
	}

	if tuicListener != nil {
		_ = tuicListener.Close()
		tuicListener = nil
	}
}
