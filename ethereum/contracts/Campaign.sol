pragma solidity ^0.4.17;

contract CampaignFactory{
    address[] public deployedCampaigns;
    
    function createCampaign(uint minimumContribution) public{
        address newCampaignAddress = new Campaign(minimumContribution, msg.sender);
        
        deployedCampaigns.push(newCampaignAddress);
    }
    
    function getDeployedCampaigns() public view returns(address[]){
        return deployedCampaigns;
    }
}

contract Campaign {
    
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }
    
    Request[] public requests;
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers;
    uint public approversCount;
    
    function Campaign(uint minimum,address creator) public {
        manager = creator;
        minimumContribution = minimum;
    }
    
    function contribute() public payable {
        require(msg.value > minimumContribution);
        approvers[msg.sender] = true;
        approversCount++;
    }
    
    modifier restricted(){
        require(msg.sender == manager);
        _;
    }
    
    function createRequest(string description, uint value, address recipient) public restricted{
        
        Request memory newRequest = Request({
            description:description,
            value:value,
            recipient:recipient,
            complete: false,
            approvalCount: 0
        });
        
        requests.push(newRequest);
    }
    
    function approveRequest (uint requestIndex) public {
        Request storage request = requests[requestIndex];
        
        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);
        
        request.approvals[msg.sender] = true;
        request.approvalCount++;
        
    }
    
    function finalizeRequest(uint requestIndex) public restricted{
        Request storage request = requests[requestIndex];
        
        require(request.approvalCount > (approversCount / 2));
        require(!request.complete);
        
        request.recipient.transfer(request.value);
        request.complete = true;
           
    }   
}