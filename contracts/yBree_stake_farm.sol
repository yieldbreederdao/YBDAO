
pragma solidity ^0.6.0;

import "./Owned.sol";
import "./yBree.sol";
import "./ERC20contract.sol";
import "./SafeMath.sol";

contract ybree_STAKE_FARM is Owned{
    
    using SafeMath for uint256;
    
    uint256 public yieldCollectionFee = 0.1 ether;
    uint256 public stakingPeriod = 30 days;
    uint256 public stakeClaimFee = 0.01 ether;
    uint256 public totalYield;
    uint256 public totalRewards;
    uint256 public totalLockedStaking;
    
    Token public ybree;
    
    struct Tokens{
        bool exists;
        uint256 rate;
    }
    
    mapping(address => Tokens) public tokens;
    address[] TokensAddresses;
    
    struct DepositedToken{
        bool    whitelisted;
        uint256 activeDeposit;
        uint256 totalDeposits;
        uint256 startTime;
        uint256 pendingGains;
        uint256 lastClaimedDate;
        uint256 totalGained;
        uint    rate;
        uint    period;
    }
    
    mapping(address => mapping(address => DepositedToken)) public users;
    
    event TokenAdded(address tokenAddress, uint256 APY);
    event TokenRemoved(address tokenAddress);
    event FarmingRateChanged(address tokenAddress, uint256 newAPY);
    event YieldCollectionFeeChanged(uint256 yieldCollectionFee);
    event FarmingStarted(address _tokenAddress, uint256 _amount);
    event YieldCollected(address _tokenAddress, uint256 _yield);
    event AddedToExistingFarm(address _tokenAddress, uint256 tokens);
    
    event Staked(address staker, uint256 tokens);
    event AddedToExistingStake(uint256 tokens);
    event StakingRateChanged(uint256 newAPY);
    event TokensClaimed(address claimer, uint256 stakedTokens);
    event RewardClaimed(address claimer, uint256 reward);
    
    
    
    constructor(address _tokenAddress) public {
        ybree = Token(_tokenAddress);
        
        // add ybree token to ecosystem
        _addToken(_tokenAddress, 300); // 40 apy initially
    }
    
    //#########################################################################################################################################################//
    //####################################################FARMING EXTERNAL FUNCTIONS###########################################################################//
    //#########################################################################################################################################################// 
    
    // ------------------------------------------------------------------------
    // Add assets to farm
    // @param _tokenAddress address of the token asset
    // @param _amount amount of tokens to deposit
    // ------------------------------------------------------------------------
    function FARM(address _tokenAddress, uint256 _amount) external{
        require(_tokenAddress != address(ybree), "Use staking instead"); 
        
        // add to farm
        _newDeposit(_tokenAddress, _amount);
        
        // transfer tokens from user to the contract balance
        require(ERC20Interface(_tokenAddress).transferFrom(msg.sender, address(this), _amount));
        
        emit FarmingStarted(_tokenAddress, _amount);
    }
    
    // ------------------------------------------------------------------------
    // Add more deposits to already running farm
    // @param _tokenAddress address of the token asset
    // @param _amount amount of tokens to deposit
    // ------------------------------------------------------------------------
    function addToFarm(address _tokenAddress, uint256 _amount) external{
        require(_tokenAddress != address(ybree), "use staking instead");
        _addToExisting(_tokenAddress, _amount);
        
        // move the tokens from the caller to the contract address
        require(ERC20Interface(_tokenAddress).transferFrom(msg.sender,address(this), _amount));
        
        emit AddedToExistingFarm(_tokenAddress, _amount);
    }
    
    // ------------------------------------------------------------------------
    // Withdraw accumulated yield
    // @param _tokenAddress address of the token asset
    // @required must pay yield claim fee
    // ------------------------------------------------------------------------
    function YIELD(address _tokenAddress) external payable {
        require(msg.value >= yieldCollectionFee, "should pay exact claim fee");
        require(pendingYield(_tokenAddress, msg.sender) > 0, "No pending yield");
        require(tokens[_tokenAddress].exists, "Token doesn't exist");
         require(_tokenAddress != address(ybree), "use staking instead");
        uint256 _pendingYield = pendingYield(_tokenAddress, msg.sender);
        
        // Global stats update
        totalYield = totalYield.add(_pendingYield);
        
        // update the record
        users[msg.sender][_tokenAddress].totalGained = users[msg.sender][_tokenAddress].totalGained.add(pendingYield(_tokenAddress, msg.sender));
        users[msg.sender][_tokenAddress].lastClaimedDate = now;
        users[msg.sender][_tokenAddress].pendingGains = 0;
        
        // transfer fee to the owner
        owner.transfer(msg.value);
        
        // mint more tokens inside token contract equivalent to _pendingYield
        require(ybree.mintTokens(_pendingYield, msg.sender));
        
        emit YieldCollected(_tokenAddress, _pendingYield);
    }
    
    // ------------------------------------------------------------------------
    // Withdraw any amount of tokens, the contract will update the farming 
    // @param _tokenAddress address of the token asset
    // @param _amount amount of tokens to deposit
    // ------------------------------------------------------------------------
    function withdrawFarmedTokens(address _tokenAddress, uint256 _amount) external {
         require(users[msg.sender][_tokenAddress].activeDeposit >= _amount, "insufficient amount in farming");
        require(_tokenAddress != address(ybree), "use withdraw of staking instead");
        
        // update farming stats
            // check if we have any pending yield, add it to previousYield var
            users[msg.sender][_tokenAddress].pendingGains = pendingYield(_tokenAddress, msg.sender);
            // update amount 
            users[msg.sender][_tokenAddress].activeDeposit = users[msg.sender][_tokenAddress].activeDeposit.sub(_amount);
            // update farming start time -- new farming will begin from this time onwards
            users[msg.sender][_tokenAddress].startTime = now;
            // reset last claimed figure as well -- new farming will begin from this time onwards
            users[msg.sender][_tokenAddress].lastClaimedDate = now;
        
        // withdraw the tokens and move from contract to the caller
        require(ERC20Interface(_tokenAddress).transfer(msg.sender, _amount));
        
        emit TokensClaimed(msg.sender, _amount);
    }
    
    //#########################################################################################################################################################//
    //####################################################STAKING EXTERNAL FUNCTIONS###########################################################################//
    //#########################################################################################################################################################//    
    
    // ------------------------------------------------------------------------
    // Start staking
    // @param _tokenAddress address of the token asset
    // @param _amount amount of tokens to deposit
    // ------------------------------------------------------------------------
    function STAKE(uint256 _amount) external  {
        // add new stake
        _newDeposit(address(ybree), _amount);
        totalLockedStaking=totalLockedStaking.add(_amount);
        // transfer tokens from user to the contract balance
        require(ybree.transferFrom(msg.sender, address(this), _amount));
        
        emit Staked(msg.sender, _amount);
        
    }
    
    // ------------------------------------------------------------------------
    // Add more deposits to already running farm
    // @param _tokenAddress address of the token asset
    // @param _amount amount of tokens to deposit
    // ------------------------------------------------------------------------
    function addToStake(uint256 _amount) external {
        require(now - users[msg.sender][address(ybree)].startTime < users[msg.sender][address(ybree)].period, "current staking expired");
        _addToExisting(address(ybree), _amount);
         totalLockedStaking=totalLockedStaking.add(_amount);

        // move the tokens from the caller to the contract address
        require(ybree.transferFrom(msg.sender,address(this), _amount));
        
        emit AddedToExistingStake(_amount);
    }
    
    // ------------------------------------------------------------------------
    // Claim reward and staked tokens
    // @required user must be a staker
    // @required must be claimable
    // ------------------------------------------------------------------------
    function ClaimStakedTokens() external {
         //require(users[msg.sender][address(ybree)].running, "no running stake");
        require(users[msg.sender][address(ybree)].activeDeposit > 0, "no running stake");
        require(users[msg.sender][address(ybree)].startTime.add(users[msg.sender][address(ybree)].period) < now, "not claimable before staking period");
        
        uint256 _currentDeposit = users[msg.sender][address(ybree)].activeDeposit;
        
        // check if we have any pending reward, add it to pendingGains var
        users[msg.sender][address(ybree)].pendingGains = pendingReward(msg.sender);
        // update amount 
        users[msg.sender][address(ybree)].activeDeposit = 0;
        
        // transfer staked tokens
        require(ybree.transfer(msg.sender, _currentDeposit));
        
        emit TokensClaimed(msg.sender, _currentDeposit);
        
    }
    
    // ------------------------------------------------------------------------
    // Claim reward and staked tokens
    // @required user must be a staker
    // @required must be claimable
    // ------------------------------------------------------------------------
    function ClaimReward() external payable {
         require(msg.value >= stakeClaimFee, "should pay exact claim fee");
        require(pendingReward(msg.sender) > 0, "nothing pending to claim");
    
        uint256 _pendingReward = pendingReward(msg.sender);
        
        // add claimed reward to global stats
        totalRewards = totalRewards.add(_pendingReward);
        // add the reward to total claimed rewards
        users[msg.sender][address(ybree)].totalGained = users[msg.sender][address(ybree)].totalGained.add(_pendingReward);
        // update lastClaim amount
        users[msg.sender][address(ybree)].lastClaimedDate = now;
        // reset previous rewards
        users[msg.sender][address(ybree)].pendingGains = 0;
        
        // transfer the claim fee to the owner
        owner.transfer(msg.value);
        
        // mint more tokens inside token contract
        require(ybree.mintTokens(_pendingReward, msg.sender));
         
        emit RewardClaimed(msg.sender, _pendingReward);
    }
    
    //#########################################################################################################################################################//
    //##########################################################FARMING QUERIES################################################################################//
    //#########################################################################################################################################################//
    
    // ------------------------------------------------------------------------
    // Query to get the pending yield
    // @param _tokenAddress address of the token asset
    // ------------------------------------------------------------------------
    function pendingYield(address _tokenAddress, address _caller) public view returns(uint256 _pendingRewardWeis){
        uint256 _totalFarmingTime = now.sub(users[_caller][_tokenAddress].lastClaimedDate);
        
        uint256 _reward_token_second = ((tokens[_tokenAddress].rate).mul(10 ** 21)).div(365 days); // added extra 10^21
        
        uint256 yield = ((users[_caller][_tokenAddress].activeDeposit).mul(_totalFarmingTime.mul(_reward_token_second))).div(10 ** 27); // remove extra 10^21 // 10^2 are for 100 (%)
        
        return yield.add(users[_caller][_tokenAddress].pendingGains);
    }
    
    // ------------------------------------------------------------------------
    // Query to get the active farm of the user
    // @param farming asset/ token address
    // ------------------------------------------------------------------------
    function activeFarmDeposit(address _tokenAddress, address _user) external view returns(uint256 _activeDeposit){
        return users[_user][_tokenAddress].activeDeposit;
    }
    
    // ------------------------------------------------------------------------
    // Query to get the total farming of the user
    // @param farming asset/ token address
    // ------------------------------------------------------------------------
    function yourTotalFarmingTillToday(address _tokenAddress, address _user) external view returns(uint256 _totalFarming){
        return users[_user][_tokenAddress].totalDeposits;
    }
    
    // ------------------------------------------------------------------------
    // Query to get the time of last farming of user
    // ------------------------------------------------------------------------
    function lastFarmedOn(address _tokenAddress, address _user) external view returns(uint256 _unixLastFarmedTime){
        return users[_user][_tokenAddress].startTime;
    }
    
    // ------------------------------------------------------------------------
    // Query to get total earned rewards from particular farming
    // @param farming asset/ token address
    // ------------------------------------------------------------------------
    function totalFarmingRewards(address _tokenAddress, address _user) external view returns(uint256 _totalEarned){
        return users[_user][_tokenAddress].totalGained;
    }
    
    //#########################################################################################################################################################//
    //####################################################FARMING ONLY OWNER FUNCTIONS#########################################################################//
    //#########################################################################################################################################################//
    
    // ------------------------------------------------------------------------
    // Add supported tokens
    // @param _tokenAddress address of the token asset
    // @param _farmingRate rate applied for farming yield to produce
    // @required only owner 
    // ------------------------------------------------------------------------    
    function addToken(address _tokenAddress, uint256 _rate) external onlyOwner {
        _addToken(_tokenAddress, _rate);
    }
    
    // ------------------------------------------------------------------------
    // Remove tokens if no longer supported
    // @param _tokenAddress address of the token asset
    // @required only owner 
    // ------------------------------------------------------------------------  
    function removeToken(address _tokenAddress) external onlyOwner {
        
        require(tokens[_tokenAddress].exists, "token doesn't exist");
        
        tokens[_tokenAddress].exists = false;
        
        emit TokenRemoved(_tokenAddress);
    }
    
    // ------------------------------------------------------------------------
    // Change farming rate of the supported token
    // @param _tokenAddress address of the token asset
    // @param _newFarmingRate new rate applied for farming yield to produce
    // @required only owner 
    // ------------------------------------------------------------------------  
    function changeFarmingRate(address _tokenAddress, uint256 _newFarmingRate) external onlyOwner {
        
        require(tokens[_tokenAddress].exists, "token doesn't exist");
        
        tokens[_tokenAddress].rate = _newFarmingRate;
        
        emit FarmingRateChanged(_tokenAddress, _newFarmingRate);
    }

    // ------------------------------------------------------------------------
    // Change Yield collection fee
    // @param _fee fee to claim the yield
    // @required only owner 
    // ------------------------------------------------------------------------     
    function setYieldCollectionFee(uint256 _fee) public onlyOwner{
        yieldCollectionFee = _fee;
        emit YieldCollectionFeeChanged(_fee);
    }
    
    //#########################################################################################################################################################//
    //####################################################STAKING QUERIES######################################################################################//
    //#########################################################################################################################################################//
    
    // ------------------------------------------------------------------------
    // Query to get the pending reward
    // ------------------------------------------------------------------------
    function pendingReward(address _caller) public view returns(uint256 _pendingReward){
         uint256 _totalStakedTime = 0;
        uint256 expiryDate = (users[_caller][address(ybree)].period).add(users[_caller][address(ybree)].startTime);
        
        if(now < expiryDate)
            _totalStakedTime = now.sub(users[_caller][address(ybree)].lastClaimedDate);
        else{
            if(users[_caller][address(ybree)].lastClaimedDate >= expiryDate) // if claimed after expirydate already
                _totalStakedTime = 0;
            else
                _totalStakedTime = expiryDate.sub(users[_caller][address(ybree)].lastClaimedDate);
        }
            
        uint256 _reward_token_second = ((users[_caller][address(ybree)].rate).mul(10 ** 21)); // added extra 10^21
        uint256 reward =  ((users[_caller][address(ybree)].activeDeposit).mul(_totalStakedTime.mul(_reward_token_second))).div(10 ** 27); // remove extra 10^21 // the two extra 10^2 is for 100 (%) // another two extra 10^4 is for decimals to be allowed
        reward = reward.div(365 days);
        return (reward.add(users[_caller][address(ybree)].pendingGains));
    }
    
    // ------------------------------------------------------------------------
    // Query to get the active stake of the user
    // ------------------------------------------------------------------------
    function yourActiveStake(address _user) external view returns(uint256 _activeStake){
        return users[_user][address(ybree)].activeDeposit;
    }
    
    // ------------------------------------------------------------------------
    // Query to get the total stakes of the user
    // ------------------------------------------------------------------------
    function yourTotalStakesTillToday(address _user) external view returns(uint256 _totalStakes){
        return users[_user][address(ybree)].totalDeposits;
    }
    
    // ------------------------------------------------------------------------
    // Query to get the time of last stake of user
    // ------------------------------------------------------------------------
    function lastStakedOn(address _user) public view returns(uint256 _unixLastStakedTime){
        return users[_user][address(ybree)].startTime;
    }
    
    
    
    // ------------------------------------------------------------------------
    // Query to get total earned rewards from stake
    // ------------------------------------------------------------------------
    function totalStakeRewardsClaimedTillToday(address _user) external view returns(uint256 _totalEarned){
        return users[_user][address(ybree)].totalGained;
    }
    
    // ------------------------------------------------------------------------
    // Query to get the staking rate
    // ------------------------------------------------------------------------
    function latestStakingRate() public view returns(uint256 APY){
        return tokens[address(ybree)].rate;
    }
    
    // ------------------------------------------------------------------------
    // Query to get the staking rate you staked at
    // ------------------------------------------------------------------------
    function yourStakingRate(address _user) public view returns(uint256 _stakingRate){
        return users[_user][address(ybree)].rate;
    }
    
    // ------------------------------------------------------------------------
    // Query to get the staking period you staked at
    // ------------------------------------------------------------------------
    function yourStakingPeriod(address _user) public view returns(uint256 _stakingPeriod){
        return users[_user][address(ybree)].period;
    }
    
    // ------------------------------------------------------------------------
    // Query to get the staking time left
    // ------------------------------------------------------------------------
    function stakingTimeLeft(address _user) external view returns(uint256 _secsLeft){
        uint256 left = 0; 
        uint256 expiryDate = (users[_user][address(ybree)].period).add(lastStakedOn(_user));
        
        if(now < expiryDate)
            left = expiryDate.sub(now);
            
        return left;
    }
    
    //#########################################################################################################################################################//
    //####################################################STAKING ONLY OWNER FUNCTION##########################################################################//
    //#########################################################################################################################################################//
    
    // ------------------------------------------------------------------------
    // Change staking rate
    // @param _newStakingRate new rate applied for staking
    // @required only owner 
    // ------------------------------------------------------------------------  
    function changeStakingRate(uint256 _newStakingRate) public onlyOwner{
        
        tokens[address(ybree)].rate = _newStakingRate;
        
        emit StakingRateChanged(_newStakingRate);
    }
    
    // ------------------------------------------------------------------------
    // Add accounts to the white list
    // @param _account the address of the account to be added to the whitelist
    // @required only callable by owner
    // ------------------------------------------------------------------------
    function whiteList(address _account) public onlyOwner{
       users[_account][address(ybree)].whitelisted = true;
    }
    
    // ------------------------------------------------------------------------
    // Change the staking period
    // @param _seconds number of seconds to stake (n days = n*24*60*60)
    // @required only callable by owner
    // ------------------------------------------------------------------------
    function setStakingPeriod(uint256 _seconds) public onlyOwner{
       stakingPeriod = _seconds;
    }
    
    // ------------------------------------------------------------------------
    // Change the staking claim fee
    // @param _fee claim fee in weis
    // @required only callable by owner
    // ------------------------------------------------------------------------
    function setClaimFee(uint256 _fee) public onlyOwner{
       stakeClaimFee = _fee;
    }
    
    //#########################################################################################################################################################//
    //################################################################COMMON UTILITIES#########################################################################//
    //#########################################################################################################################################################//    
    
    // ------------------------------------------------------------------------
    // Internal function to add new deposit
    // ------------------------------------------------------------------------        
    function _newDeposit(address _tokenAddress, uint256 _amount) internal{
        require(users[msg.sender][_tokenAddress].activeDeposit ==  0, "Already running");
        require(tokens[_tokenAddress].exists, "Token doesn't exist");
        
        // add that token into the contract balance
        // check if we have any pending reward/yield, add it to pendingGains variable
        if(_tokenAddress == address(ybree)){
            users[msg.sender][_tokenAddress].pendingGains = pendingReward(msg.sender);
            users[msg.sender][_tokenAddress].period = stakingPeriod;
            users[msg.sender][_tokenAddress].rate = tokens[_tokenAddress].rate; // rate for stakers will be fixed at time of staking
        }
        else
            users[msg.sender][_tokenAddress].pendingGains = pendingYield(_tokenAddress, msg.sender);
            
        users[msg.sender][_tokenAddress].activeDeposit = _amount;
        users[msg.sender][_tokenAddress].totalDeposits = users[msg.sender][_tokenAddress].totalDeposits.add(_amount);
        users[msg.sender][_tokenAddress].startTime = now;
        users[msg.sender][_tokenAddress].lastClaimedDate = now;
        
    }

    // ------------------------------------------------------------------------
    // Internal function to add to existing deposit
    // ------------------------------------------------------------------------        
     function _addToExisting(address _tokenAddress, uint256 _amount) internal{
        require(tokens[_tokenAddress].exists, "Token doesn't exist");
        // require(users[msg.sender][_tokenAddress].running, "no running farming/stake");
        require(users[msg.sender][_tokenAddress].activeDeposit > 0, "no running farming/stake");
        // update farming stats
            // check if we have any pending reward/yield, add it to pendingGains variable
            if(_tokenAddress == address(ybree)){
                users[msg.sender][_tokenAddress].pendingGains = pendingReward(msg.sender);
                users[msg.sender][_tokenAddress].period = stakingPeriod;
                users[msg.sender][_tokenAddress].rate = tokens[_tokenAddress].rate; // rate of only staking will be updated when more is added to stake
            }
            else
                users[msg.sender][_tokenAddress].pendingGains = pendingYield(_tokenAddress, msg.sender);
            // update current deposited amount 
            users[msg.sender][_tokenAddress].activeDeposit = users[msg.sender][_tokenAddress].activeDeposit.add(_amount);
            // update total deposits till today
            users[msg.sender][_tokenAddress].totalDeposits = users[msg.sender][_tokenAddress].totalDeposits.add(_amount);
            // update new deposit start time -- new stake/farming will begin from this time onwards
            users[msg.sender][_tokenAddress].startTime = now;
            // reset last claimed figure as well -- new stake/farming will begin from this time onwards
            users[msg.sender][_tokenAddress].lastClaimedDate = now;
    }

    // ------------------------------------------------------------------------
    // Internal function to add token
    // ------------------------------------------------------------------------     
    function _addToken(address _tokenAddress, uint256 _rate) internal{
        require(!tokens[_tokenAddress].exists, "token already exists");
        
        tokens[_tokenAddress] = Tokens({
            exists: true,
            rate: _rate
        });
        
        TokensAddresses.push(_tokenAddress);
        emit TokenAdded(_tokenAddress, _rate);
    }
    
    
}

