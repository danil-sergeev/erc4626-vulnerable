pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

interface IERC20Like is IERC20 {
  function totalSupply() external view returns (uint256);
  function burnFrom(address from, uint256 amount) external;
  function mint(address to, uint256 amount) external;
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
  function transfer(address to, uint256 amount) external returns (bool);
}

contract ERC20Mock is ERC20("MockERC20", "MOCK") {
  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

  function balances(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  function mint(address to, uint256 amount) public {
    _mint(to, amount);
  }

  function burn(address from, uint256 amount) public {
    _burn(from, amount);
  }

  function setAllowance(address from, address to, uint256 amount) public {
    _allowances[from][to] = amount;
  }
}

contract WERC20Mock is ERC20Mock {
  IERC20 public innerToken;

  constructor(IERC20 innerToken_) ERC20Mock() {
    innerToken = innerToken_;
  }

  function wrap(uint256 amount) public {
    require(amount <= innerToken.balanceOf(msg.sender));
    innerToken.transferFrom(msg.sender, address(this), amount);
    this.mint(msg.sender, amount);
  }

  function unwrap(uint256 amount) public {
    unwrapFrom(msg.sender, amount);
  }

  function unwrapFrom(address user, uint256 amount) public {
    require(amount <= this.balanceOf(user));
    this.burn(user, amount);
    innerToken.transfer(user, amount);
  }
}
