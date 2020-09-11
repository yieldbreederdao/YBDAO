<template>
  <v-card class="mx-auto" outlined>
    <v-card-title>
      <span class="font-weight-regular" style="font-size: 17px;">TOTAL ACCUMULATED REWARDS</span>
    </v-card-title>
    <hr class="hr-styles" />
    <v-card-text class="font-weight-light my-2" style="font-size: 18px">
      132,923,293.29310 YBREE
    </v-card-text>
  </v-card>
</template>

<script>
  export default {
    data: () => ({
      //
      currentAddress:undefined,
      balance:0
    }),
    async created() {
      this.currentAddress=this.$store.state.currentAddress
         let bal= await this.$store.state.DAO.methods.totalStakeRewardsClaimedTillToday(this.currentAddress).call();
      this.balance=await window.web3.utils.fromWei(bal.toString(),'ether');
    },
  }
</script>