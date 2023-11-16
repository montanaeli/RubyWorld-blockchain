//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../interfaces/IERC721TokenReceiver.sol";

contract ERC721TokenReceiver is IERC721TokenReceiver {
    modifier isSmartContract(address _address) {
        require(_address.code.length > 0, "Invalid contract");
        _;
    }

    function isERC721_TokenReceiver(
        address _address,
        uint256 _tokenId
    ) private isSmartContract(_address) {
        bytes4 ERC721_TokenReceiver_Hash = 0x150b7a02;
        bytes memory _data;
        bytes4 ERC721Received_result = this.onERC721Received(
            address(this),
            msg.sender,
            _tokenId,
            _data
        );
        if (ERC721Received_result != ERC721_TokenReceiver_Hash) {
            revert("No ERC721Receiver");
        }
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    ) external returns (bytes4) {
        isERC721_TokenReceiver(_operator, _tokenId);
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }
}
