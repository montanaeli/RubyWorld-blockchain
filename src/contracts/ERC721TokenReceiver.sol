//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../interfaces/IERC721TokenReceiver.sol";

contract ERC721TokenReceiver is IERC721TokenReceiver {
    event Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes _data
    );

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    ) external returns (bytes4) {
        emit Received(_operator, _from, _tokenId, _data);
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    function isERC721TokenReceiver(address _to, uint256 _tokenId) external {
        //TODO: Check this, i change it but i'm not sure
        require(_to != address(0), "Invalid contract");
        bytes4 MAGIC_NUMBER = 0x150b7a02;
        bytes memory _data;
        bytes4 result = this.onERC721Received(
            _to,
            address(this),
            _tokenId,
            _data
        );
        require(result == MAGIC_NUMBER, "No ERC721Receiver");
    }
}
