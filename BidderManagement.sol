// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BidderManagement {
    struct Bidder {
        string name;
        bool validBidder;
        uint currentBid;
        uint totalBid;
    }
    address Owner;
    mapping(address => Bidder) public buyers;
    address[] public BuyerAddressList;

    constructor() {
        Owner = msg.sender;
    }

    function setBidder(string memory _name) external {
        require(msg.sender != Owner,"Owner cannot register as Buyer.");
        require(!buyers[msg.sender].validBidder, "Bidder cannot register themselves again.");
        buyers[msg.sender] = Bidder(_name, true, 0, 0);
        BuyerAddressList.push(msg.sender); 
    }

    function checkValidBidder(address _buyer) external view returns(bool){
        return (buyers[_buyer].validBidder);
    }
    function getBuyerAddress(uint _index) external view returns(address){
        return (BuyerAddressList[_index]);
    }
    function getNumberOfBuyers() external view returns(uint256){
        return (BuyerAddressList.length);
    }
    function setCurrentBid(address _bidderAddress, uint256 _value) external{
        buyers[_bidderAddress].currentBid = _value;
    }
    function setTotalBid(address _bidderAddress, uint256 _value) external{
        buyers[_bidderAddress].totalBid = buyers[_bidderAddress].totalBid + _value;
    }
    function getCurrentBid(address _bidderAddress) internal view returns(uint256){
        return (buyers[_bidderAddress].currentBid);
    }
    function getTotalBid(address _bidderAddress) internal view returns(uint256){
        return (buyers[_bidderAddress].totalBid);
    }
    function fetchBuyerTotalBid(uint _index) external view returns(uint256){
        return (getTotalBid(BuyerAddressList[_index]));
    }
    function fetchBuyerCurrentBid(uint _index) external view returns(uint256){
        return (getCurrentBid(BuyerAddressList[_index]));
    }
    function ChangeTotalBid(uint _index, uint256 _amount) external{
        buyers[BuyerAddressList[_index]].totalBid = buyers[BuyerAddressList[_index]].totalBid - _amount ;
    }
    function ResetBids() external{
        for(uint i=0; i < BuyerAddressList.length;i++){
            buyers[BuyerAddressList[i]].currentBid = 0;
            buyers[BuyerAddressList[i]].totalBid = 0;
        }
    }
}
