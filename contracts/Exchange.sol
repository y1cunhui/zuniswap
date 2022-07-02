pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    address public tokenAddress;

    constructor(address _token) ERC20("ZUniswap-V1", "ZUNI1") {
        require(_token != address(0), "invalid token address");

        tokenAddress = _token;
    }

    function addLiquidity(uint256 _amount) public payable{
        IERC20 token = IERC20(tokenAddress);
        if (getReserve() == 0) {
            token.transferFrom(msg.sender, address(this), _amount);
            uint liquidity = address(this).balance;
            _mint(msg.sender, liquidity);
        } else {
            uint ethReserve = address(this).balance - msg.value;
            uint tokenReserve = getReserve();
            uint _minTokenAmount = (msg.value * tokenReserve) / ethReserve;

            require(_amount >= _minTokenAmount, "Insufficient token for liquidity");

            token.transferFrom(msg.sender, address(this), _minTokenAmount);

            uint liquidity = (totalSupply() * msg.value) / ethReserve;
            _mint(msg.sender, liquidity);
        }
        
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

    function ethToTokenSwap(
        uint _minToken
    ) public payable {
        uint tokenAmount = getAmount(
            msg.value,
            address(this).balance - msg.value, 
            getReserve()
            );
        require(tokenAmount >= _minToken, "Insufficient token amount");

        IERC20 token = IERC20(tokenAddress);
        token.transfer(msg.sender, tokenAmount);
    }

    function tokenToEthSwap(
        uint _minEth,
        uint _tokenSold
    ) public {
        uint ethAmount = getEthAmount(_tokenSold);

        require(ethAmount >= _minEth, "Insufficient eth amount");
        
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _tokenSold);
        payable(msg.sender).transfer(ethAmount);
    }

}