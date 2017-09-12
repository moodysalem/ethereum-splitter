pragma solidity ^0.4.15;


contract Splitter {
    function Splitter(){
        owner = msg.sender;
    }

    event LogEtherSplit(address payer, address payee1, address payee2);

    event LogEtherPaidOut(address taker, uint paidOut);

    address internal owner;

    mapping (address => uint) public balancesOwed;

    function splitEther(address payee1, address payee2) payable {
        require(msg.value % 2 == 0);
        require(msg.value > 0);

        uint half = msg.value / 2;
        balancesOwed[payee1] += half;
        balancesOwed[payee2] += half;

        LogEtherSplit(msg.sender, payee1, payee2);
    }

    function withdrawEther(address forPayee) {
        require(balancesOwed[forPayee] > 0);

        uint owed = balancesOwed[forPayee];
        balancesOwed[forPayee] = 0;
        forPayee.transfer(owed);

        LogEtherPaidOut(forPayee, owed);
    }

    function withdrawEther() {
        withdrawEther(msg.sender);
    }

    function destroy(){
        require(owner == msg.sender);
        require(this.balance == 0);

        selfdestruct(owner);
    }
}
