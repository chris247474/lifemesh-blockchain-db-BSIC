/*var ConvertLib = artifacts.require("./ConvertLib.sol");
var MetaCoin = artifacts.require("./MetaCoin.sol");
var SimpleStorage = artifacts.require("./SimpleStorage.sol");*/
var Strings = artifacts.require("./strings.sol");
var LifeMesh = artifacts.require("./LifeMesh.sol");

module.exports = function(deployer) {
  /*deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, MetaCoin);
  deployer.deploy(MetaCoin);
  deployer.deploy(SimpleStorage);*/
  deployer.deploy(Strings);
  deployer.link(Strings, LifeMesh);
  deployer.deploy(LifeMesh);
};
