pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Splitter.sol";

contract TestSplitter {

    function testInitialBalanceUsingDeployedContract() {
        Splitter splitter = Splitter(DeployedAddresses.Splitter());

        Assert.equal(splitter.balancesOwed(tx.origin), 0, "Owner should be owed 0 initially");
    }

    function testInitialBalanceWithNewSplitter() {
        Splitter splitter = new Splitter();

        Assert.equal(splitter.balancesOwed(tx.origin), 0, "Owner should be owed 0 initially");
    }

}
