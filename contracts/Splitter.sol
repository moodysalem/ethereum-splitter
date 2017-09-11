pragma solidity ^0.4.15;


contract Splitter {
    function Splitter(){
        owner = msg.sender;
    }

    event LogEtherSplit(address payer, address payee1, address payee2);

    event LogEtherPaidOut(address taker, uint paidOut);

    address owner;

    mapping (address => uint) balancesOwed;

    address[] haveBalances;

    function splitEther(address payee1, address payee2) payable {
        require(msg.value % 2 == 0);
        require(msg.value > 0);

        uint half = msg.value / 2;
        balancesOwed[payee1] += half;
        balancesOwed[payee2] += half;

        LogEtherSplit(msg.sender, payee1, payee2);

        haveBalances.push(payee1);
        haveBalances.push(payee2);
    }

    function totalOwed() constant returns (uint total){
        return this.balance;
    }

    function payeeOwed(address payee) constant returns (uint amountPayeeOwed) {
        return balancesOwed[payee];
    }

    function withdrawEther() {
        require(balancesOwed[msg.sender] > 0);

        uint owed = balancesOwed[msg.sender];
        balancesOwed[msg.sender] = 0;
        msg.sender.transfer(owed);

        LogEtherPaidOut(msg.sender, owed);
    }

    function destroy(){
        require(owner == msg.sender);

        for (uint i = 0; i < haveBalances.length; i++) {
            uint toPay = balancesOwed[haveBalances[i]];
            if (toPay > 0) {
                haveBalances[i].transfer(toPay);
            }
        }

        selfdestruct(owner);
    }
}
