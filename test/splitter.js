const Splitter = artifacts.require('./Splitter.sol');

contract('Splitter', function (accounts) {

  it('should have empty balance to start', function () {
    return Splitter.deployed()
      .then(instance => instance.payeeOwed(accounts[0]))
      .then(balance => {
        assert.equal(balance.valueOf(), 0, '0 wasn\'t the initial balance');
      });
  });

  it('should fail if no ether is sent', function (done) {
    Splitter.deployed()
      .then(instance => instance.splitEther(accounts[1], accounts[2], {from: accounts[0], value: 0}))
      .then(() => {
        assert.fail();
      })
      .catch(() => done());
  });

  it('should fail if an odd amount of ether is sent', function (done) {
    Splitter.deployed()
      .then(instance => instance.splitEther(accounts[1], accounts[2], {from: accounts[0], value: 1}))
      .catch(() => done());
  });

  it('should not let you withdraw if you have no ether', done => {
    let _instance;
    Splitter.deployed()
      .then(instance => _instance = instance)
      .then(
        () => _instance.payeeOwed(accounts[0])
      )
      .then(owed0 => {
        assert.equal(owed0, 0, 'account 0 is not owed any ether');
        return _instance.withdrawEther({from: accounts[0]});
      })
      .catch(err => {
        done();
      });
  });

  it('should split ether that is paid in', function () {
    let _instance;

    return Splitter.deployed()
      .then(instance => _instance = instance)
      .then(() => _instance.splitEther(accounts[1], accounts[2], {from: accounts[0], value: 2}))
      .then(
        () =>
          Promise.all([
            _instance.payeeOwed(accounts[1]),
            _instance.payeeOwed(accounts[2])
          ])
      )
      .then(
        ([owed1, owed2]) => {
          assert.equal(owed1, 1, 'payee1 is owed 1 wei');
          assert.equal(owed2, 1, 'payee2 is owed 1 wei');
        }
      )
      // ether can be withdrawn
      .then(
        () => _instance.withdrawEther({from: accounts[1]})
      )
      .then(
        () => Promise.all([
          _instance.payeeOwed(accounts[1]),
          _instance.payeeOwed(accounts[2])
        ])
      )
      .then(
        ([owed1, owed2]) => {
          assert.equal(owed1, 0, 'payee1 has been paid out');
          assert.equal(owed2, 1, 'payee2 has not been paid out');
        }
      );
  });
});
