<template>
  <v-card height="220px" class="mx-auto" outlined>
    <v-card-title class="pa-3" :class="{ 'card-title-bg-light': !$vuetify.theme.dark, 'card-title-bg-dark':  $vuetify.theme.dark }">
      <GiftIcon size="0.8x" class="custom-class mr-1"></GiftIcon><span class="font-weight-light" style="font-size: 17px;">MY REWARDS</span>
    </v-card-title>
    <hr class="hr-styles" />
   <div :class="{'stake-cards':!$vuetify.theme.dark,'stake-cards-light':$vuetify.theme.dark}" justify="center"  class="font-weight-light stake-cards">
      {{$store.state.myRewards}} YBREE <span @click="updateReward" style="position:relative;bottom:2px;cursor:pointer"><v-icon>mdi-refresh</v-icon></span>
    </div>
    <hr class="hr-styles" />  
    <div class="pa-4 d-flex">
      <v-btn  :disabled="this.$store.state.myRewards>0?false:true" @click="claimStakeReward" class="ma-2" color="primary" elevation="0" style="font-size: 12px; width: 145px">
        <CornerUpRightIcon size="1.2x" class="custom-class ml-3"></CornerUpRightIcon> <span class="ml-4 mr-5">CLAIM</span>
      </v-btn>
      <v-tooltip  max-width="200px" bottom>
        <template v-slot:activator="{ on, attrs }">
          <p class="mt-n1"><InfoIcon v-bind="attrs" v-on="on" size="1.1x" class="ml-n1" style="color: #ABACAE"></InfoIcon></p>
        </template>
        <small>You can claim your rewards immediately. Rewards will stop accumulating once your default lock-in period ends.</small>
      </v-tooltip>
    </div>
  </v-card>
</template>

<script>
import { GiftIcon, CornerUpRightIcon, InfoIcon } from 'vue-feather-icons'
  export default {
    components: {
      GiftIcon,
      CornerUpRightIcon,
      InfoIcon
    },
    data: () => ({
      //
      currentAddress:undefined,
      balance:0,
    }),
    methods: {
      async claimStakeReward(){
        try{
          let balance=await window.web3.eth.getBalance(this.currentAddress);
          balance=parseFloat(await window.web3.utils.fromWei(balance,'ether'));
          let fee=await this.$store.state.DAO.methods.stakeClaimFee().call();
          let ethfee=parseFloat(await window.web3.utils.fromWei(fee,'ether'));
          if(balance<ethfee){
            this.$store.state.text=`You don't have enough ether to pay claiming fee of ${ethFee} ether.`
            this. this.$store.state.color="red";
            this.$store.state.snackbar=true;
            return;
          }
           else if(this.$store.state.myRewards<=0){
             this.$store.state.text="You don't have any stake rewards to claim"
            this. this.$store.state.color="red";
            this.$store.state.snackbar=true;
            return;
          }
          this.$store.state.loading=true
          let claim=await this.$store.state.DAO.methods.ClaimReward().send({from:this.currentAddress,value:fee});
           await this.$store.dispatch('setStakeDetails');
          this.$store.state.color="green"
          this.$store.state.text="Transaction completed successfully"
          this.$store.state.snackbar=true;
        }catch(err){
          console.log(err);
            this.$store.state.color="red"
          this.$store.state.text="Transaction failed, something went wrong"
          this.$store.state.snackbar=true;
        }
        finally{
          this.$store.state.loading=false;
        
        }
      },
      async updateReward(){
        this.$store.state.loading=true;
        await this.$store.dispatch('setStackDetails')
        this.$store.state.loading=false;
       
      //  let timerr = setInterval( async()=>{
      //   let myRewards=await this.$store.state.DAO.methods.
      //    pendingReward(this.currentAddress).call();
      //   console.log('updating')
      //   this.$store.state.myRewards = await window.web3.utils.fromWei(myRewards.toString(), "ether");
      //   },30000)
        
      }
    },  
    async created() {
      this.currentAddress=this.$store.state.currentAddress
      await this.updateReward();
    },
  
  }
</script>