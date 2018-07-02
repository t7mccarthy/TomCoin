pragma solidity ^0.4.22;

import "./ConvertLib.sol";

// This is just a simple example of a coin-like contract.
// It is not standards compatible and cannot be expected to talk to other
// coin/token contracts. If you want to create a standards-compliant
// token, see: https://github.com/ConsenSys/Tokens. Cheers!

contract SafeMath {

  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

}

contract ERC20 {
    //function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    //function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    //function approve(address spender, uint tokens) public returns (bool success);
    //function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    //event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    address public manager;
}

contract TomCoin is ERC20, SafeMath {
	uint256 public totalSupply;

	mapping (address => uint) balances;

	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	constructor() public {
		balances[tx.origin] = 10000;
		balances[manager] = 80000;
	}

	function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
		if (balances[msg.sender] < amount) return false;
		balances[msg.sender] -= amount;
		balances[receiver] += amount;
		emit Transfer(msg.sender, receiver, amount);
		return true;
	}

	function balanceOfInEth(address _address) public view returns(uint){
		return ConvertLib.convert(balanceOf(_address),2);
	}

	function balanceOf(address _address) public view returns(uint) {
		return balances[_address];
	}

  function transfer(address _to, uint256 _value) returns(bool success){
    require(_to != address(0));
		balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    emit Transfer(msg.sender, _to, _value);

    return true;
	}

  struct Withdrawal {
    uint256 tokens;
    uint256 time;
  }

  struct Price {
    uint256 numerator;
    uint256 denominator;
  }

	address public manager = 0x56c56111F9E7322D9170816a3366781fdf38a0Da;


  mapping (address => Withdrawal) public withdrawals;
  mapping (uint256 => Price) public prices;

	function requestWithdrawal(address _participant, uint _tokensToWithdraw){
		require(balanceOf(_participant) >= _tokensToWithdraw);
		require(withdrawals[_participant].tokens == 0);
		balances[_participant] = safeSub(balances[_participant], _tokensToWithdraw);
		withdrawals[_participant] = Withdrawal({tokens: _tokensToWithdraw, time: now});
    withdraw(_participant);
	}

	Price public currentPrice;

  /* function checkEthValue(uint256 amountTokensToWithdraw) returns (uint256 ethervalue) {
		currentPrice.numerator = 2;
		currentPrice.denominator = 1;
    //require(amountTokensToWithdraw > 0 );
    //require(balanceOf(msg.sender) >= amountTokensToWithdraw);
    //uint256 etherValue = safeMul(amountTokensToWithdraw, currentPrice.denominator) / currentPrice.numerator;
    //require(manager.balance >= withdrawValue);
    return 0;
  } */

  function withdraw(address participant) {
    currentPrice.numerator = 2;
		currentPrice.denominator = 1;
    //address participant = msg.sender;
    uint256 tokens = withdrawals[participant].tokens;
		//require(tokens > 0);
		uint256 requestTime = withdrawals[participant].time;
		//Price price = prices[requestTime];
		uint256 ethValue = safeMul(tokens, currentPrice.denominator)/(currentPrice.numerator);
    //require(currentPrice.numerator > 0);
		withdrawals[participant].tokens = 0;
		if (manager.balance >= ethValue){
			withdraw_from_balance(participant, ethValue, tokens);
		}
		else {
			withdraw_error(participant, ethValue, tokens);
		}
	}

	function withdraw_from_balance(address _participant, uint256 _ethValue, uint256 _tokens) private{
		balances[manager] = safeAdd(balances[manager], _tokens);
		_participant.transfer(_ethValue);

	}

	function withdraw_error(address _participant, uint256 _ethValue, uint256 _tokens) private{
		balances[_participant] = safeAdd(balances[_participant], _tokens);
	}

  function transfer_to_contract() payable returns(bool success){
      return true;
  }

  function () payable {}
}
