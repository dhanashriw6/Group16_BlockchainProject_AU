// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ProductManagement.sol";
import "./BidderManagement.sol";

contract AuctionManagement {
    address public owner;

    ProductManagement public productManagement;
    BidderManagement public bidderManagement;

    struct Auction {
        address highestBidder;
        uint currentHighestBid;
        uint productToBeAuctioned;
        bool auctionStart;
        bool auctionEnd;
        uint auctionStartTime;
        uint auctionEndTime;
    }

    Auction public auction;

    constructor(address _productManagementAddress, address _bidderManagement) {
        owner = msg.sender;
        productManagement = ProductManagement(_productManagementAddress);
        bidderManagement = BidderManagement(_bidderManagement);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Owner access only.");
        _;
    }

    function startAuction(uint _productId) external onlyOwner {
        require(!auction.auctionStart, "Auction already in progress.");
        require(_productId > 0 && _productId <= productManagement.getProductsLength(), "Enter a valid product ID.");
        
        auction.productToBeAuctioned = _productId; // Not in index form.
        auction.auctionStartTime = block.timestamp;
        auction.auctionEndTime = auction.auctionStartTime + 120; // 2 minutes Auction Time
        auction.currentHighestBid = productManagement.getProductPrice(_productId);
        auction.auctionStart = true;
        auction.auctionEnd = false;
    }

    function bid() external payable {
        require(auction.auctionStart, "Auction not started.");
        require(!auction.auctionEnd, "Auction finished.");
        require(productManagement.getProductOwner(auction.productToBeAuctioned - 1) != msg.sender,"Product Owner Cannot Participate in Auction");
        if(block.timestamp < auction.auctionEndTime){

            require(bidderManagement.checkValidBidder(msg.sender), "Not a valid bidder.");
            require(msg.value > auction.currentHighestBid, "Bid must be higher than current highest bid.");
        
            auction.currentHighestBid = msg.value;
            auction.highestBidder = msg.sender;

            //BuyerFetch[msg.sender].CurrrentBid = msg.value;
            bidderManagement.setCurrentBid(msg.sender,msg.value);
            //BuyerFetch[msg.sender].TotalBid += msg.value;
            bidderManagement.setTotalBid(msg.sender,msg.value);

            // Extend auction end time if within last minute
            if (block.timestamp >= auction.auctionEndTime - 60) {
                auction.auctionEndTime += 20;
            }
            RollBackAmount();
        }
        else{
            uint amount = msg.value;
            payable(msg.sender).transfer(amount);
            // to send back the last irrelevent amount.
            auction.auctionStart = false;
            auction.auctionEnd = true;
            RevertandPayOwner();
            bidderManagement.ResetBids();
        }
    }

    function RollBackAmount() internal{
        for(uint i=0; i < bidderManagement.getNumberOfBuyers();i++){

            //uint amount = BuyerFetch[BuyerAddressList[i]].TotalBid;
            uint256 amount = bidderManagement.fetchBuyerTotalBid(i);

            if(bidderManagement.getBuyerAddress(i) == auction.highestBidder){
                amount = amount - bidderManagement.fetchBuyerCurrentBid(i);
                payable(bidderManagement.getBuyerAddress(i)).transfer(amount);
            }
            else{
                payable(bidderManagement.getBuyerAddress(i)).transfer(amount);
            }
            //BuyerFetch[BuyerAddressList[i]].TotalBid = BuyerFetch[BuyerAddressList[i]].TotalBid - amount;
            bidderManagement.ChangeTotalBid(i,amount);
        }
    }
    function RevertandPayOwner() internal{
        require(block.timestamp > auction.auctionEndTime,"Auction has not ended yet.");
        auction.auctionEnd = true; 
        auction.auctionStart = false;
        //payable(owner).transfer(auction.currentHighestBid);
        payable(productManagement.getProductOwner(auction.productToBeAuctioned - 1)).transfer(auction.currentHighestBid);
        productManagement.changeProductOwnership((auction.productToBeAuctioned - 1),auction.highestBidder);
    }

    function endAuction() external onlyOwner{
        require(auction.auctionStart, "Auction not started.");
        require(!auction.auctionEnd, "Auction already ended.");
        RevertandPayOwner();
        bidderManagement.ResetBids();
    }

    function viewWinner() external view returns (address, uint) {
        require(auction.auctionEnd, "Auction not ended.");
        return (auction.highestBidder, auction.currentHighestBid);
    }

    function getCurrentHighestBidder() external view returns (address, uint) {
        require(auction.auctionStart, "Auction not started.");
        return (auction.highestBidder, auction.currentHighestBid);
    }

    function getCurrentHighestBid() external view returns (uint) {
        require(auction.auctionStart, "Auction not started.");
        return auction.currentHighestBid;
    }

    function getAuctionStatus() external view returns (bool, bool) {
        return (auction.auctionStart, auction.auctionEnd);
    }

    function getAuctionTimeRemaining() external view returns (uint) {
        require(auction.auctionStart, "Auction not started.");
        require(!auction.auctionEnd, "Auction finished.");
        return auction.auctionEndTime - block.timestamp;
    }
}

