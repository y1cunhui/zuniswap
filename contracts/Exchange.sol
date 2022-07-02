pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Exchange {
    address public tokenAddress;

    constructor(address _token) {
        require(_token != address(0), "invalid token address");

        tokenAddress = _token;
    }

    function addLiquidity(uint256 _amount) public payable{
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function getReserve() public view returns(uint) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function getPrice(uint inReserve, uint outReserve) 
        public
        pure
        returns(uint) {
        require(inReserve > 0 && outReserve > 0, "Invalid Reserve");

        return (inReserve*1000) / outReserve ;
    }

    function getAmount(
        uint inputAmount,
        uint inputReserve, 
        uint outputReserve
    ) private pure returns(uint) {
        require(inputReserve > 0 && outputReserve > 0, "Invalid Reserve");
        
        return (inputAmount * outputReserve) / (inputReserve + inputAmount);
    }

    function getTokenAmount(
        uint _ethSold
    ) public view returns(uint) {
        require(_ethSold > 0, "Invalid Amount");

        return getAmount(_ethSold, address(this).balance, getReserve());
    }

    function getEthAmount(
        uint _tokenSold
    ) public view returns(uint) {
        require(_tokenSold > 0, "Invalid Amount");

        return getAmount(_tokenSold, getReserve(), address(this).balance);
    }

}