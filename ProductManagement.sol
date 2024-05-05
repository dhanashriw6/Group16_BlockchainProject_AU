// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProductManagement {
    address public owner;
    
    struct Product {
        string name;
        string productInformation;
        uint256 minPrice;
        bool auctionedProduct;
        address ProductOwner;
    }
    
    Product[] public products;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Owner access only.");
        _;
    }

    function addProduct(
        string memory _name,
        string memory _productInformation,
        uint256 _minPrice,
        address _productOwner
    ) external onlyOwner {
        products.push(Product(_name, _productInformation, _minPrice, false, _productOwner));
    }

    function getProductsLength() external view returns (uint256) {
        return products.length;
    }
    function getProductPrice(uint _pid) external view returns (uint256) {
        return products[--_pid].minPrice;
    }
    function getProductOwner(uint _id) external view returns (address){
        return products[_id].ProductOwner;
    }
    function changeProductOwnership(uint _id, address _owner) external{
        products[_id].ProductOwner = _owner;
    }
}
