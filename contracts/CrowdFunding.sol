// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

contract CrowdFunding {

    // this struct defines what a campaign should have
    struct Campaign {
        string title;
        string description;
        address benefactor;
        uint256 goal;
        uint256 deadline;
        uint256 amountRaised;
        bool ended;
        uint256 id;
    }

    // this is an event to be emited when the campaign is created

    event CampaignCreated(
        string title,
        string description,
        address benefactor,
        uint256 goal,
        uint256 deadline,
        uint256 campaignId
    );


// i will emit this later in the code when donation is received

    event DonationReceived(address sender, uint256 amount, uint256 campaignId);

    // i will be emitting this event when the campaigns ends
    event CampaignEnded(uint256 campaignId);

    // this is a state variable to hold the address of the owner
    address owner;

    // this is the array to hold all the campaigns
    Campaign[] public campaigns;
    // this is a mapping to hold benefactor of each address and their campaign index
    mapping(address => uint256) public addressToCampaign;

// this would run only when the contract is being deployed
    constructor() {
        owner = msg.sender;
    }

    // this function created a campaign by retriening the requried information as arguments from the function

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _goal,
        uint256 _deadline
    ) public payable onlyOwner {

        // her i check if the 

        require(
            _deadline > block.timestamp,
            "Campaign deadline cannot be in the past"
        );
        require(_goal > 0.1 ether, "Campaign goal must be at least 1 ETH");

        uint256 deadline = block.timestamp + _deadline;

        campaigns.push(
            Campaign({
                title: _title,
                goal: _goal,
                deadline: deadline,
                amountRaised: 0,
                ended: false,
                id: campaigns.length + 1,
                description: _description,
                benefactor: msg.sender
            })
        );

        addressToCampaign[msg.sender] = campaigns.length;

        emit CampaignCreated(
            _title,
            _description,
            msg.sender,
            _goal,
            _deadline,
            campaigns.length + 1
        );
    }

    function donateToCampaign(uint256 campaignId) public payable {
        require(msg.value >= 0.1 ether, "Minimum amount to donate is 0.1 ETH");
        require(
            campaigns[campaignId - 1].deadline > block.timestamp,
            "Campaign Has Ended"
        );
        require(
            campaigns[campaignId - 1].amountRaised + msg.value <
                campaigns[campaignId].goal,
            "Campaign goal already reached"
        );
        require(campaigns[campaignId].ended == false, "Campaign is ended");

        Campaign storage campaign = campaigns[campaignId - 1];
        campaign.amountRaised += msg.value;
        emit DonationReceived(msg.sender, msg.value, campaignId);
    }

    function endCampaign(uint256 campaignId) public payable {
        Campaign memory campaign;
        campaign = campaigns[campaignId - 1];

        require(
            campaigns[campaignId - 1].benefactor == msg.sender,
            "Not the owner"
        );

        campaign.ended = true;
        payable(campaign.benefactor).transfer(campaign.amountRaised);

        emit CampaignEnded(campaignId);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        return campaigns;
    }

    function getSingleCampaign(uint256 campaignId)
        public
        view
        returns (Campaign memory)
    {
        return campaigns[campaignId - 1];
    }
}
