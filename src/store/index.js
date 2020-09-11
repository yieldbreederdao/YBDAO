import Vue from 'vue'
import Vuex from 'vuex'
import utils from "../utils/abi"

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    BREED:undefined,
    timer:false,
    snackbar:false,
    color:"",
    text:"",
    timout:5000,
    loading:false,
    breedBalance:0,
    DAO:undefined,
    totalStakedGlobal:0,
    totalStakedMe:0,
    myRewards:0,
    totalClaimedGlobal:0,
    totalClaimedMe:0,
    totalFarmClaimedMe:0,
    totalFarmClaimedGlobal:0,
    totalFarmedMe:0,
    farmingBalance:0,
    activeFarmDeposit:0,
    farmRate:0,
    yCrvBalance:0,
    YCRV:undefined,
    currentAddress:undefined,
    currentTokenAddress:utils.yCrvAddress
  },
  mutations: {
    setBreed:(state,data)=>{
      state.BREED=data;
    },
    setDAO:(state,data)=>{
      state.DAO=data;
    },
    setYCRV:(state,data)=>{
      state.YCRV=data;
    },
    setAddress:(state,data)=>{
      state.currentAddress=data
    },
    setStakeDetails:(state,data)=>{
    
      state.totalStakedGlobal= parseFloat(data.totalStakedGlobal);
      state.breedBalance= parseFloat(data.breedBalance);
      state.totalStakedMe= parseFloat(data.totalStakedMe);
      state.myRewards=parseFloat(data.myRewards);
      state.totalClaimedGlobal=parseFloat(data.totalClaimedGlobal);
      state.totalClaimedMe=parseFloat(data.totalClaimedMe);
    },
    setFarmDetails:(state,data)=>{
     // state.yCrvBalance=parseFloat(data.yCrvBalance);
      state.totalFarmClaimedMe=data.totalFarmClaimedMe;
      state.totalFarmedMe=data.totalFarmedMe;
      state.totalFarmClaimedGlobal=parseFloat(data.totalFarmClaimedGlobal);
      //state.activeFarmDeposit=parseFloat(data.activeFarmDeposit);
      //state.farmRate=data.rate
    }
  },
  actions: {
    setBreedContract: async (context)=>{
      let contract=await new window.web3.eth.Contract(utils.abiBree,utils.breedAddress)
      context.commit('setBreed',contract);
      
    },
    setDaoContract: async (context)=>{
      let contract=await new window.web3.eth.Contract(utils.abiDAO,utils.daoAddress)
      context.commit('setDAO',contract);
    },
    
    setYCRVContract:async(context)=>{
      // let contract=await new window.web3.eth.Contract(utils.ycrvAbi,utils.yCrvAddress)
      // context.commit('setYCRV',contract);
    },
    setCurrentAddress:async (context)=>{
      let address=await window.web3.eth.getAccounts();
      console.log("address heerrer:",address)
      context.commit('setAddress',address[0]);
    },

    setStakeDetails:async({commit,state})=>{
      try{
      let breedBalance = await state.BREED.methods
      .balanceOf(state.currentAddress)
      .call();
      breedBalance = await window.web3.utils.fromWei(breedBalance.toString(), "ether");
     

      let totalStakedGlobal = await state.DAO.methods
      .totalLockedStaking()
      .call();
      totalStakedGlobal = await window.web3.utils.fromWei(totalStakedGlobal.toString(), "ether");

      let totalStakedMe=await await state.DAO.methods
      .yourActiveStake(state.currentAddress).call();

      totalStakedMe = await window.web3.utils.fromWei(totalStakedMe.toString(), "ether");

      let myRewards=await await state.DAO.methods.
      pendingReward(state.currentAddress).call();

      myRewards = await window.web3.utils.fromWei(myRewards.toString(), "ether");
 
      
      let totalClaimedGlobal=await await state.DAO.methods.
      totalRewards().call();

      totalClaimedGlobal = await window.web3.utils.fromWei(totalClaimedGlobal.toString(), "ether");

      let totalClaimedMe=await await state.DAO.methods.
      totalStakeRewardsClaimedTillToday(state.currentAddress).call();

      totalClaimedMe = await window.web3.utils.fromWei(totalClaimedMe.toString(), "ether");

     let data={
        breedBalance,
        totalStakedGlobal,
        totalStakedMe,
        myRewards,
        totalClaimedGlobal,
        totalClaimedMe
      }
      commit('setStakeDetails',data);
    }
    catch(err){
      console.log("err:",err)
    }
    },

    setFarmDetails:async({commit,state})=>{
      try{
      

      let totalFarmClaimedMe= await state.DAO.methods.totalFarmingRewards(state.currentTokenAddress,state.currentAddress).call();
      totalFarmClaimedMe=await window.web3.utils.fromWei(totalFarmClaimedMe.toString(),'ether');
      
      let totalFarmedMe= await state.DAO.methods.pendingYield(state.currentTokenAddress,state.currentAddress).call();
      totalFarmedMe=await window.web3.utils.fromWei(totalFarmedMe.toString(),'ether');

      let totalFarmClaimedGlobal= await state.DAO.methods.totalYield().call();
      totalFarmClaimedGlobal=await window.web3.utils.fromWei(totalFarmClaimedGlobal.toString(),'ether');

      // let activeFarmDeposit = await state.DAO.methods
      // .activeFarmDeposit(utils.yCrvAddress, state.currentAddress)
      // .call();
      // activeFarmDeposit = await window.web3.utils.fromWei(activeFarmDeposit.toString(), "ether")

      // let rate=await state.DAO.methods.tokens(utils.yCrvAddress).call()
      // rate=rate.rate

      let data={
       // yCrvBalance,
        totalFarmClaimedMe,
        totalFarmedMe,
        totalFarmClaimedGlobal,
       // activeFarmDeposit,
        //rate
      }
      commit('setFarmDetails',data)
    }
    catch(err){
      console.log("Err:",err);
    }
    }
  },
  modules: {
  }
})
