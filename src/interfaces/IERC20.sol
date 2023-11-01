//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IERC20 {
    function name() external view returns (string memory _name);

    function symbol() external view returns (string memory _symbol);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function decimals() external view returns (uint256 _decimals);

    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256 _amount);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);

    function approve(address _spender, uint256 _value) external;

    function price() external view returns (uint256 _price);

    function buy(uint256 _amount) external payable;

    function setPrice(uint256 _price) external;
}
