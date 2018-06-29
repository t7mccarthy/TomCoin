var ConvertLib = artifacts.require("./ConvertLib.sol");
var TomCoin = artifacts.require("./TomCoin.sol");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, TomCoin);
  deployer.deploy(TomCoin);
};
