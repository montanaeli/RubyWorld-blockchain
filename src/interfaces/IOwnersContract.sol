//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IOwnersContract {
    /// @dev Returns the index of the last owner added to the list of owners
    function ownerIndex() external view returns(uint256 _ownerIndex);
    /// @dev Fee percentage charged on the sale price of each token
    function tokenSellFeePercentage() external view returns(uint256 _tokenSellFee);
    /// @dev Returns true if the _ownerAddress parameter is the address of a protocol owner. Othersie returns false
    function owners(address _ownerAddress) external view returns(bool _isOwner);
    /// @dev Returns the address of a protocol owner for the _ownerIndex received as a parameter. Othersie returns zero address
    function ownersList(uint256 _ownerIndex) external view returns(address _ownerAddress);
    /// @dev Returns the address of a contract for the _contractName received as a parameter
    function addressOf(string memory _contractName) external view returns(address _contractAddress);
    /// @dev Returns the amount of ethers that the address received by parameters can withdraw from the contract
    function balanceOf(address _ownerAddress) external view returns(uint256 _ownerBalance);
    /// @dev Add a new address as owner address in owner lists
    function addOwner(address _newOwner) external;
    /// @dev Add a new contract address to the list of contracts
    function addContract(string memory _contractName, address _contract) external;   
    /// @dev Withdraw to this contract the ethers locked in each contract for the fees charged.
    /// The amount received is divided equally among all owners currently listed on the contract and added to 
    /// the balance that each owner can withdraw
    /// @dev In the event that the Land contract does not have ethers, revert with the message "zero balance"
    function collectFeeFromContract(string memory _contractName) external;
    /// @dev Transfers, to the owner of the protocol that calls the method, the entire balance available for withdrawal
    /// on its balance. The owner balance must be zero at the end of the operation.
    /// @dev Accept requests only from EOA, otherwise revert with the message "Invalid operation for smart contracts"
    function WithdrawEarnings() external;
}