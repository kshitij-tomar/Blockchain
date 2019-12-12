pragma solidity ^0.5.11;
contract CarChain
{   
    
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    //stores the address of the host and is set at the time of creation of the contract
    address private host;

    
    //This mapping only stores the list of addressed allowed to make changes to the history of cars
    mapping (address => uint256) private _authorizedDealers;
    //This mapping stores the actual history, it maps from string which is the unique key(VIN) for every car
    //It stores it as a mapping from int to the struct created below
    //The int is used as the key so as to iterate over all results when sending to user requesting car info
    mapping (string => mapping (uint256 => CarInfo)) private _carHistory;
    //This mapping stores the size of history of every car
    mapping (string => uint256) private historySize;
    //this struct stores the history report of every updater
    //updater stores the address of the approved user making the updater
    //Info stores the info sent as a string(This can be configured to store jsons)
    struct CarInfo{
        address updater;
        string info ;
    }
    constructor() public
    {   
        //set host
        host=msg.sender;
    }
    
    function addAuthorizedDealer(address auth) public payable returns (string memory)
    {   
        //Let only hosts add authorized Dealers
        require(msg.sender==host);
        _authorizedDealers[auth]=1;
    }
    //add history records for the given car
    function addHistory(string memory car,string memory jsonReport) public payable returns (string memory)
    {   
        //ensures only authorized Dealers add to car histories
        require(_authorizedDealers[msg.sender]==1);
        uint256 index=historySize[car];
        CarInfo memory newHistory;
        newHistory.updater=msg.sender;
        newHistory.info=jsonReport;
        _carHistory[car][index]=newHistory;
        historySize[car]=historySize[car]+1;
        return "success";
    }
    //This returns the first history record which will be the registration
    function getRegistrationHistory(string memory car) public view returns (string memory)
    {
    
        return _carHistory[car][0].info;
    }
    //This returns all the histories for the recorded car as a comma seperated string
    function getAllHistory(string memory car) public view returns (string memory)
    {   
        require(historySize[car]>=1);
        uint256 size=historySize[car];
        string memory allHistory="";
        for(uint256 i=0;i<size;i++)
        {
            allHistory=string(abi.encodePacked(allHistory,_carHistory[car][i].info,", "));
        }
        return allHistory;
    }
}