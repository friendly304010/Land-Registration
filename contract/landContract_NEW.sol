pragma solidity ^0.4.0;

contract MyLandContract
{
    struct Land //creates land object
    {
        address ownerAddress; //stores owner address
        string location; //physical location of property
        uint cost; //cost of property
        uint landID; //each property is uniquely identifiable
    }
    address public owner;   //address of whoever deployed the contract

    uint public totalLandsCounter; //total no of lands via this contract at any time
    
    //constructor to define who the owner is and initialize state variables
    constructor() public
    {
        owner = msg.sender;
        totalLandsCounter = 0;
    }
    
    //land addition event
    event Register(address _owner, uint _landID);
    
    //land transfer event
    event Transfer(address indexed _from, address indexed _to, uint _landID);
    
    modifier isOwner //check if function caller is owner of contract
    {
        require(msg.sender == owner);
        _;
    }
    
    //one account can hold many lands (many landTokens, each token one land)
    mapping (address => Land[]) public __ownedLands; 
    

    //1. FIRST OPERATION
    //owner adds lands with this function
    function registerLand(string _location, uint _cost) public isOwner
    {
        totalLandsCounter++; 
        Land memory myLand = Land(
            {
                ownerAddress: msg.sender,
                location: _location,
                cost: _cost,
                landID: totalLandsCounter //landID is simply the nth land added
            });
        __ownedLands[msg.sender].push(myLand);
        emit Register(msg.sender, totalLandsCounter); //notify network
    }
    
    
    //2. SECOND OPERATION
    //caller transfers land to buyer, but only if the caller is the owner of the land
    function transferLand(address _landBuyer, uint _landID) public returns (bool)
    {
        //find out the particular land ID in owner's collection
        for(uint i=0; i < __ownedLands[msg.sender].length; i++)    
        {
            //if given land ID is indeed in owner's collection
            if (__ownedLands[msg.sender][i].landID == _landID)
            {
                //copy land in new owner's collection
                Land memory myLand = Land(
                    {
                        ownerAddress:_landBuyer,
                        location: __ownedLands[msg.sender][i].location,
                        cost: __ownedLands[msg.sender][i].cost,
                        landID: _landID
                    });
                __ownedLands[_landBuyer].push(myLand);   
                
                //remove land from current ownerAddress - assigns everything to 0
                delete __ownedLands[msg.sender][i];
                emit Transfer(msg.sender, _landBuyer, _landID); //inform the network               
                return true;
            }
        }
        //if true never returned, the land is not in the owner's collection
        return false;
    }
    
    
    //3. THIRD OPERATION
    //get land details of an account to display to front end
    function getLand(address _landHolder, uint _index) public view returns (string, uint, address, uint)
    {
        return (__ownedLands[_landHolder][_index].location, 
                __ownedLands[_landHolder][_index].cost,
                __ownedLands[_landHolder][_index].ownerAddress,
                __ownedLands[_landHolder][_index].landID);
                
    }
    
    //4. GET TOTAL NUMBER OF LANDS OWNED BY AN ACCOUNT
    function getNoOfLands(address _landHolder) public view returns (uint)
    {
        return __ownedLands[_landHolder].length;
    }


}