// SPDX-License-Identifier: MIT  

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}


contract DriveThrough{
    struct Ticket{
        address payable owner;
        string ticketNumber;
        string category;
        uint price;
        bool booked;
    }
  
    using SafeMath for uint;


    address internal cUsdTokenAddress ;
    address internal adminAddress; // replace with your own address

    uint ticketLength = 0;
    mapping(uint => Ticket) public tickets;

    
    // check if user is admin
    modifier isAdmin(){
        require(msg.sender == adminAddress,"Only the admin can access this");
        _;
    }

    // check user is not an admin
    modifier notAdmin(){
         require(msg.sender != adminAddress,"Cannot be admin");
        _;
    }

     constructor(){
        adminAddress = msg.sender;
        cUsdTokenAddress =  0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    }
    
    // function to add ticket
    function addTicket(
        string memory _ticketNo,
        string memory _category, 
        uint _price       
    )public isAdmin {
        Ticket storage _tickets = tickets[ticketLength];
        _tickets.owner = payable(msg.sender);
        _tickets.ticketNumber = _ticketNo;
        _tickets.category = _category;
        _tickets.price = _price;
        _tickets.booked = false;

        ticketLength.add(1);
    }
    
    // function to update ticket
    function updateTicket(
        uint _ticketId,
          string memory _ticketNo,
        string memory _category, 
        uint _price       
    ) public isAdmin {
         Ticket storage _tickets = tickets[_ticketId];
        _tickets.ticketNumber = _ticketNo;
        _tickets.category = _category;
        _tickets.price = _price;
    }
 
    // buy or book a ticket
    function bookTicket(uint _index) notAdmin public {
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                    msg.sender,
                    tickets[_index].owner,
                    tickets[_index].price
            ),
            "Transaction could not be performed"
        );
        // change ownership
        tickets[_index].owner = payable(msg.sender);
        tickets[_index].booked = true;
    }
    
    // revoke ticket without refunding the user
    function revokeTicket(uint _index)  public{

        Ticket storage _tickets = tickets[_index];
        require(_tickets.owner == msg.sender || msg.sender == adminAddress, "Only the owner of this ticket can call this");
        tickets[_index].booked = false;
    }

    // change the admin
    function revokeOwnership(address _address) isAdmin public{
        adminAddress = _address;
    }
    
    // check if user is an admin
    function isUserAdmin(address _address) public view returns (bool){
        if(_address == adminAddress){
            return true;
        }
        return false;   
    } 
    
    // get total ticket count
    function getTicketLength() public view returns (uint) {
        return (ticketLength);
    }
}
