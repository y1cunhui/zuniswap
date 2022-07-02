pragma solidity ^0.8.0;

import "./Exchange.sol";

contract Factory {
    mapping(address => address) tokenToExchange;

    function createExchange(address _token) public returns(address) {
        require(_token != address(0), "Invalid token address");
        require(tokenToExchange[_token] == address(0),
            "Exchange already registered."
        );
        Exchange exchange = new Exchange(_token);

        tokenToExchange[_token] = address(exchange);

        return address(exchange);
    }

    function getExchange(address _token) public view returns(address) {
        return tokenToExchange[_token];
    }
}