App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    console.log('Initializing...');

    return App.initWeb3();
  },

  initWeb3: function() {
// Is there is an injected web3 instance?
      if (typeof web3 !== 'undefined') {
          App.web3Provider = web3.currentProvider;
          web3 = new Web3(web3.currentProvider);
      } else {
          // If no injected web3 instance is detected, fallback to the TestRPC.
          App.web3Provider = new web3.providers.HttpProvider('http://localhost:8545');
          web3 = new Web3(App.web3Provider);
      }

    return App.initContract();
  },

  initContract: function() {
      $.getJSON('SimpleStorage.json', function(data) {
          // Get the necessary contract artifact file and instantiate it with truffle-contract.
          var SimpleStorageArtifact = data;
          App.contracts.SimpleStorage = TruffleContract(SimpleStorageArtifact);

          // Set the provider for our contract.
          App.contracts.SimpleStorage.setProvider(App.web3Provider);

      });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '#btnSet', App.handleSet);
    $(document).on('click', '#btnGet', App.handleGet);
  },

  handleSet: function() {
    event.preventDefault();

    var input = prompt("Please enter a number to store in the contract", "42");

    var number = parseInt(input);

      var simpleStorageInstance;

      web3.eth.getAccounts(function(error, accounts) {
          if (error) {
              console.log(error);
          }

          var account = accounts[0];

          App.contracts.SimpleStorage.deployed().then(function(instance) {
              simpleStorageInstance = instance;

              return simpleStorageInstance.set(number, {from: account});
          }).then(function(result) {
              console.log('finished');
          }).catch(function(err) {
              console.log(err.message);
              console.log('failed');
          });
      });
  },



  handleGet: function(adopters, account) {
      var simpleStorageInstance;

      App.contracts.SimpleStorage.deployed().then(function(instance) {
          simpleStorageInstance = instance;

          return simpleStorageInstance.get.call();
      }).then(function(number) {
          console.log(number['c']); // I don't understand why i'm getting an array here.
          alert('You stored number: ' + number['c']);
      }).catch(function(err) {
          console.log(err.message);
      });
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
