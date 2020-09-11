<template>
  <v-card class="mx-auto" height="270" outlined>
    <v-card-title class="pa-3" :class="{ 'card-title-bg-light': !$vuetify.theme.dark, 'card-title-bg-dark':  $vuetify.theme.dark }">
      <GiftIcon size="0.8x" class="custom-class mr-1"></GiftIcon><span class="font-weight-light" style="font-size: 17px;">FARMED</span>
    </v-card-title>
    <hr class="hr-styles" />
    <v-card-text class="font-weight-light my-2 px-7" style="font-size: 18px; height: 120px">
      {{this.$store.state.totalFarmedMe}} YBREE <span @click="updateReward" style="position:relative;bottom:2px;cursor:pointer"><v-icon>mdi-refresh</v-icon></span>
    </v-card-text>
    <hr class="hr-styles" />
    <v-card-actions  style="padding:16px;">
      <v-btn :disabled="$store.state.totalFarmedMe>0?false:true" @click="claimFarmReward" class="ml-2" color="primary" style="font-size: 12px; width: 150px" v-bind="attrs" v-on="on" elevation="0">
        <CornerUpRightIcon size="1.2x" class="custom-class ml-3"></CornerUpRightIcon> <span class="ml-4 mr-5">CLAIM</span>
      </v-btn>
    </v-card-actions>
  </v-card>
</template>

<script>
import { CornerUpRightIcon, GiftIcon } from "vue-feather-icons";
  export default {
    components: {
      CornerUpRightIcon,
      GiftIcon
    },
    data: () => ({
      //
      balance:0
    }),
    methods: {
       async claimFarmReward(){
        try{
          let balance=await window.web3.eth.getBalance(this.currentAddress);
          balance=parseFloat(await window.web3.utils.fromWei(balance,'ether'));
          let fee=await this.$store.state.DAO.methods.yieldCollectionFee().call();
          let ethfee=parseFloat(await window.web3.utils.fromWei(fee,'ether'));
          if(balance<ethfee){
            this.$store.state.text=`You don't have enough ether to pay claiming fee of ${ethFee} ether.`
            this. this.$store.state.color="red";
            this.$store.state.snackbar=true;
            return;
          }
          else if(this.$store.state.totalFarmedMe<=0){
             this.$store.state.text="You don't have any yield rewards to claim"
            this. this.$store.state.color="red";
            this.$store.state.snackbar=true;
            return;
          }
          this.$store.state.loading=true
          let claim=await this.$store.state.DAO.methods.YIELD(this.$store.state.currentTokenAddress).send({from:this.currentAddress,value:fee});
           await this.$store.dispatch('setFarmDetails');
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
        await this.$store.dispatch('setFarmDetails');
        this.$store.state.loading=false;
      }
      // async updateReward(){
        
       
      //  let timerr = setInterval( async()=>{
      //   let myRewards=await this.$store.state.DAO.methods.
      //    pendingYield(this.$store.state.currentTokenAddress,this.currentAddress).call();
      //  console.log("updating farm")
      //   this.$store.state.totalFarmedMe = await window.web3.utils.fromWei(myRewards.toString(), "ether");
      //   },30000)
        
      // }
    },
  
  async created() {
    try{
     this.currentAddress=this.$store.state.currentAddress;
     await this.$store.dispatch('setFarmDetails')
     this.updateReward();
    }
    catch(err){
      console.log("here 86:",err);
    }
     
  },
  }
</script>