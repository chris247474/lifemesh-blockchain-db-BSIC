
    import { Connect, SimpleSigner } from 'uport-connect'

    const uport = new Connect('LifeMesh', {
      clientId: '2oq3fdbGXYkWmotZ43TPksn62wK9NmtJYkE',
      network: 'rinkeby or ropsten or kovan',
      signer: SimpleSigner('d09a3c03b60a6a922f27352ffbcac797098cb2ae874f1e6811c3d9d1a9dfcf99')
    })

    // Request credentials to login
    uport.requestCredentials({
      requested: ['name', 'phone', 'country'],
      notifications: true // We want this if we want to recieve credentials
    })
    .then((credentials) => {
      // Do something
    })

    // Attest specific credentials
    uport.attestCredentials({
      sub: THE_RECEIVING_UPORT_ADDRESS,
      claim: {
        CREDENTIAL_NAME: CREDENTIAL_VALUE
      },
      exp: new Date().getTime() + 30 * 24 * 60 * 60 * 1000, // 30 days from now
    })