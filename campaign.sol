pragma solidity ^0.4.17;

contract CampaignFactory{
    address[] public deployedCampaigns;
    function createCampaign(uint minimum) public{
        address newCampaign = new Campaign(minimum,msg.sender); //returns the address of a Campaign
        deployedCampaigns.push(newCampaign);
    }
    //return deployed Campaign
    function getDeployedCampaigns() public view returns(address[]){
        return deployedCampaigns;
    }
}
contract Campaign{
   address public manager;
   uint public minimumContribution;
   mapping(address => bool) public approvers;
   struct Request{
     string description;
     uint value;
     address receipient;
     bool complete;
     
     uint approvalCount;
     mapping(address =>bool) approvals;
   }
   Request[] public requests; // define the struct
   uint public approversCount;
   
   constructor(uint minimum, address creator) public {
     manager = creator;
     minimumContribution = minimum;
   }
   modifier restricted(){
       require(msg.sender == manager);
       _;
   }
   function createRequest(string description,uint value,address receipient) public restricted{
       
       Request memory newRequest = Request({
          description:description,
          value:value,
          receipient:receipient,
          complete: false,
          approvalCount:0
       });
       requests.push(newRequest);
   }
   function approveRequest(uint index) public{ //index of Request to be approved
       // make sure person calling function has donated to the contract
       // person has not approved
       // require statement return truthy valu
       
       Request storage request = requests[index];
       require(approvers[msg.sender]);  //if person is an appriver returns true
       require(!request.approvals[msg.sender]); // person has not voted on the request before
       
       requests[index].approvals[msg.sender] = true;
       requests[index].approvalCount++; // the id of approval request
   }
   // Contributing to the campaign
   function Contribute() public payable{
     require(msg.value > minimumContribution);
     
     approvers[msg.sender] = true;
     approversCount ++;
   }
   function finalizeRequest(uint index) public restricted{
       Request storage request = requests[index];
       // if the request has enough approvals
       // 50% of people have to vote yes to the campaign
       require(request.approversCount >(approversCount / 2));
       require(!request.complete); // if requests at given index is complete or has been uproved
       
       // if the request is approved and has the correct numbers of approvers
       request.complete= true;
       request.receipient.transfer(request.value);
       
       
   }
}

