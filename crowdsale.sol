pragma solidity ^0.4.16;

interface token{
    function transfer (address receiver,uint amount) public;
    function getBalance(address _funderAddress) public returns (uint);
}

contract NavroICOSales {
    address public beneficiary;
    uint public amountRaised;
    uint public fundingGoalInEthersICOsale;
    uint public ICOSaleDeadlineInDays;
    uint public ICOSalePrice;

    token public tokenReward;
    mapping (address=>uint) balanceOf;
    bool fundingGoalICOsaleReached = false;
    bool ICOSaleClosed = false;
    

    event GoalReached(address _beneficiary, uint _amountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
    event Withdrawal(address _beneficiary, uint _amountRaised, uint _time);
    

    
    
    /* Constructor */
    function NavroICOSales(address _ifSuccessfulSendTo,uint _fundingGoalInWeiICOsale,
    uint _ICOSaleDeadlineInDays,uint _ICOSaleWeiCostOfEachToken,
    address _addressOfTokenUsedAsReward) public
    {
        beneficiary = _ifSuccessfulSendTo;
        fundingGoalInEthersICOsale = _fundingGoalInWeiICOsale;
        ICOSaleDeadlineInDays = now + _ICOSaleDeadlineInDays * 1 days;
        ICOSalePrice = _ICOSaleWeiCostOfEachToken;
        tokenReward = token(_addressOfTokenUsedAsReward);
    }

    function () payable{
        require(!ICOSaleClosed);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender,(amount/ICOSalePrice)*1000000000000000000);
        FundTransfer(msg.sender,amount,true);
    }

     
    modifier afterICOSalesdeadline(){
        if(now >= ICOSaleDeadlineInDays){
            _;
        }
    }

    
    function checkPreSalesGoalReached()  public afterICOSalesdeadline{
        if(amountRaised >= fundingGoalInEthersICOsale){
            fundingGoalICOsaleReached = true;
            ICOSaleClosed = true;
            GoalReached(beneficiary,amountRaised);
        }
        ICOSaleClosed = true;
    }
    

    
    function withdrawal() public{

        if(beneficiary == msg.sender){
            if(beneficiary.send(amountRaised)){
                    Withdrawal(beneficiary,amountRaised,now);
                    FundTransfer(beneficiary,amountRaised,false);
                }

        }

    }
    
    function getBalance(address _funderAddress) view  public returns (uint){
       return tokenReward.getBalance(_funderAddress);
    }
    

}