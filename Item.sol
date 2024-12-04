pragma solidity ^0.4.24;

import "./ERC721.sol";

contract Item is ERC721{
    
    struct GameItem{
        string name; // Name of the Item
        uint level; // Item Level
        uint rarityLevel;  // 1 = normal, 2 = rare, 3 = epic, 4 = legendary
    }
    
    struct MarketItem {
        address seller; // 卖家地址
        uint price; // 价格
    }

    GameItem[] public items; // First Item has Index 0
    address public owner;
    // uint256 public constant PRICE = 0.1 ether; // 每个NFT的价格
    mapping(address => bool) public whiteList; // 白名单映射
    bool public mintingActive = false; // 是否允许铸造
    mapping(uint => MarketItem) public marketItems; // 市场中的NFT映射
    
    constructor () public {
        owner = msg.sender; // The Sender is the Owner; Ethereum Address of the Owner
    }
    
    function createItem(string _name, address _to) public{
        require(owner == msg.sender); // Only the Owner can create Items
        uint id = items.length; // Item ID = Length of the Array Items
        items.push(GameItem(_name,5,1)); // Item ("Sword",5,1)
        _mint(_to,id); // Assigns the Token to the Ethereum Address that is specified
    }

    
    
    function changeOwner(address newOwner) public {
        require(msg.sender == owner);
        require(newOwner != address(0));
        require(newOwner != address(this));
        // 检查一个地址是否是合约地址（是合约地址就不能作为外部账户地址）
        require(!isContract(newOwner));

        owner = newOwner;
    }

    function batchMintByOwner(address[] users, uint[] tokenIds) public{
        require(msg.sender == owner);
        require(users.length == tokenIds.length);
        for(uint i = 0; i < users.length; i++) {
            _mint(users[i], tokenIds[i]);
        }
    }


    // 用户购买NFT的方法
    function buyItem(uint _tokenId) public payable {
        require(_exists(_tokenId), "Item does not exist.");
        require(ownerOf(_tokenId) != msg.sender, "You already own this Item.");
        MarketItem storage item = marketItems[_tokenId];
        require(item.price > 0, "Item is not for sale.");
        require(msg.value >= item.price, "Insufficient funds to purchase the item.");

        address seller = item.seller;
        uint price = item.price;

        // 转移NFT所有权
        transferFrom(seller, msg.sender, _tokenId);

        // 清除市场信息
        delete marketItems[_tokenId];

        // 将资金转给卖家
        seller.transfer(price);
    }

    // 列出NFT到市场
    function listForSale(uint _tokenId, uint _price) public {
        require(_exists(_tokenId), "Token does not exist.");
        require(ownerOf(_tokenId) == msg.sender, "You do not own this token.");
        require(_price > 0, "Price must be greater than 0.");

        marketItems[_tokenId] = MarketItem({
            seller: msg.sender,
            price: _price
        });
    }

    // 取消市场上的NFT
    function cancelListing(uint _tokenId) public {
        require(_exists(_tokenId), "Token does not exist.");
        require(marketItems[_tokenId].seller == msg.sender, "You are not the seller of this token.");

        delete marketItems[_tokenId];
    }

    // 白名单用户自己铸造NFT
    function mintByWhiteList(string name, uint level, uint rarityLevel) public{
        require(mintingActive, "Minting is not active.");
        require(whiteList[msg.sender], "You are not on the whitelist.");

        uint id = items.length; // 新物品的ID就是当前数组长度
        items.push(GameItem(name, level, rarityLevel)); // 添加新物品到数组中
        _mint(msg.sender, id); // 将新生成的NFT分配给调用者
    }  
    // ower添加白名单
    function addWhiteList(address[] users) public{
        require(msg.sender == owner, "Only the owner can add to the whitelist.");
        for (uint i = 0; i < users.length; i++) {
            whiteList[users[i]] = true;
        }
    }
    // ower删除白名单
    function removeWhiteList(address[] users) public{
        require(msg.sender == owner, "Only the owner can remove from the whitelist.");
        for (uint i = 0; i < users.length; i++) {
            whiteList[users[i]] = false;
        }
    }   

    // 合约所有者可以激活或禁用铸造
    function setMintingStatus(bool _status) public {
        require(msg.sender == owner, "Only the owner can change the minting status.");
        mintingActive = _status;
    }

    function owner(address user) public view returns (uint[]){
        
    
    }
    

}