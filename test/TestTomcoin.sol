pragma solidity ^0.4.22;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TomCoin.sol";

contract TestTomcoin {

  function testInitialBalanceUsingDeployedContract() public {
    TomCoin tom = TomCoin(DeployedAddresses.TomCoin());

    uint expected = 10000;

    Assert.equal(tom.getBalance(tx.origin), expected, "Owner should have 10000 TomCoin initially");
  }

  function testInitialBalanceWithNewTomCoin() public {
    TomCoin tom = new TomCoin();

    uint expected = 10000;

    Assert.equal(tom.getBalance(tx.origin), expected, "Owner should have 10000 TomCoin initially");
  }

}
