<template>
  <div class="stacking-dashboard">
    <div>
      <div class="my-5 mx-3">
        <p class="ma-0 grey--text" style="font-size: 12px">Staking Dashboard</p>
        <h2 class="ma-0 font-weight-light">MY STATISTICS</h2>
      </div>
    </div>
    <hr class="mx-n5 hr-styles" />
    <div class="pa-3">
      <v-row>
        <v-col cols="12" md="3">
          <StakingBalance />
        </v-col>
        <v-col cols="12" md="3">
          <StakingStakedBalance :key="$store.state.timer" />
        </v-col>
        <v-col cols="12" md="3">
          <StakingRewards />
        </v-col>
        <v-col cols="12" md="3">
          <StakingClaimed />
        </v-col>
      </v-row>
    </div>
    <div>
      <div class="mx-3">
        <h2 class="ma-0 mt-2 font-weight-light">GLOBAL STATISTICS</h2>
      </div>
      <div class="px-3">
        <v-row class="">
          <v-col cols="12" md="5">
            <StakingTotalLocked />
          </v-col>
          <v-col cols="12" md="5">
            <StakingTotalClaimedRewards />
          </v-col>
          <!-- <v-col cols="12" md="4">
            <StakingtotalAccumulatedRewards />
          </v-col> -->
        </v-row>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Staking',
  components: {
    StakingBalance: () => import('../components/Staking/StakingBalance'),
    StakingStakedBalance: () => import('../components/Staking/StakingStakedBalance'),
    StakingRewards: () => import('../components/Staking/StakingRewards'),
    StakingClaimed:  () => import('../components/Staking/StakingClaimed'),
    StakingTotalLocked:  () => import('../components/Staking/StakingTotalLocked'),
    StakingTotalClaimedRewards: () => import('../components/Staking/StakingTotalClaimedRewards'),
    StakingtotalAccumulatedRewards: () => import('../components/Staking/StakingTotalAccumulatedRewards')
  },
  async created() {
     this.$store.state.loading=true;
     await this.$store.dispatch("setStakeDetails");
     this.$store.state.loading=false;
  },
  
  
}
</script>
