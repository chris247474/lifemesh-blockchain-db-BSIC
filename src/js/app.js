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
      $.getJSON('LifeMesh.json', function(data) {   
        // Get the necessary contract artifact file and instantiate it with truffle-contract.
        var LifeMeshDBArtifact = data;
        App.contracts.LifeMeshDB = TruffleContract(LifeMeshDBArtifact);

        // Set the provider for our contract.
        App.contracts.LifeMeshDB.setProvider(App.web3Provider);

        // Use our contract to retieve and mark the adopted pets.
        return App.dbCall();
      });

      return App.bindEvents();
  },

  dbCall: function() {
    var dbInstance;
    
    App.contracts.LifeMeshDB.deployed().then(function(instance) {
        console.log('smart contract deployed')
        dbInstance = instance;
        var inputForm = this;
        
        return dbInstance.getProvidersIntIndexArray(); // i used it as a function, not call ".call()" on it.
        }).then(function(indexArr) {
          console.log("there are " + indexArr.length + " providers in the db");
          //var input = prompt("there are " + indexArr.length + " providers in the db", "42");//worked for a while : works again
        }).catch(function(err) {
          console.log(err.message);
        });
  },

  bindEvents: function() {
    $(document).on('submit','#addNeedForm',App.handleAddNeedForm);
    $(document).on('reset', "#GetProviderByIDForm", App.handleOnLoadForInitialDBExplorerData);
    $(document).on('submit','#GetProviderByIDForm', App.handleGetProviderByIDOnForm);
    $(document).on('submit', "#addProviderForm", App.handleAddProviderForm);
  },
  
  handleAddProviderForm: function () {
    console.log("in handleAddProviderForm");
    event.preventDefault();
    var lifemeshInstance;

    var inputForm = this;
     
    web3.eth.getAccounts(function(error, accounts) {
        if (error) {
            console.log(error);
        }

        var account = accounts[0];

       App.contracts.LifeMeshDB.deployed().then(function(instance) {
            console.log("passing args to createProvider: " + inputForm.providerName.value + ", " + inputForm.providerLocation.value);
            
            lifemeshInstance = instance;
            var promiseobj = lifemeshInstance.createProvider(inputForm.providerName.value, inputForm.providerLocation.value);
            
            console.log("createProvider returned: " + promiseobj);
            return promiseobj;
        }).then(function(promiseObj) {
            //to retrieve new provider's index/id, need to use Promises
            console.log('fetched promise object: ' + promiseObj);
            
            inputForm.providerName.value = " ";
            inputForm.providerLocation.value = " ";
        }).catch(function(err) {
            console.log("Error: " + err.message);
        });
    });
  },
  
  handleOnLoadForInitialDBExplorerData: function () {
    console.log("in handleOnLoadForInitialDBExplorerData");
    event.preventDefault();
    var lifemeshInstance;

    var inputForm = this;
    
    web3.eth.getAccounts(function(error, accounts) {
        if (error) {
            console.log(error);
        }

        var account = accounts[0];

       App.contracts.LifeMeshDB.deployed().then(function(instance) {
            lifemeshInstance = instance;
            return lifemeshInstance.getProvidersIntIndexArray();
        }).then(function(result) {
            console.log('fetched provider id: '+result);
                       
            for(providerID in result){
              console.log("adding " + providerID + " to dropdown");
              var option = document.createElement("option");
              option.value = providerID;
              option.innerHTML = providerID; // whatever property it has
              // then append it to the select element
              inputForm.dropdown.appendChild(option);
            }
            
            console.log("getProviderById dropdown populated")
        }).catch(function(err) {
            console.log("Error: " + err.message);
        });
    });
  },
  
  handleGetProviderByIDOnForm: function () {
    console.log("in handleGetProviderByIDOnForm")
    event.preventDefault();
    var lifemeshInstance;

    var inputForm = this;
    
    web3.eth.getAccounts(function(error, accounts) {
        if (error) {
            console.log(error);
        }
 
        var account = accounts[0];

       App.contracts.LifeMeshDB.deployed().then(function(instance) {
            lifemeshInstance = instance;
            console.log("passing arg: "+ inputForm.addProviderDropdownID.value+" to getProviderById");
            
            lifemeshInstance.getProviderById(inputForm.addProviderDropdownID.value)
            .then(function(id, name, location){
              
              console.log('fetched provider id: ' + id + ", name: " + name + ", location: "+ location);
              
              //parse result and assign to inputForm.textAreaResult
              inputForm.textAreaResult.value = 'Provider ID: ' + id + "\nOrganization Name: " + name + "\nHQ Location: "+location;
              
            }).catch(function(err){
              console.log("getProviderById Promise Error: " + err.message);
            });
            
            
        }).then(function() {//, name, location, promise) {
            //console.log('fetched provider id: ' + id);// + ", name: " + name + ", location: "+ location);
          
            
        }).catch(function(err) {
            console.log("Error: " + err.message);
        });
    });
  },

  handleAddNeedForm: function() {
    
    event.preventDefault();
    console.log('handleAddNeedForm');
      var lifemeshInstance;

    var inputForm = this;
    
      web3.eth.getAccounts(function(error, accounts) {
          if (error) {
              console.log(error);
          }

          var account = accounts[0];

         App.contracts.LifeMeshDB.deployed().then(function(instance) {
              lifemeshInstance = instance;
              return lifemeshInstance.createNeed(inputForm.ownerid.value, inputForm.ownerName.value, inputForm.materialType.value, inputForm.quantity.value, inputForm.size.value, inputForm.long.value, inputForm.lat.value);
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
